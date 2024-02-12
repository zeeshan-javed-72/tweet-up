import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tweet_up/constants/appColors.dart';
import 'package:tweet_up/widgets/flush_bar.dart';
import 'package:tweet_up/widgets/formFields.dart';
import '../../../models/error.dart';
import 'package:provider/provider.dart';
import '../../../constants/constants.dart';
import '../../../services/database.dart';
import '../../../services/loading.dart';
import '../Student-Module/created_classes.dart';

class CreateClass extends StatefulWidget {
  static const routeName = '/create-class';
  const CreateClass({super.key});
  @override
  _CreateClassState createState() => _CreateClassState();
}

class _CreateClassState extends State<CreateClass> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final subjectName = TextEditingController();

  final professorName = TextEditingController();

  final batch = TextEditingController();
  String code = '';
  bool _loading = false, created = false;
  String msg = ' ';
  ErrorMsg err = ErrorMsg(' ');

  String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = math.Random.secure();
    return String.fromCharCodes(Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ));
  }

  String randomString = "";

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    String? coll = user.email;
    final CollectionReference myClassCollection = FirebaseFirestore.instance.collection(coll!);
    final db = ClassDatabase(user.uid, myClassCollection);
    return _loading
        ? Loader()
        : Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: Theme.of(context).primaryColor,
              centerTitle: true,
              title: const Text(
                'Create class',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          formField(
                            controller: subjectName,
                            title: 'Name of subject',
                            context: context,
                          ),
                          const SizedBox(
                            height: 10
                          ),
                          formField(
                              controller: professorName,
                              title: 'Name of professor',
                              context: context),
                          const SizedBox(
                            height: 10
                          ),
                          formField(
                            controller: batch,
                            title: 'Semester/class',
                            context: context
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              msg,
                              style: GoogleFonts.roboto(fontSize: 15),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(20),
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              shadowColor:
                                  Theme.of(context).colorScheme.secondary,
                              color: Theme.of(context).colorScheme.secondary,
                              child: Builder(builder: (context) {
                                return TextButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        randomString = generateRandomString(16);
                                        _loading = true;
                                      });
                                      await ClassDatabase.createClassByTeacher(
                                        professorName: professorName.text,
                                        subjectName: subjectName.text,
                                        teacherId: FirebaseAuth.instance.currentUser?.uid,
                                        batch: batch.text,
                                        code: randomString,
                                        emailId: FirebaseAuth.instance.currentUser?.email,
                                      );
                                      setState(() {
                                        _loading = false;
                                        created = true;
                                        code = user.email! +
                                            subjectName.text +
                                            batch.text;
                                        msg = '${err.error}🌟🌟';
                                      });
                                      subjectName.text = '';
                                      batch.text = '';
                                      professorName.text = '';
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      'Create class',
                                      style: kTitleStyle,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          CopyCode(
                            created: created,
                            code: randomString,
                          ),
                          Container(
                            padding: const EdgeInsets.all(20),
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Material(
                              borderRadius: BorderRadius.circular(20.0),
                              shadowColor: Theme.of(context).primaryColor,
                              color: Theme.of(context).primaryColor,
                              child: Builder(builder: (context) {
                                return TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                        CreatedClasses.routeName,
                                        arguments: user.email);
                                  },
                                  child: Center(
                                    child: Text(
                                      'View all your classes',
                                      style: kTitleStyle,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class CopyCode extends StatelessWidget {
  CopyCode({super.key,
    required this.created,
    required this.code,
  });

  final bool created;
  final String? code;
  final Utils _utils = Utils();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          const Text(
              'Copy the following code and send to your students, so they can join your class'),
          TextButton(
            onPressed: created
                ? () async {
                    ClipboardData data = ClipboardData(text: (code!));
                    await Clipboard.setData(data);
                    Utils.flushBarErrorMessage('code copied', context, AppColors.warningColor);
                  }
                : null,
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}
