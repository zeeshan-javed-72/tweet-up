import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:tweet_up/Model-View_Classes/classes_view_model.dart';
import 'package:tweet_up/constants/appColors.dart';
import 'package:tweet_up/screens/views/Teacher-Module/upload_assignment.dart';
import 'package:tweet_up/screens/views/Teacher-Module/upload_notes.dart';
import 'package:intl/intl.dart';

class Classwork extends StatefulWidget {
  final Map<dynamic, dynamic> classData;
  const Classwork(this.classData, {Key? key}) : super(key: key);
  @override
  _ClassworkState createState() => _ClassworkState();
}

class _ClassworkState extends State<Classwork>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final classViewModel = Provider.of<ClassesViewModel>(context);
    return Scaffold(
      floatingActionButton: SpeedDial(
        childMargin: const EdgeInsets.only(right: 18, bottom: 10),
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: const IconThemeData(size: 22),
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: const CircleBorder(),
        children: [
          SpeedDialChild(
              child: const Icon(Icons.notes),
              backgroundColor: Colors.red,
              label: 'Upload Notes',
              labelStyle: const TextStyle(fontSize: 18.0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Notes(widget.classData['code'])),
                );
              }),
          SpeedDialChild(
            child: const Icon(Icons.brush),
            backgroundColor: Colors.blue,
            label: 'Give assignment',
            labelStyle: const TextStyle(fontSize: 18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UploadAssignment(
                        code: widget.classData['code'],
                        page: false,
                        email: user.email!)),
              );
            },
          ),
        ],
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.classData['subName'].toString(),
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.secondary),
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(
              text: "Notes",
            ),
            Tab(
              text: "Assignments",
            ),
            Tab(
              text: "Submitted",
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  controller: _tabController,
                  children: [
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("classes")
                            .doc(widget.classData['code'])
                            .collection('notes')
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong');
                          }

                          if (!snapshot.hasData) {
                            return const Text("Loading");
                          }
                          if (snapshot.data!.docs.isEmpty) {
                            return Center(
                                child: const Text("No notes added yet"));
                          }

                          print('No notes added yet');
                          return ListView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 8),
                            children: snapshot.data!.docs.map((document) {
                              return Dismissible(
                                key: const Key('value'),
                                background: Container(
                                  color: Colors.blue,
                                ),
                                secondaryBackground: Container(
                                  color: Colors.red,
                                ),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  tileColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 5),
                                  leading: CircleAvatar(
                                    radius: 25,
                                    child: Text(
                                        "${document['topic'].substring(0, 1)}"),
                                  ),
                                  title: Text(
                                    document['topic'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(DateFormat('MMM-dd hh:mm a')
                                      .format(document['time'].toDate())),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("classes")
                            .doc(widget.classData['code'])
                            .collection('assignments')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong');
                          }
                          if (!snapshot.hasData) {
                            return const Text("Loading");
                          }
                          if (snapshot.data!.docs.isEmpty) {
                            return Center(
                                child: const Text("No assignments added yet"));
                          }
                          return ListView(
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 6, right: 6, bottom: 10, top: 10),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  tileColor: Colors.white,
                                  title: Text(
                                    "${document['assignmentTopic']}",
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    "Due Date: ${DateFormat('MMM-dd hh:mm a').format(document['assignmentDueDate'].toDate())}",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  trailing: FilledButton.tonal(
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          document['assignmentDueDate']
                                                  .toDate()
                                                  .isAfter(DateTime.now())
                                              ? AppColors.successColor
                                              : AppColors.errorColor,
                                      visualDensity: const VisualDensity(
                                          vertical: -1, horizontal: 3),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: document['assignmentDueDate']
                                            .toDate()
                                            .isAfter(DateTime.now())
                                        ? const Text("Active")
                                        : const Text("Expired"),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("classes")
                            .doc(widget.classData['code'])
                            .collection('assignments')
                            .snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong');
                          }
                          if (!snapshot.hasData) {
                            return const Text("Loading");
                          }
                          if (snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text("No assignments added yet"));
                          }
                          return ListView(
                            children: snapshot.data!.docs.map((DocumentSnapshot document) {
                              return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: document['assignmentsUrl'].length,
                                  itemBuilder: (context,index){
                                    final data = document['assignmentsUrl'][index];
                                return document['assignmentsUrl'].isNotEmpty ?
                                 Padding(
                                  padding: const EdgeInsets.only(
                                      left: 6, right: 6, bottom: 10, top: 10),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    tileColor: Colors.white,
                                    title: Text(
                                      "${document['assignmentTopic']}",
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      "Submitted At: ${DateFormat('MMM-dd hh:mm a').format(data['submittedAt'].toDate())}",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                        fontSize: 13,
                                      ),
                                    ),
                                    trailing: FilledButton.tonal(
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                        document['assignmentDueDate'].toDate().isAfter(DateTime.now())
                                            ? AppColors.successColor
                                            : AppColors.errorColor,
                                        visualDensity: const VisualDensity(
                                            vertical: -1, horizontal: 3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                      onPressed: () async{
                                       await classViewModel.downloadFile(data['submittedAssignment'],context);
                                        log('message==> ${data['submittedAssignment']}');
                                      },
                                      child: const Icon(Icons.download_sharp),
                                    ),
                                  ),
                                ) :
                                const Center(
                                    child: Text("No assignments added yet",
                                      style: TextStyle(color: Colors.black),));
                              });
                            }).toList(),
                          );
                        }),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
