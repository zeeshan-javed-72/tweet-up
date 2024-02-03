// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tweet_up/screens/views/Teacher-Module/subject_class.dart';
import 'package:tweet_up/screens/views/Student-Module/subject_class_student.dart';
import 'package:tweet_up/services/firestore_service.dart';
import 'package:tweet_up/util/utils.dart';
import '../../../constants/constants.dart';
import 'create_class.dart';
import '../Student-Module/created_classes.dart';

class Home extends StatefulWidget {
  static const routeName = '/home';

  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String image = "https://img.freepik.com/free-vector/laptop-w"
      "ith-program-code-isometric-icon-software-development-programming-applications-dark-neon_39422-971.jpg";
  NotificationService firestoreService = NotificationService();
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    // firestoreService.startMeeting(context);
    super.initState();
  }

  int index = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final user = Provider.of<User?>(context);
    late String imgURL;
    if (user == null) {
      imgURL =
          'https://cdn3.iconfinder.com/data/icons/user-interface-web-1/550/web-circle-circular-round_54-512.png';
    } else {
      imgURL = user.photoURL ??
          'https://cdn3.iconfinder.com/data/icons/user-interface-web-1/550/web-circle-circular-round_54-512.png';
    }
    final String? name = user != null ? user.displayName : 'Name';
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(CreateClass.routeName);
        },
        label: const Text(
          'create class',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(CupertinoIcons.add),
      ),
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              Utils.alertDialogue(context: context, title: "Log out");
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          )
        ],
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: Text(
          style: GoogleFonts.poppins(
              textStyle: const TextStyle(
            color: Colors.white,
          )),
          name!,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              UserInfo(imgURL: imgURL, user: user),
              Text(
                'Teacher\'s section',
                textAlign: TextAlign.start,
                style: kPageTitleStyleBlack,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "All your Courses",
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(CreatedClasses.routeName,
                          arguments: user?.email);
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
                    .collection("${user?.email}")
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
                  return ListView(
                      shrinkWrap: true,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                SubjectClass.routeName,
                                arguments: document.data(),
                              );
                            },
                            visualDensity: const VisualDensity(horizontal: -4),
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              height: MediaQuery.of(context).size.height * 0.22,
                              width: width * 0.22,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                  border: Border.all(color: Colors.transparent),
                                  image: DecorationImage(
                                      image: NetworkImage(image),
                                      fit: BoxFit.fill)),
                            ),
                            trailing: IconButton(
                              onPressed: () async {
                                ClipboardData data =
                                    ClipboardData(text: (document['code']));
                                await Clipboard.setData(data);
                                Utils.snackBar(
                                    message: 'Code copied😁',
                                    color: Colors.black,
                                    context: context);
                              },
                              icon: const Icon(Icons.copy,
                                  size: 24, color: Colors.black87),
                            ),
                            title: Text(
                              "${document["subName"]}",
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.textScaleFactorOf(context) * 20,
                                fontFamily: "fonts/Lato-Bold.ttf",
                              ),
                            ),
                            subtitle: const Text(
                              'Class 3',
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }).toList());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserInfo extends StatefulWidget {
  const UserInfo({
    super.key,
    required this.imgURL,
    required this.user,
  });

  final String imgURL;
  final User? user;

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
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
            horizontal: 10,
            vertical: 35,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                maxRadius: 50,
                backgroundColor: Colors.white,
                child: Text(
                  "${widget.user?.displayName?.substring(0, 1)}",
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.user?.displayName}',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        fontFamily: "fonts/Lato-Bold.ttf",
                      ),
                    ),
                    // SizedBox(height: 2.h,),
                    Text('${widget.user?.email}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage your classes like never before. ',
                textAlign: TextAlign.center,
                style: GoogleFonts.questrial(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w900,
                  color: const Color.fromRGBO(20, 33, 61, 1),
                  wordSpacing: 2.5,
                ),
              ),
              Text(
                'Either be a student or a teacher',
                textAlign: TextAlign.center,
                style: GoogleFonts.questrial(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w900,
                  color: const Color.fromRGBO(20, 33, 61, 1),
                  wordSpacing: 2.5,
                ),
              ),
            ],
          ),
        ),
        Positioned(
            right: -45,
            top: -40,
            child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.logout,
                  color: Colors.black,
                ))),
        Positioned(
          right: -45,
          top: -40,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(width: 18, color: const Color(0xFF264CD2))),
          ),
        ),
      ],
    );
  }
}
