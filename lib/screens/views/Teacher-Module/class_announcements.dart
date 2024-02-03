import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tweet_up/services/firestore_service.dart';
import '../../../services/database.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

List<Color> colorList = [
  const Color.fromRGBO(255, 173, 173, 1),
  const Color.fromRGBO(64, 166, 166,  1),
  const Color.fromRGBO(200, 231, 255, 1),
  const Color.fromRGBO(242, 232, 207, 1),
  const Color.fromRGBO(155, 246, 255, 1),
  const Color.fromRGBO(160, 196, 255, 1),
  const Color.fromRGBO(189, 178, 255, 1),
  const Color.fromRGBO(255, 198, 255, 1),
];

class Announcements extends StatefulWidget {
  final Map<dynamic, dynamic>? classData;
  const Announcements({super.key,this.classData});
  static const routeName = '/announcements';

  @override
  AnnouncementsState createState() => AnnouncementsState();
}

class AnnouncementsState extends State<Announcements> {

  final announcement = TextEditingController();
  final _scrollController = ScrollController();
  User? user = FirebaseAuth.instance.currentUser;

  Color? color = Colors.grey.shade300;
  bool isTure = false;
  String tokens = "";
  String userName = '';
  String userImg = '';
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? messagesSubscription;
  List<String> fcmTokens = [];

  void getUserData(){
    fcmTokens.clear();
   FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if(doc.exists){
          if(mounted){
            setState(() => fcmTokens.add(doc['token']??''));
          }
          log('tokens ===> ${fcmTokens}');
        }
      }
    });
  }
  void getMyData(){
    FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots()
        .listen((event) {
        userName = event['name'];
        userImg = event['userImage'];
    });
  }
  void readAllMessages(){
    messagesSubscription = FirebaseFirestore.instance
        .collection('classes')
        .doc(widget.classData?['code'])
        .collection('groupChat')
        .where(
        'status', isEqualTo: 'unread',
    ).where('postedBy', isNotEqualTo: user?.uid)
        .snapshots()
        .listen((querySnapshot) {
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'status': 'read'});
      }
      batch.commit();
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    getMyData();
    readAllMessages();
  }

  @override
  void dispose() {
    messagesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(widget.classData!['subName'].toString(),
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          ListOfAnnouncements(classData: widget.classData!, scrollController: _scrollController),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  flex: 8,
                  child: TextFormField(
                    controller: announcement,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    onChanged: (String? index){
                      if(index!.isNotEmpty){
                        setState(() {
                          color = Theme.of(context).primaryColor;
                          isTure = false;
                        });
                      }else if(index.isEmpty){
                        setState(() {
                          color = Colors.grey.shade300;
                          isTure = true;
                        });
                      }
                    },
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 8, top: 0, bottom: 0, right: 0),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      filled: true,
                      hintText: "Type a message",
                      fillColor: Colors.grey.shade300,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    onPressed: () async{
                      if (announcement.text.isNotEmpty){
                        _scrollController.animateTo(
                            _scrollController.position.minScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut);
                        ClassDatabase.groupMessage(
                          widget.classData?['code'],
                          FirebaseAuth.instance.currentUser!.uid,
                          announcement.text.trim(),
                          userName.toString(),
                        );
                        NotificationService.sendPushNotification(
                          title: userName.toString(),
                          body: announcement.text.trim(),
                          fcmToken: fcmTokens,
                          profile: userImg,
                        );
                        announcement.clear();
                      }
                    },
                    icon: Icon(Icons.send_outlined,
                      size: 28, color: announcement.text.isEmpty ? Colors.grey :
                      Theme.of(context).primaryColor,),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListOfAnnouncements extends StatelessWidget {
    ListOfAnnouncements({super.key, required this.classData, required this.scrollController}) ;

  final Map classData;
  final ScrollController scrollController;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("classes")
              .doc(classData['code'])
              .collection('groupChat')
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }
            if (!snapshot.hasData) {
              return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator.adaptive(backgroundColor: Colors.grey),
                  Text("Loading"),
                ],
              ));
            }
            return  ListView(
              controller: scrollController,
              reverse: true,
              children: snapshot.data!.docs.map((announcementData){
                return Padding(
                  padding:  const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  child: Column(
                    crossAxisAlignment: announcementData['postedBy']
                        == FirebaseAuth.instance.currentUser?.uid ?
                    CrossAxisAlignment.start : CrossAxisAlignment.end,
                    children: [
                      Text('${announcementData['senderName']}',
                        style: TextStyle(
                            color: announcementData['postedBy'] ==
                                FirebaseAuth.instance.currentUser?.uid ?
                            Colors.black  : Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width -95,
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 12),
                          decoration: BoxDecoration(
                              color: announcementData['postedBy'] == FirebaseAuth.instance.currentUser?.uid ?
                              Theme.of(context).primaryColor : const Color(0xffEDF0F2),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                topLeft: Radius.zero,
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              )
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                announcementData['post'],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: announcementData['postedBy']
                                        == FirebaseAuth.instance.currentUser?.uid ?
                                    Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(DateFormat("MMM d hh:mm a").format(announcementData['time'].toDate()),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            color: announcementData['postedBy']
                                == FirebaseAuth.instance.currentUser?.uid ?
                            Colors.grey : Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 10
                        ),
                      ),
                      // SentMessage(message: "message", send: announcementData['postedBy']),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
    );
  }
}

class Triangle extends CustomPainter {
  final Color bgColor;

  Triangle(this.bgColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = bgColor;

    var path = Path();
    path.lineTo(-5, 0);
    path.lineTo(0, 10);
    path.lineTo(5, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class SentMessage extends StatelessWidget {
  final String message;
  final String send;
   SentMessage({
    Key? key,
    required this.send,
    required this.message,
  }) : super(key: key);

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final messageTextGroup = Flexible(
        child: Row(
          mainAxisAlignment: send == user?.uid ? MainAxisAlignment.start : MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            send == user?.uid ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: CustomPaint(
                painter: Triangle(Colors.grey.shade300),
              ),
            ): Container(),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: send == user?.uid ? Theme.of(context).primaryColor : Colors.grey[900],
                  borderRadius: send == user?.uid ?
                  const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ) :
                  const BorderRadius.only(
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white,
                      fontFamily: 'Monstserrat', fontSize: 14),
                ),
              ),
            ),
            CustomPaint(painter: Triangle(Colors.grey.shade900)),
          ],
        ));

    return Padding(
      padding: send != user?.uid ? const EdgeInsets.only(right: 18.0, left: 50, top: 5, bottom: 5)
            : const EdgeInsets.only(right: 50.0, left: 18, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          const SizedBox(height: 30),
          messageTextGroup,
        ],
      ),
    );
  }
}

