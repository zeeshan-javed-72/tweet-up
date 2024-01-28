import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseApi{
  static User? auth = FirebaseAuth.instance.currentUser;
  static CollectionReference usersCollectionReference = FirebaseFirestore.instance.collection('users');
  static CollectionReference messagesCollectionReference = FirebaseFirestore.instance.collection('messages');
}