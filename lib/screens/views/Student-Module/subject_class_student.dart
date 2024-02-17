import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SubjectClassStudent extends StatefulWidget {
  static const routeName = '/subject-class-student';
  final DocumentSnapshot? document;
  const SubjectClassStudent({super.key, this.document});
  @override
  _SubjectClassStudentState createState() => _SubjectClassStudentState();
}

class _SubjectClassStudentState extends State<SubjectClassStudent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "${widget.document?['subName']}",
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.secondary),
        backgroundColor: Colors.white,
      ),
    );
  }
}
