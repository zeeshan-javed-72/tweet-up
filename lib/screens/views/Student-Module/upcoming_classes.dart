import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tweet_up/screens/views/Student-Module/scheduled_classes.dart';
import 'package:tweet_up/services/database.dart';
import 'package:tweet_up/services/firestore_service.dart';
import 'package:tweet_up/util/utils.dart';
import '../../../widgets/formFields.dart';

class UpcomingClasses extends StatefulWidget {
  final Map<dynamic, dynamic> classData;
  const UpcomingClasses(this.classData, {super.key});

  @override
  _UpcomingClassesState createState() => _UpcomingClassesState();
}

class _UpcomingClassesState extends State<UpcomingClasses> {
  String msg = 'Schedule a class.';
  String? subCollName;
  bool _loading = false;
  List<String> fcmTokens = [];
  void getUserData() {
    fcmTokens.clear();
    FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc.exists) {
          if (mounted) {
            setState(() => fcmTokens.add(doc['token'] ?? ''));
          }
          log('tokens ===> ${fcmTokens}');
        }
      }
    });
  }

  DateTime selectedDate = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  TimeOfDay _time = TimeOfDay.now();
  Future<void> selectTime(context) async {
    _time = TimeOfDay.now();
    TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: _time);
    setState(() {
      _time = picked!;
    });
  }

  final url = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final topics = TextEditingController();
  String mToken = 'ok';
  NotificationService firestoreService = NotificationService();
  void getToken() async {}

  @override
  void initState() {
    super.initState();
    getToken();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
            children: [
              Text(
                msg,
                style: GoogleFonts.questrial(
                  fontSize: 15.0,
                  color: Colors.black,
                  wordSpacing: 2.5,
                ),
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      formField(
                          controller: url,
                          title: 'Meeting url',
                          validator: (value) {
                            if (value.toString().isEmpty) {
                              return 'Please enter meeting url';
                            }
                          },
                          context: context),
                      formField(
                          controller: topics,
                          title: 'Lecture topic',
                          validator: (value) {
                            if (value.toString().isEmpty) {
                              return 'Please enter lecture topic';
                            }
                          },
                          context: context),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextButton(
                          onPressed: () => _selectDate(context),
                          child: Text(
                            'Selected date ${"${selectedDate.toLocal()}".split(' ')[0]}',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextButton(
                          onPressed: () => selectTime(context),
                          child: Text(_time == null
                              ? 'Selected time'
                              : 'Selected time${_time.format(context)}'),
                        ),
                      ),
                      Builder(builder: (context) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => _loading = true);
                                    log('form is validate====> ');
                                    subCollName = topics.text;
                                    await ClassDatabase.nextClass(
                                        code: widget.classData['code'],
                                        url: url.text,
                                        topics: topics.text,
                                        date: selectedDate,
                                        time: _time);
                                    await NotificationService
                                        .sendPushNotification(
                                      title: url.text.toString(),
                                      body: topics.text.toString(),
                                      fcmToken: fcmTokens,
                                    );
                                    setState(() => _loading = false);
                                    setState(() {
                                      url.clear();
                                      topics.clear();
                                      _loading = false;
                                    });
                                  } else {
                                    Utils.snackBar(
                                        message:
                                            "scheduled class cant be empty",
                                        context: context,
                                        color: Colors.redAccent);
                                  }
                                },
                                child: _loading
                                    ? Transform.scale(
                                        scale: 0.5,
                                        child: const CircularProgressIndicator
                                            .adaptive(
                                            backgroundColor: Colors.white))
                                    : const Text(
                                        'Schedule class',
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                            ),
                          ],
                        );
                      }),
                      Builder(builder: (context) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ScheduledClasses(
                                            widget.classData, subCollName)),
                                  );
                                },
                                child: const Text(
                                  'View scheduled classes',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
