import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpcomingClassesStudent extends StatefulWidget {
  final Map<dynamic, dynamic>? classData;
  const UpcomingClassesStudent({
    super.key,
    this.classData,
  });

  @override
  UpcomingClassesStudentState createState() => UpcomingClassesStudentState();
}

class UpcomingClassesStudentState extends State<UpcomingClassesStudent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collectionGroup("assignments")
              .where("enrolledStudentsId",
                  isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (!snapshot.hasData) {
              return Center(
                  child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              ));
            }
            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text("No Upcoming Lectures Available"));
            }
            return ListView(
              shrinkWrap: true,
              children: snapshot.data!.docs
                  .skip(1)
                  .map((lectureData) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Topic: ${lectureData['assignmentTopic']}',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(
                              'Date: ${(lectureData['assignmentDueDate'].toString()).substring(0, 10)}',
                              style: GoogleFonts.poppins(fontSize: 15),
                            ),
                            Text(
                                'Time: ${lectureData['assignmentDueDate'].toString().substring(10, 15)}'),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.amber,
                              ),
                              onPressed: () {},
                              child: const Text('Open url'),
                            ),
                          ],
                        ),
                      ),
                    );
                  })
                  .toList()
                  .cast(),
            );
          }),
    );
  }
}
