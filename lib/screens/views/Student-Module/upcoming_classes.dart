import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tweet_up/screens/views/Student-Module/Home-Widgets/my_classes.dart';
import 'package:tweet_up/screens/views/Student-Module/scheduled_classes.dart';
import 'package:tweet_up/services/database.dart';
import 'package:tweet_up/services/firestore_service.dart';
import 'package:tweet_up/util/utils.dart';
import '../../../models/error.dart';
import '../../../services/loading.dart';
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

  Future<Null> selectTime(context) async {
    _time = TimeOfDay.now();
    TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: _time);

    setState(() {
      _time = picked!;
    });
    if (kDebugMode) {
      print(_time);
    }
  }

  final url = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final topics = TextEditingController();
  String mToken = 'ok';
  FirestoreService firestoreService = FirestoreService();
  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      if (token!.isNotEmpty) {
        setState(() {
          mToken = token;
          firestoreService.saveToke(token);
          if (kDebugMode) {
            print("my Device Toke$token");
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    FirestoreService.requestPermission(context);
    FirestoreService.initInfo(context);
    getToken();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(mToken);
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.classData['subName'].toString(),
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.secondary),
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
                                context: context),
                            formField(
                                controller: topics,
                                title: 'Lecture topic',
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
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          _loading = true;
                                        });
                                        if (_formKey.currentState!.validate()) {
                                          subCollName = topics.text;
                                          await ClassDatabase.nextClass(
                                            widget.classData['code'],
                                            url.text,
                                            topics.text,
                                            _time.toString(),
                                            selectedDate.toLocal(),
                                          );
                                          DocumentSnapshot snapshot =
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(FirebaseAuth.instance.currentUser?.email)
                                                  .get();
                                          String token = snapshot['token'];
                                         await FirestoreService.sendPushNotification(
                                            title: url.text.toString(),
                                            body: topics.text.toString(),
                                            token: token,
                                          );
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
                                      child: const Text(
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
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ScheduledClasses(
                                                      widget.classData,
                                                      subCollName)),
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