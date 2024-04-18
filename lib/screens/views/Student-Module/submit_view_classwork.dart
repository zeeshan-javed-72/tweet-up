import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tweet_up/Model-View_Classes/classes_view_model.dart';
import 'package:tweet_up/constants/appColors.dart';
import 'package:tweet_up/util/utils.dart';
import 'package:tweet_up/widgets/custom_shimmer.dart';
import 'assignments.dart';
import 'package:url_launcher/url_launcher.dart';

class SubmitClasswork extends StatefulWidget {
  final Map<dynamic, dynamic>? classData;
  const SubmitClasswork({
    Key? key,
    this.classData,
  }) : super(key: key);

  @override
  SubmitClassworkState createState() => SubmitClassworkState();
}

class SubmitClassworkState extends State<SubmitClasswork>
    with SingleTickerProviderStateMixin {
  bool isDownloading = false;
  late TabController _tabController;
  var currentId = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final classNotifier = Provider.of<ClassesViewModel>(context);
    var height =
        MediaQuery.of(context).size.height - AppBar().preferredSize.height;
    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.classData?['subName']}'),
          centerTitle: true,
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
                text: "Upcoming",
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("classes")
                    .doc(widget.classData?['code'])
                    .collection('notes')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("You don't have any notes to download"));
                  }
                  return ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    children: snapshot.data!.docs
                        .map((document) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    document['topic'] ?? 'Loading',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                    ),
                                    child: const Text('Download Notes'),
                                    onPressed: () async {
                                      await classNotifier.downloadFile(
                                          document['url'], context,
                                          topicName: document['topic']);
                                    },
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
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("classes")
                    .doc(widget.classData?['code'])
                    .collection('assignments')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("You don't have any assigned work"));
                  }
                  return ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    children: snapshot.data!.docs
                        .map((e) {
                          return Assignments(
                            snapshot: e,
                            code: widget.classData?['code'],
                          );
                        })
                        .toList()
                        .cast(),
                  );
                }),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("classes")
                  .doc(widget.classData?['code'])
                  .collection('upComingClasses')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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

                var classList = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: classList.length,
                  itemBuilder: (context, index) {
                    var classData = classList[index];
                    return UpcommingClassesCard(snapshot: classData);
                  },
                );
              },
            ),
          ],
        ));
  }
}

class UpcommingClassesCard extends StatefulWidget {
  final QueryDocumentSnapshot<Object?>? snapshot;

  const UpcommingClassesCard({super.key, this.snapshot});

  @override
  State<UpcommingClassesCard> createState() => _UpcommingClassesCardState();
}

class _UpcommingClassesCardState extends State<UpcommingClassesCard> {
  String? name;
  Duration? timeRemaining;
  bool isReady = false;

  void calculateTimeRemaining() {
    final now = DateTime.now();
    if (now.isBefore(widget.snapshot?['nowDate'].toDate())) {
      setState(() {
        timeRemaining = widget.snapshot?['nowDate'].toDate().difference(now);
      });
    } else {
      timeRemaining = const Duration();
      isReady = true;
    }
  }

  @override
  void initState() {
    calculateTimeRemaining();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height / 812;
    final w = MediaQuery.of(context).size.width / 375;
    return Padding(
      padding: EdgeInsets.only(top: 10 * h),
      child: ListTile(
          visualDensity: const VisualDensity(horizontal: -4),
          contentPadding: EdgeInsets.zero,
          tileColor: Colors.white,
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          leading: TextButton(
            onPressed: null,
            style: TextButton.styleFrom(
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              padding: EdgeInsets.zero,
              elevation: 0,
            ),
            child: const Text(
              '1',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(widget.snapshot?['topics'],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              )),
          subtitle: isReady
              ? Text(
                  "Expired",
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                )
              : CountdownTimer(
                  duration: timeRemaining!,
                ),
          trailing: isReady
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      visualDensity:
                          const VisualDensity(horizontal: 2, vertical: -1),
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: null,
                    child: const Text('Expired'),
                  ))
              : Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      visualDensity:
                          const VisualDensity(horizontal: 2, vertical: -1),
                      backgroundColor: const Color(0xff0956B5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      // Utils.snackBar(
                      //     message: "Class is not started by the host yet",
                      //     context: context,
                      //     color: AppColors.warningColor);
                      _launchZoomMeeting();
                    },
                    child: Text(
                      "Join Now",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )),
    );
  }

  _launchZoomMeeting() async {
    String meetingUrl = 'https://zoom.us/join';

    if (await launch(meetingUrl)) {
      await launch(meetingUrl).then((value) {});
    } else {
      throw 'Could not launch $meetingUrl';
    }
  }
}
