// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tweet_up/util/form_validator.dart';
import 'package:tweet_up/util/utils.dart';
import '../../../models/error.dart';
import '../../../services/database.dart';
import '../../../services/loading.dart';
import '../../../widgets/formFields.dart';

class JoinClass extends StatefulWidget {
  static const routeName = '/join-class';
  const JoinClass({super.key});
  @override
  _JoinClassState createState() => _JoinClassState();
}

class _JoinClassState extends State<JoinClass> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController rollNum = TextEditingController();

  final code = TextEditingController();
  bool exists = true;

  Future<void> checkExistence() async {
    var allClasses = FirebaseFirestore.instance.collection('classes');
    setState(() {
      _loading = true;
    });
    DocumentSnapshot data = await allClasses.doc(code.text).get();
    setState(() {
      _loading = false;
    });
    if (data.data() == null) {
      setState(() {
        exists = false;
        message = 'does not exist';
      });
      Utils.snackBar(
          message: "This class does not exist",
          context: context,
          color: Colors.redAccent);
    } else {
      setState(() {
        exists = true;
      });
      if (kDebugMode) {
        print('class exists');
      }
    }
  }

  final name = TextEditingController();
  String message = ' ';
  bool _loading = false;

  bool? _isValidInput;
  bool validateRollNumber(String input) {
    RegExp regex = RegExp(r'^[A-Z]{5}-\d{2}-\d{2}$');
    return regex.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    name.text = user.displayName ?? 'Noname';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Join a class',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.secondary),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    formField(
                      controller: rollNum,
                      title: 'Enter Roll No. (i.e: MCEIT-01-23)',
                      context: context,
                      validator: FormValidator.validateRollNumber,
                    ),
                    formField(
                        controller: code,
                        title: 'Enter code',
                        context: context,
                        validator: (value) {
                          if (value.toString().isEmpty) {
                            return 'Please enter class code';
                          }
                        }),
                    Text(message),
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            color: Theme.of(context).primaryColor,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await checkExistence();
                                if (exists) {
                                  setState(() {
                                    _loading = true;
                                  });
                                  await ClassDatabase.joinClass(
                                          rollNum.text, code.text, context)
                                      .then((value) {
                                    setState(() {
                                      _loading = false;
                                    });
                                    code.clear();
                                    rollNum.clear();
                                  });
                                }
                              }
                            },
                            child: _loading
                                ? Transform.scale(
                                    scale: 0.5,
                                    child: const CircularProgressIndicator
                                        .adaptive(
                                      backgroundColor: Colors.white,
                                    ))
                                : const Text(
                                    'Join the class',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Divider(),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28.0, vertical: 10),
              child: Text(
                'To sign in with a class code',
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28.0, vertical: 10),
              child: Text(
                '🌟🌟Ask your teacher for the class code and input above.',
                style: GoogleFonts.roboto(fontSize: 15),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28.0, vertical: 10),
              child: Text(
                '🌟🌟Make sure you have entered correct roll number, and entered real name during registration. Because you won\'t be able to join the same class using this account.',
                style: GoogleFonts.roboto(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
