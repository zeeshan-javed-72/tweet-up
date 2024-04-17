import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_shimmer.dart';
import 'Student-Module/Home-Widgets/upcoming_classes.dart';

class UpcomingClassesWidget extends StatefulWidget {
  const UpcomingClassesWidget({super.key});

  @override
  State<UpcomingClassesWidget> createState() => _UpcomingClassesWidgetState();
}

class _UpcomingClassesWidgetState extends State<UpcomingClassesWidget> {
  var currentId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    var height =
        MediaQuery.of(context).size.height - AppBar().preferredSize.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "UpComing Classes",
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
          ),
        ),
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
            return const CustomShimmer();
          }
          if (snapshot.data!.size == 0) {
            // log('lenght us => ${snapshot.data!.size}');
            return SizedBox(
              height: height * 0.07,
              child: const Center(
                child: Text(
                  "No Upcoming classs",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            );
          }
          return Container(
            // height: height * 0.35,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
            child: ListView(
              // scrollDirection: Axis.vertical,
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
                            return const CustomShimmer();
                          }
                          if (snapshot.data!.size == 0) {
                            return const SizedBox.shrink();
                          }
                          return ListView(
                            padding: const EdgeInsets.all(8),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            children: snapshot.data!.docs.map((e) {
                              DateTime dateTime = DateTime.parse(e['date']);
                              String formattedDate =
                                  DateFormat('dd EEEE').format(dateTime);
                              return UpcomingClasses(
                                snapshot: e,
                                meetingTime: '$formattedDate-${e['time']}',
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
    );
  }
}
