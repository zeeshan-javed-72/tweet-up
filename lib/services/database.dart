import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tweet_up/util/utils.dart';
import '../models/error.dart';

class ClassDatabase {

  static CollectionReference teacherClass = FirebaseFirestore.instance.collection("classes");

  static Future createClassByTeacher({subjectName, batch, professorName, teacherId, err, code, assignments, emailId}) async{
  try{
   await teacherClass.doc(code).set({
      'profName': professorName,
      'subName': subjectName,
      'teacherId': teacherId,
      'batch': batch,
      'code': code,
      "emailId": emailId,
      "enrolledStudents": [],
      "enrolledStudentsId": [],
    });

  }catch(e){
    print(e.toString());
  }
  }

 static Future groupMessage(var code, String postedBy, post,senderName) async{
    var collName = FirebaseFirestore.instance.collection("classes");
    await collName.doc(code).collection('groupChat').doc().set({
      'postedBy': postedBy,
      'post': post,
      "senderName": senderName,
      'time': DateTime.now(),
      'status': 'unread',
    });
  }

  static Future nextClass({code, url, topics, date, time}) async {
    DateTime selectedTime = DateTime(2022, 1, 1, time.hour, time.minute);
    var collName = FirebaseFirestore.instance.collection("classes");
    await collName.doc(code).collection('upComingClasses').doc().set({
      'url': url,
      'topics': topics,
      'time': DateFormat('hh:mm a').format(selectedTime),
      'date': date.toString(),
      "nowDate": DateTime.now(),
    }).then((_) {
   print("scheduled successfully");
    }).catchError((err) {
     print(err.toString());
    });
  }

  static Future postNote(context,topic,urlFile, code) async {
    var collName = FirebaseFirestore.instance.collection("classes");
    await collName.doc(code).collection('notes').doc().set({
      'topic': topic,
      'url': urlFile,
      'time': DateTime.now(),
    });
  }

  static Future postAssignment({String? code, topicName, url, dueDate, page,assignmentCode}) async {
    var timeStamp = Timestamp.fromMillisecondsSinceEpoch(10000000000);
    var collName = FirebaseFirestore.instance.collection("classes");
    if(page == false) {
      await collName.doc(code).collection('assignments').doc().set({
      'assignmentTopic': topicName,
      'assignmentFile': url,
      'assignmentDueDate': dueDate,
        "submittedByStudents": [],
        "assignmentsUrl": [],
    });
    }else if(page == true){
      await collName.doc(code).collection('assignments').doc(assignmentCode).update({
        'assignmentsUrl': FieldValue.arrayUnion([{
          "submittedAssignment": url,
          "studentName": FirebaseAuth.instance.currentUser!.displayName,
        }]),
        "submittedByStudents": FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
      });
    }
  }

  static Future joinClass(var rollNumber, String code, context,{String? studentName,userImg}) async{

      var allClasses = FirebaseFirestore.instance.collection('classes');
      final classDoc = await allClasses.doc(code).get();
      final enrolledStudents = classDoc['enrolledStudents'] ?? [];
      final enrolledStudentsId = classDoc['enrolledStudentsId'] ?? [];
      final teacherId = classDoc['teacherId'];
      if(enrolledStudents.any((student) => student['studentId'] == FirebaseAuth.instance.currentUser!.uid)){
          Utils.snackBar(message: "You are already enrolled in this class",
              context: context, color: Colors.redAccent);
          return;
      }
      if (FirebaseAuth.instance.currentUser!.uid == teacherId) {
        Utils.snackBar(message: "Error: Teacher cannot enroll in their own class.",
            context: context, color: Colors.redAccent);
        return;
      }
      await enrolledStudents.add({
        'studentId': FirebaseAuth.instance.currentUser?.uid,
        'rollNo': rollNumber,
        'stdName': studentName,
        'stdImg': userImg,
      });
      await enrolledStudentsId.add(FirebaseAuth.instance.currentUser?.uid);
      await allClasses.doc(code).update({'enrolledStudents': enrolledStudents});
      await allClasses.doc(code).update({'enrolledStudentsId': enrolledStudentsId});
      Utils.snackBar(message: "Class joined successfully",
          context: context, color: Colors.redAccent);
  }

  final CollectionReference teacher;
  final String uid;
  File? file;

  ClassDatabase(this.uid, this.teacher);
  Future createClass(subjectName, batch, professorName, email, err, code) async {
    FirebaseFirestore.instance
        .collection('allClasses')
        .doc(code)
        .set({'exists': true});
    List<dynamic> studentList = [];
    return teacher.doc(code).set({
      'profName': professorName,
      'subName': subjectName,
      'email': email,
      'batch': batch,
      'code': code,
      'studentList': studentList
    }).then((value) async {
      final classCollection = FirebaseFirestore.instance.collection(code);
     await classCollection.doc('Announcements').set({});
      await  classCollection.doc('assignments').set({});
      await classCollection.doc('Upcoming classes').set({});
      await classCollection.doc('Name').set({'name': subjectName});
      if (kDebugMode) {
        print("User Added");
      }
      err.error = 'Class created';
    }).catchError((error) {
      err.error = "Failed to add user: $error";
    });
  }}

void deleteClass(code){
  FirebaseFirestore.instance.collection('${FirebaseAuth.instance.currentUser?.email}').doc(code).delete();
}

class JoinClassDataBase {
  String code, rollNum, studentName, email;
  var collName;
  ErrorMsg error;
  JoinClassDataBase(this.code, this.rollNum, this.collName, this.studentName,
      this.email, this.error);
  Future joinClass() async {
    if (code.contains(email)) {
      error.error = 'You know you are the teacher of this class. Right?. 🤣🤣';
    } else {
      var allClasses = FirebaseFirestore.instance.collection('allClasses');
      if (allClasses.doc(code).get() != null) {
        final teacher = FirebaseFirestore.instance.collection(collName);
        var val=[];
        final studentCollection =
            FirebaseFirestore.instance.collection('student $email');
        DocumentSnapshot classRoom = await teacher.doc(code).get();
        DocumentSnapshot myClasses = await studentCollection.doc(code).get();
        if (myClasses.data() != null) {
          error.error = 'Why are you trying to enroll twice? 😑🙄';
        } else {
          if (kDebugMode) {
            print(classRoom.data());
          }
          List<dynamic> studentList = classRoom['studentList'];
          String subjectName = classRoom['subName'];
          studentList.add({'studentName': studentName, 'rollNum': rollNum, 'email': email});
          teacher.doc(code).update({"studentList": studentList});
          teacher.doc(code).update({"studentList": FieldValue.arrayRemove(val)});
          if (kDebugMode) {
            print(studentList);
          }
          error.error = 'You\'ve successfully joined the class. 🌟🌟';
          return studentCollection
              .doc(code)
              .set({'code': code, 'Name': subjectName});
        }
      } else {
        if (kDebugMode) {
          print('does not exist');
        }
        error.error = 'Class does not exist';
      }
    }
  }
}

class ScheduleClass {
  var url, topics, code;
  var date;
  var time;

  ErrorMsg error =  ErrorMsg(' ');
  ScheduleClass(
      {this.date, this.time, this.topics, this.url, required this.error, this.code});
  Future scheduleClass() async {
    if (topics == '') topics = 'Unnamed topic';
    var classCollection = FirebaseFirestore.instance.collection(code);
    await classCollection
        .doc('Upcoming classes')
        .collection('Upcoming classes')
        .doc()
        .set({
      'url': url,
      'topics': topics,
      'time': time.toString(),
      'date': date.toString()
    }).then((_) {
      error.error = 'class created';
    }).catchError((err) {
      error.error = err.toString();
    });
  }
}

class MakeAnnouncement {
  var code;
  String postedBy, post,senderName;
  MakeAnnouncement(this.code, this.postedBy, this.post, this.senderName);
  Future makeAnnouncement() async {
    var collName = FirebaseFirestore.instance.collection(code);
    await collName.doc('Announcements').collection('announcements').doc().set({
      'postedBy': postedBy,
      'post': post,
      "senderName": senderName,
      'time': DateTime.now(),
    });
  }
}

class PostNotes {
  File? file;
  UploadTask? uploadTask;
  String code, topic;
  String urlFile;

  PostNotes(this.code, this.topic, this.urlFile);
  Future postNote(context) async {
    var collName = FirebaseFirestore.instance.collection(code);
    await collName.doc('Notes').collection('Notes').doc().set({
      'topic': topic,
      'url': urlFile,
      'time': DateTime.now(),
    });
  }
}


class PostAssignment {
  String? code, topicName, url, doc;
  DateTime? dueDate;

  PostAssignment({this.code, this.topicName, this.url, this.dueDate, this.doc});
  Future postNote() async {
    var timeStamp = Timestamp.now().millisecondsSinceEpoch;
    var collName = FirebaseFirestore.instance.collection(code!);
    await collName
        .doc('assignments')
        .collection('assignments')
        .doc(topicName!+timeStamp.toString())
        .set({
      'assignmentId': topicName!+timeStamp.toString(),
      'assignmentTopic': topicName,
      'assignmentFile': url,
      'assignmentDueDate': dueDate,
    });
  }


}
