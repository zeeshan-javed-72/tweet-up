import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tweet_up/Model-View_Classes/classes_view_model.dart';
import 'package:tweet_up/constants/appColors.dart';
import 'package:tweet_up/util/utils.dart';
import '../../../services/firebase_api.dart';
import '../Teacher-Module/upload_assignment.dart';

class Assignments extends StatefulWidget {
  final DocumentSnapshot? snapshot;
  final String? code;
  const Assignments({Key? key, this.snapshot, this.code}) : super(key: key);

  @override
  State<Assignments> createState() => _AssignmentsState();
}

class _AssignmentsState extends State<Assignments> {
  String? name;
  Duration? timeRemaining;
  bool isExpired = false;


  void calculateTimeRemaining() {
    final now = DateTime.now();
    if (now.isBefore(widget.snapshot?['assignmentDueDate'].toDate())) {
      setState(() {
        timeRemaining = widget.snapshot?['assignmentDueDate'].toDate().difference(now);
      });
    } else {
      timeRemaining = const Duration();
      isExpired = true;
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
    final classNotifier = Provider.of<ClassesViewModel>(context);
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
            "1",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(widget.snapshot?['assignmentTopic'],
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            )),
        subtitle: isExpired
            ? Text(
                "Expired",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            : CountdownTimer(
                duration: timeRemaining!,
              ),
        trailing: isExpired
            ?
        Padding(
                padding: EdgeInsets.only(right: 20 * w),
                child: Text(
                  "Expired",
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              )
            : widget.snapshot?['submittedByStudents'].contains(FirebaseAuth.instance.currentUser?.uid)?
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: TextButton(
            style: TextButton.styleFrom(
              visualDensity: const VisualDensity(horizontal: 2, vertical: -1),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: (){
              Utils.snackBar(message: "You already submitted your assignment",
                  context: context, color: AppColors.warningColor);
            },
            child: Text("Submitted",
              style: GoogleFonts.poppins(
              fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
            ),),
          ),
        )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      visualDensity:
                          const VisualDensity(horizontal: 2, vertical: -1),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () async {
                     await classNotifier.downloadFile(
                        widget.snapshot?['assignmentFile'],
                        context,
                        topicName: widget.snapshot?['assignmentTopic']
                      );
                    },
                    child: const Icon(Icons.download_for_offline,
                        color: Colors.white),
                  ),
                  PopupMenuButton(
                    padding: EdgeInsets.zero,
                      itemBuilder: (ctx) => [
                            PopupMenuItem(
                              padding: EdgeInsets.zero,
                              onTap: () {
                                print(widget.code);
                                Future.delayed(
                                    const Duration(microseconds: 0),
                                    () => Navigator.push(context,
                                        CupertinoPageRoute(builder: (_)=> UploadAssignment(
                                          page: true,
                                          code: widget.snapshot?.id,
                                          snapshot: widget.snapshot,
                                          classCode: widget.code,
                                        ))),
                                );
                              },
                              value: 1,
                              child: const Text("Submit assignment"),
                            )
                          ]),
                ],
              )
      ),
    );
  }
}

class CountdownTimer extends StatefulWidget {
  final Duration duration;
  final Function? onExpired;

  const CountdownTimer({super.key, required this.duration, this.onExpired});

  @override
  CountdownTimerState createState() => CountdownTimerState();
}

class CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _remainingTime = const Duration();

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds == 0) {
          _timer.cancel();
          if (widget.onExpired != null) {
            widget.onExpired!();
          }
        } else {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Time Left: ${_remainingTime.inDays.remainder(30)}d '
      '${_remainingTime.inHours.remainder(24)}h '
      '${_remainingTime.inMinutes.remainder(60)}m '
      '${_remainingTime.inSeconds.remainder(60)}s',
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
