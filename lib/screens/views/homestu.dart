import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tweet_up/screens/views/Teacher-Module/create_class.dart';
import '../authenticate/login.dart';
import 'Student-Module/Home-Widgets/joined_classes.dart';
import 'Student-Module/Home-Widgets/my_classes.dart';
import 'Student-Module/Home-Widgets/upcoming_classes.dart';
import 'Teacher-Module/enrolled_classes.dart';
import 'Student-Module/join_class.dart';

class HomeStudent extends StatefulWidget {
  static const routeName = '/homestu';
  const HomeStudent({Key? key}) : super(key: key);

  @override
  homestuState createState() => homestuState();
}

class homestuState extends State<HomeStudent> {
  var currentId = FirebaseAuth.instance.currentUser!.uid;
  String userName = '';
  String emailID = '';
  String userProfile = '';

  void saveFcmToken() {
    FirebaseMessaging.instance.getToken().then((fcmToken) {
      FirebaseFirestore.instance.collection('users').doc(currentId).update({
        'token': fcmToken.toString(),
      });
    });
  }

  void fetchMyData() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentId)
        .get()
        .then((value) {
      if (value.exists) {
        if (mounted) {
          setState(() {
            userName = value['name'];
            emailID = value['email'];
            userProfile = value['userImage'];
          });
        }
      }
    });
  }

  @override
  void initState() {
    saveFcmToken();
    fetchMyData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String image =
      "https://img.freepik.com/free-vector/laptop-with-program-code-isometric-icon-software-development-programming-applications-dark-neon_39422-971.jpg";
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    var width = MediaQuery.of(context).size.width;
    var height =
        MediaQuery.of(context).size.height - AppBar().preferredSize.height;
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (builder) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ListTile(
                          visualDensity: const VisualDensity(vertical: -4),
                          title: const Text("Create class"),
                          onTap: () {
                            Navigator.of(context).pop('popped');
                            Navigator.of(context)
                                .pushNamed(CreateClass.routeName);
                          },
                        ),
                        ListTile(
                          visualDensity: const VisualDensity(vertical: -4),
                          title: const Text("Join class"),
                          onTap: () {
                            Navigator.of(context).pop('popped');
                            Navigator.of(context)
                                .pushNamed(JoinClass.routeName);
                          },
                        ),
                      ],
                    ),
                  );
                });
          },
          child: const Icon(CupertinoIcons.add),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserInfo(
                    userName: userName,
                    emailId: emailID,
                    userProfile: userProfile),
                SizedBox(height: height * 0.03),
                Text(
                  "UpComing Classes",
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("classes")
                      .where("enrolledStudentsId", arrayContains: currentId)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: Text("Loading"));
                    }
                    if (snapshot.data!.size == 0) {
                      log('lenght us => ${snapshot.data!.size}');
                      return SizedBox(
                        height: height * 0.07,
                        child: const Center(
                          child: Text(
                            "No Upcoming classes",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      );
                    }
                    return Container(
                      height: height * 0.36,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30)),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                              return StreamBuilder<QuerySnapshot>(
                                  stream: document.reference
                                      .collection('upComingClasses')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return const Text('Something went wrong');
                                    }
                                    if (!snapshot.hasData) {
                                      return const Center(
                                          child: Text("Loading"));
                                    }
                                    if (snapshot.data!.size == 0) {
                                      log('lenght us => ${snapshot.data!.size}');
                                      return const Center(
                                          child: Text("No Upcoming class"));
                                    }
                                    return ListView(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      children: snapshot.data!.docs.map((e) {
                                        DateTime dateTime =
                                            DateTime.parse(e['date']);
                                        String formattedDate =
                                            DateFormat('dd EEEE')
                                                .format(dateTime);
                                        return UpcomingClasses(
                                          snapshot: e,
                                          meetingTime:
                                              '$formattedDate-${e['time']}',
                                          subname: document['subName'],
                                          batch: document['batch'],
                                        );
                                      }).toList(),
                                    );
                                  });
                            })
                            .toList()
                            .cast(),
                      ),
                    );
                  },
                ),
                SizedBox(height: height * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "All Courses",
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                            EnrolledClasses.routeName,
                            arguments: user?.uid);
                      },
                      child: Text(
                        "See All",
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("classes")
                      .where("enrolledStudentsId",
                          arrayContains: FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text("Loading...."),
                      );
                    }
                    if (snapshot.data!.size == 0) {
                      return SizedBox(
                          height: height * 0.07,
                          child: const Center(child: Text("No Courses")));
                    }
                    return ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                              return JoinedClasses(document: document);
                            })
                            .toList()
                            .cast());
                  },
                ),
                Text(
                  "My Classes",
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("classes")
                        .where("teacherId",
                            isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Text("Loading...."),
                        );
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text("No class created by you"));
                      }
                      return MyClasses(snapshot: snapshot);
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserInfo extends StatelessWidget {
  const UserInfo({
    super.key,
    required this.emailId,
    required this.userName,
    required this.userProfile,
  });
  final String emailId, userName, userProfile;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 35,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    maxRadius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: Image.network('$userProfile').image,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('$userName',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                                fontStyle: FontStyle.italic)),
                        IconButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser?.uid)
                                  .update({
                                'token': '',
                              });
                              await FirebaseAuth.instance
                                  .signOut()
                                  .then((value) {
                                Navigator.pushReplacementNamed(
                                    context, LoginScreen.id);
                              });
                            },
                            icon: const Icon(Icons.logout, color: Colors.white))
                      ],
                    ),
                    // SizedBox(height: 2.h,),
                    Text("$emailId",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -58,
          top: -50,
          child: Container(
            padding: const EdgeInsets.all(45),
            decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  width: 18,
                  color: Colors.white70,
                )),
          ),
        ),
        Positioned(
          right: -45,
          top: -40,
          child: Container(
            padding: const EdgeInsets.all(60),
            decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  width: 18,
                  color: Colors.white70,
                )),
          ),
        ),
      ],
    );
  }
}
