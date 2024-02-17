import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tweet_up/screens/views/Student-Module/submit_view_classwork.dart';
import 'package:tweet_up/util/utils.dart';
import '../../../constants/appColors.dart';
import '../../../constants/constants.dart';

class EnrolledClasses extends StatefulWidget {
  static const routeName = '/enrolled-classes';

  EnrolledClasses({Key? key}) : super(key: key);

  @override
  State<EnrolledClasses> createState() => _EnrolledClassesState();
}

class _EnrolledClassesState extends State<EnrolledClasses>
    with SingleTickerProviderStateMixin {
  List<Color> colorList = [
    const Color.fromRGBO(136, 14, 79, .1),
    const Color.fromRGBO(136, 14, 79, .2),
    const Color.fromRGBO(136, 14, 79, .3),
    const Color.fromRGBO(136, 14, 79, .4),
    const Color.fromRGBO(136, 14, 79, .5),
    const Color.fromRGBO(136, 14, 79, .6),
    const Color.fromRGBO(136, 14, 79, .7),
    const Color.fromRGBO(136, 14, 79, .8),
    const Color.fromRGBO(136, 14, 79, .9),
    const Color.fromRGBO(136, 14, 79, .10),
  ];
  var currentId = FirebaseAuth.instance.currentUser?.uid;
  @override
  Widget build(BuildContext context) {
    var colorIndex = -1;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All your classes',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("classes")
            .where("enrolledStudentsId", arrayContains: currentId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.size == 0) {
            return const Center(child: Text("No classes found"));
          }

          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var enrolledClasses = snapshot.data!.docs[index];
                return Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.white70, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          PopupMenuButton(
                              itemBuilder: (ctx) => [
                                    PopupMenuItem(
                                      onTap: () {
                                        Future.delayed(
                                            const Duration(microseconds: 0),
                                            () => showDialog(
                                                barrierDismissible: true,
                                                useSafeArea: true,
                                                context: context,
                                                builder: (ctx) => Container(
                                                      width: 300,
                                                      height: 100,
                                                      decoration:
                                                          const BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8)),
                                                      ),
                                                      child: BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 6,
                                                                sigmaY: 6),
                                                        child:
                                                            CupertinoAlertDialog(
                                                          title: const Text(
                                                              "Alert Box"),
                                                          content: Wrap(
                                                            children: [
                                                              const Text(
                                                                  "Do You Want to Leave"),
                                                              Text(
                                                                ' ${enrolledClasses['subName']}',
                                                                style:
                                                                    TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              const Text(
                                                                  " Class"),
                                                            ],
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  "Cancel"),
                                                            ),
                                                            TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          "classes")
                                                                      .doc(enrolledClasses
                                                                          .id)
                                                                      .update({
                                                                    "enrolledStudentsId":
                                                                        FieldValue
                                                                            .arrayRemove([
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid,
                                                                    ]),
                                                                  });
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          "classes")
                                                                      .doc(enrolledClasses
                                                                          .id)
                                                                      .update({
                                                                    "enrolledStudents":
                                                                        FieldValue
                                                                            .arrayRemove([
                                                                      {
                                                                        "studentId": FirebaseAuth
                                                                            .instance
                                                                            .currentUser!
                                                                            .uid,
                                                                        "rollNo":
                                                                            enrolledClasses['enrolledStudents'][enrolledClasses.reference]['rollNo'],
                                                                      },
                                                                    ]),
                                                                  }).then((value) {
                                                                    Navigator.pop(
                                                                        context);
                                                                    Utils.snackBar(
                                                                        message:
                                                                            "Class leaved",
                                                                        context:
                                                                            context,
                                                                        color: AppColors
                                                                            .errorColor);
                                                                  });
                                                                },
                                                                child: const Text(
                                                                    "Leave")),
                                                          ],
                                                        ),
                                                      ),
                                                    )));
                                      },
                                      value: 1,
                                      child: const Text("Leave Class"),
                                    )
                                  ]),
                        ],
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 5),
                          child: Text(
                            enrolledClasses["subName"],
                            maxLines: 1,
                            textAlign: TextAlign.start,
                            style: kPageTitleStyleBlack,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              shadowColor:
                                  Theme.of(context).colorScheme.secondary,
                              color: colorList[colorIndex % colorList.length],
                              child: Builder(builder: (context) {
                                return TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (_) => SubmitClasswork(
                                                  classData: enrolledClasses
                                                      .data() as dynamic,
                                                )));
                                    // Navigator.of(context).pushNamed(
                                    //     SubjectClassStudent.routeName,
                                    //     arguments: enrolledClasses,
                                    // );
                                  },
                                  child: Center(
                                    child: Text(
                                      'View class',
                                      style: GoogleFonts.questrial(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              });
        },
      ),
    );
  }
}

class Arguments {
  final String collectionName;

  Arguments(this.collectionName);
}
