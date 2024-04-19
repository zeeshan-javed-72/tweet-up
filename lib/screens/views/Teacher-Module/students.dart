// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mailto/mailto.dart';
import 'package:tweet_up/constants/appColors.dart';
import 'package:tweet_up/util/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class Students extends StatefulWidget {
  final Map<dynamic, dynamic> classData;
  const Students(this.classData, {super.key});

  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          widget.classData['subName'].toString(),
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        iconTheme:
        IconThemeData(color: Theme.of(context).colorScheme.secondary),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              kBottomNavigationBarHeight -
              AppBar().preferredSize.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  top: 8
                ),
                child:  Text('Enrolled Students',
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary,
                  fontSize: 18,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
              Expanded(
                child: widget.classData['enrolledStudents'].length == 0
                    ? NoStudentsEnrolled(classData: widget.classData)
                    : ListOfStudents(
                        classData: widget.classData,
                        user: null,
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NoStudentsEnrolled extends StatelessWidget {
  const NoStudentsEnrolled({
    super.key,
    required this.classData,
  });

  final Map classData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            // alignment: Alignment.center,
            child: Text(
              'No students have enrolled yet😅😅. Invite them now by sending the following link',
              textAlign: TextAlign.center,
              style: GoogleFonts.questrial(fontSize: 20),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                )),
            onPressed: () async {
              ClipboardData data = ClipboardData(text: (classData['code']));
              await Clipboard.setData(data);
              if (kDebugMode) {
                print(classData['code']);
              }
              Utils.snackBar(
                  message: 'Code copied😁',
                  color: const Color(0xffFF8C00),
                  context: context);
            },
            child: Center(
              child: Text(
                'Copy code',
                style: GoogleFonts.questrial(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class ListOfStudents extends StatefulWidget {
  const ListOfStudents({
    super.key,
    required this.classData,
    required this.user,
  });

  final Map classData;
  final User? user;
  @override
  State<ListOfStudents> createState() => _ListOfStudentsState();
}

class _ListOfStudentsState extends State<ListOfStudents> {
  final FirebaseAuth _auth1 = FirebaseAuth.instance;
  var data;
  showDialogFunction(img, name) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: const EdgeInsets.all(15),
              height: 365,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: "${_auth1.currentUser?.photoURL}",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        _auth1.currentUser!.photoURL!,
                        width: 300,
                        height: 300,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      name,
                      maxLines: 3,
                      style: TextStyle(fontSize: 17, color: Colors.grey[100]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("classes")
          .doc(widget.classData['code'])
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
          }
        if (!snapshot.hasData) {
          return const Center(child: Text("Loading"));
        }
        return ListView.builder(
            itemCount: snapshot.data!['enrolledStudents'].length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  dense: true,
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)
                  ),
                  title: Text(
                    snapshot.data?['enrolledStudents'][index]['stdName']??'Name',
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.inter().fontFamily,
                    ),
                  ),
                  subtitle: Text(
                    "${snapshot.data?['enrolledStudents'][index]['rollNo']}",
                    style: const TextStyle(color: Colors.black),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final mailtoLink = Mailto(
                              to: ['${snapshot.data?['enrolledStudents'][index]['email']}'],
                              cc: ['cc1@example.com', 'cc2@example.com'],
                            subject: '${snapshot.data?['enrolledStudents'][index]['stdName']}',
                            body: "What's in your mind?",
                              );
                          await launch('$mailtoLink');
                          // await canLaunchUrl(Uri.parse('mail:$mailtoLink'));
                        },
                        child: Icon(
                          Icons.email,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      PopupMenuButton(
                          // icon: Icon(Icons.highlight_remove),
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
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 6, sigmaY: 6),
                                                    child:
                                                        CupertinoAlertDialog(
                                                      title: const Text(
                                                          "Alert Box"),
                                                      content: const Wrap(
                                                        children: [
                                                          Text(
                                                              "Do You Want to remove "),
                                                          Text("from class"),
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
                                                                  .doc(widget
                                                                          .classData[
                                                                      'code'])
                                                                  .update({
                                                                "enrolledStudentsId":
                                                                    FieldValue
                                                                        .arrayRemove([
                                                                  snapshot.data![
                                                                          'enrolledStudentsId']
                                                                      [index],
                                                                ]),
                                                              });
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "classes")
                                                                  .doc(widget
                                                                          .classData[
                                                                      'code'])
                                                                  .update({
                                                                "enrolledStudents":
                                                                    FieldValue
                                                                        .arrayRemove([
                                                                  snapshot.data![
                                                                          'enrolledStudents']
                                                                      [index],
                                                                ]),
                                                              }).then((value) {
                                                                Navigator.pop(
                                                                    context);
                                                                Utils.snackBar(
                                                                    message:
                                                                        "Student removed",
                                                                    context:
                                                                        context,
                                                                    color: AppColors
                                                                        .errorColor);
                                                              });
                                                            },
                                                            child: const Text(
                                                                "Remove")),
                                                      ],
                                                    ),
                                                  ),
                                                )));
                                    // showAlertDialogBox(context);
                                    if (kDebugMode) {
                                      print('PopUp menu pressed');
                                    }
                                  },
                                  value: 1,
                                  child: const Text("Remove student"),
                                )
                              ]),
                    ],
                  ),
                  leading: Stack(
                    children: [
                       CircleAvatar(
                        radius: 20,
                        backgroundImage: Image.network('${snapshot.data?['enrolledStudents'][index]['stdImg']}').image,
                        backgroundColor: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }
}
