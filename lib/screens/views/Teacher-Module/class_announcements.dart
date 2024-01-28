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
  const Announcements({Key? key,this.classData}) : super(key: key);
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
  getUserData(){
    FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if(mounted){
          setState(() {
            tokens = doc['token'];
            print("this is token $tokens");
          });
        }
      }
    });
  }
  @override
  void initState() {
    super.initState();
    FirestoreService.requestPermission(context);
    FirestoreService.initInfo(context);
    getUserData();
  }
  @override
  Widget build(BuildContext context) {
    // getUserData();
    final user = Provider.of<User?>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.classData!['subName'].toString(),
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        backgroundColor: Colors.white,
      ),
      body: Scaffold(
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
                          // var db = MakeAnnouncement(
                          //   widget.classData?['code'],
                          //   FirebaseAuth.instance.currentUser!.uid,
                          //   announcement.text.trim(),
                          //   user!.displayName!,
                          // );
                          ClassDatabase.groupMessage(
                            widget.classData?['code'],
                            FirebaseAuth.instance.currentUser!.uid,
                            announcement.text.trim(),
                            user!.displayName,
                          );
                           FirestoreService.sendPushNotification(
                            title: user.displayName,
                            body: announcement.text.trim(),
                            token: tokens,
                          );
                          announcement.clear();
                          // await db.makeAnnouncement();
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
    var colorIndex = -1;
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
              return Center(child: Column(
                children: const [
                  CircularProgressIndicator(),
                  Text("Loading"),
                ],
              ));
            }
            colorIndex++;
            return  ListView.builder(
                    controller: scrollController,
                    reverse: true,
                    itemCount: snapshot.data!.docs.skip(1).length + 0,
                    itemBuilder: (context, index) {
                      DocumentSnapshot announcementData =
                          snapshot.data!.docs[index];
                      return Padding(
                        padding:  const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                        child: Column(
                          crossAxisAlignment: announcementData['postedBy']
                              == FirebaseAuth.instance.currentUser?.uid ?
                             CrossAxisAlignment.start : CrossAxisAlignment.end,
                          children: [
                              Text('${announcementData['senderName']}',
                                style: TextStyle(
                                  color: announcementData['postedBy'] == FirebaseAuth.instance.currentUser?.uid ?
                                      Colors.black  : colorList[colorIndex % colorList.length],
                                    fontWeight: FontWeight.bold),
                              ),
                            const SizedBox(height: 2),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width -95,
                              ),
                              child: InkWell(
                                onLongPress: announcementData['postedBy'] == FirebaseAuth.instance.currentUser?.uid ?
                                    (){
                                  showDialog<void>(
                              context: context,
                              barrierDismissible: true,
                              // false = user must tap button, true = tap outside dialog
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: const Text('Alert Box'),
                                  content: const Text('Do you want ot delete message?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Delete'),
                                      onPressed: () {
                                        Navigator.of(dialogContext)
                                            .pop(); // Dismiss alert dialog
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(dialogContext)
                                            .pop(); // Dismiss alert dialog
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }: null,
                                child: Container(
                                  padding: const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 12),
                                    decoration: BoxDecoration(
                                        color: announcementData['postedBy'] == FirebaseAuth.instance.currentUser?.uid ?
                                        Theme.of(context).primaryColor : Colors.blueGrey.shade100,
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
                                                Colors.white : Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    ),
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
                              ),
                            ),
                            // SentMessage(message: "message", send: announcementData['postedBy']),
                        ],
                        ),
                      );
                    },
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

