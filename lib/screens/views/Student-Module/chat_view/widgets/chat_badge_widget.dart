import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatBadgeWidget extends StatelessWidget {
  final String chatRoomId;
  const ChatBadgeWidget({super.key, required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: getUnreadMessageCountStream(chatRoomId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Text('');
        }
        final unreadCount = snapshot.data ?? 0;
        return unreadCount == 0
            ? const Badge(isLabelVisible: false)
            :  Container(
          width: 16,
          height: 16,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: Text('$unreadCount',style: const TextStyle(color: Colors.white)),
        );
      },
    );
  }

  Stream<int> getUnreadMessageCountStream(String chatRoomId) {
    final chatRoomRef =
    FirebaseFirestore.instance.collection('classes').doc(chatRoomId);
    return chatRoomRef.collection('groupChat').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.data()['postedBy'] != FirebaseAuth.instance.currentUser?.uid)
          .where((doc) => doc.data()['status'] == 'unread')
          .length;
    });
  }
}