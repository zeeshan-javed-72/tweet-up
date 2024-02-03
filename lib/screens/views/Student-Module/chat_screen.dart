import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tweet_up/generated/assets.dart';
import 'package:tweet_up/screens/views/Student-Module/chat_view/widgets/chat_badge_widget.dart';
import 'package:tweet_up/screens/views/Teacher-Module/class_announcements.dart';

class ChatScreen extends StatefulWidget {
  final Map<dynamic, dynamic>? classData;
  const ChatScreen({Key? key, this.classData}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Group Chat'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("classes")
            .where("enrolledStudentsId", arrayContains: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (!snapshot.hasData) {
            return const Text("Loading");
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No chat available"));
          }
          return ListView(
            physics: const BouncingScrollPhysics(),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) => Announcements(
                                  classData: document.data() as dynamic,
                                )));
                  },
                  visualDensity: const VisualDensity(horizontal: -4),
                  style: ListTileStyle.drawer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black),
                  ),
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(Assets.imagesAppIcon),
                  ),
                  title: Title(
                    color: Colors.black,
                    child: Text("${document['subName']}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.inter().fontFamily
                    ),
                    ),
                  ),
                  subtitle: const Text("Lets go for Flutter 3.8"),
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text("22-03-2023"),
                        ChatBadgeWidget(chatRoomId: document.id,),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
