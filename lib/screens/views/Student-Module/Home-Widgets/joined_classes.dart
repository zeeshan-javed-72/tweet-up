import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../submit_view_classwork.dart';

class JoinedClasses extends StatelessWidget {
  final DocumentSnapshot document;
  JoinedClasses({Key? key, required this.document, this.fistName})
      : super(key: key);
  final String? fistName;
  final Random random = Random();

  @override
  Widget build(BuildContext context) {
    final Color color = Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
    final String initial = document['subName'].substring(0, 1);

    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                allowSnapshotting: true,
                builder: (_) =>
                    SubmitClasswork(classData: document.data() as dynamic),
              ));
          // Navigator.of(context).pushNamed(
          //     SubjectClassStudent.routeName,
          //     arguments: document.data(),
          // );
        },
        visualDensity: const VisualDensity(horizontal: -4),
        contentPadding: EdgeInsets.zero,
        leading: Container(
          height: MediaQuery.of(context).size.height * 0.22,
          width: width * 0.22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color,
            border: Border.all(color: Colors.transparent),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 24, color: Colors.black87),
        title: Text(
          "${document['subName']}",
          style: const TextStyle(
              color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          'Class 3',
          style: TextStyle(
              color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
