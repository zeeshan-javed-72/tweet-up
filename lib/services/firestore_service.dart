import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tweet_up/main.dart';
import 'package:tweet_up/services/token_model.dart';
import 'package:tweet_up/services/user_model.dart';
import '../util/utils.dart';

import 'message_model.dart';

class NotificationService {
  User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference _usersCollectionReference =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _messagesCollectionReference =
      FirebaseFirestore.instance.collection('messages');
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<List<MessagesModel>> _chatMessagesController =
      StreamController<List<MessagesModel>>.broadcast();

  Future createUser(UserModel user) async {
    try {
      await _usersCollectionReference.doc(user.id).set(user.toJson());
    } catch (e) {
      // TODO: Find or create a way to repeat error handling without so much repeated code
      if (e is PlatformException) {
        return e.message;
      }
      return e.toString();
    }
  }

  Future getUser(String uid) async {
    try {
      var userData = await _usersCollectionReference.doc(uid).get();

      return UserModel.fromData(userData.data() as Map<String, dynamic>);
    } catch (e) {
      // TODO: Find or create a way to repeat error handling without so much repeated code
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
    }
  }

  Future getAllUsersOnce(String currentUserUID) async {
    try {
      var usersDocumentSnapshot = await _usersCollectionReference.get();
      String? fcmToken = await _fcm.getToken();

      final tokenRef = _usersCollectionReference
          .doc(currentUserUID)
          .collection('tokens')
          .doc(fcmToken);
      await tokenRef.set(
        TokenModel(token: fcmToken, creditAt: FieldValue.serverTimestamp())
            .toJson(),
      );
      if (usersDocumentSnapshot.docs.isNotEmpty) {
        return usersDocumentSnapshot.docs
            .map((snapshot) =>
                UserModel.fromMap(snapshot.data() as Map<String, dynamic>))
            .where((mappedItem) => mappedItem?.id != currentUserUID)
            .toList();
      }
    } catch (e) {
      // TODO: Find or create a way to repeat error handling without so much repeated code
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
    }
  }

  Future createMessage(MessagesModel message) async {
    try {
      await _messagesCollectionReference.doc().set(message.toJson());
    } catch (e) {
      // TODO: Find or create a way to repeat error handling without so much repeated code
      if (e is PlatformException) {
        return e.message;
      }

      return e.toString();
    }
  }

  Stream listenToMessagesRealTime(String friendId, String currentUserId) {
    // Register the handler for when the posts data changes
    _requestMessages(friendId, currentUserId);
    return _chatMessagesController.stream;
  }

  void _requestMessages(String friendId, String currentUserId) {
    var messagesQuerySnapshot =
        _messagesCollectionReference.orderBy('createdAt', descending: true);

    messagesQuerySnapshot.snapshots().listen((messageSnapshot) {
      if (messageSnapshot.docs.isNotEmpty) {
        var messages = messageSnapshot.docs
            .map((snapshot) =>
                MessagesModel.fromMap(snapshot.data() as Map<String, dynamic>))
            .where((element) =>
                (element.receiverId == friendId &&
                    element.senderId == currentUserId) ||
                (element.receiverId == currentUserId &&
                    element.senderId == friendId))
            .toList();

        _chatMessagesController.add(messages);
      }
    });
  }

  static void requestPermission(context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings setting = await messaging.requestPermission(
      sound: true,
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      provisional: false,
      criticalAlert: false,
    );
    if (setting.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print("permission Granted.....................................");
      }
      // Utils.snackBar(message: "permission granted", context: context, color: Colors.green);
    } else {
      Utils.snackBar(
          message: "permission denied", context: context, color: Colors.red);
    }
  }

  saveToke(token) {
    _usersCollectionReference.doc(user?.email).set({
      "token": token,
    });
  }

  static initInfo(context) {
    var androidInitialize =
        const AndroidInitializationSettings("assets/images/appIcon.png");
    var iosInitialization = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iosInitialization,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: (payload) async {
      try {
        if (payload.payload != null && payload.payload!.isNotEmpty) {
        } else {}
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
        Utils.snackBar(
            message: e.toString(), context: context, color: Colors.red);
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) async {
      if (kDebugMode) {
        print('.................onMessaging...................');
        print(
            "onMessaging.....${remoteMessage.notification?.title}& ${remoteMessage.notification?.body}");
      }

      AndroidNotificationActionInput replyAction =
          const AndroidNotificationActionInput(
        label: 'Enter reply',
        // choices: ["Are you ready", "How are you", "HAHAHA"],
        allowFreeFormInput: true,
      );

      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        remoteMessage.notification!.body.toString(),
        htmlFormatBigText: true,
        contentTitle: remoteMessage.notification?.title.toString(),
        htmlFormatContentTitle: true,
      );
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        "tweet-up",
        "tweet-up",
        importance: Importance.max,
        styleInformation: bigTextStyleInformation,
        priority: Priority.max,
        playSound: true,
        setAsGroupSummary: true,
        enableVibration: true,
        icon: 'app_notification',
        groupKey: "tweet-up",
        groupAlertBehavior: GroupAlertBehavior.summary,
      );
      DarwinNotificationDetails iosNotificationDetails =
          const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: "tweet-up",
      );
      NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );
      await flutterLocalNotificationsPlugin.show(
        remoteMessage.hashCode,
        remoteMessage.notification?.title,
        remoteMessage.notification?.body,
        notificationDetails,
        payload: remoteMessage.data['body'],
      );
    });
  }

  static Future<void> sendPushNotification({title, body,required List<String> fcmToken,String? profile}) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                "key=AAAAQetlVCI:APA91bG60TAGfRbnVi1d5DdHL07C6U_2jssCurCZ5bhbPaBJkEQhD4h5kYggCsuYjeTZkI0ZQmudc4K1hwfO7lxvLrZVRaUWHTcdN_W5XzRanVAcSYuuFnC4LCwjmUbvdJVTnOyvDrK7",
          },
          body: jsonEncode(
            {
              'priority': 'high',
              'data': {
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'status': 'done',
                'type': 'personalChat',
                'body': body,
                'title': title,
                'photo': profile ?? 'https://firebasestorage.googleapis.com/v0/b/dring-389312.appspot.com/o/profile.png?alt=media&token=00636dbd-09fd-4d0a-ac29-6c86a2e0ff52',
              },
              "notification": {
                "title": title,
                "body": body,
                "android_channel_id": "tweet-up",
              },
              'registration_ids': fcmToken
            },
          ));
    } catch (e) {
      if (kDebugMode) {
        print('........ERORRRRRRRRRRRRRRRR${e.toString()}');
      }
      // Utils.snackBar(message: e.toString(), context: context, color: Colors.redAccent);
    }
  }


  static void init() async{
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    const initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: myBackgroundHandler,
      onDidReceiveNotificationResponse: myBackgroundHandler,
    );
  }
  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
  static void showChatNotifications(
      RemoteNotification remoteNotification, String profile) async {
    final String largeIconPath =
    await _downloadAndSaveFile(profile, 'largeIcon');
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'tweet-up',
      'tweet-up',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.message,
      setAsGroupSummary: true,
      groupAlertBehavior: GroupAlertBehavior.summary,
      icon: 'app_notification',
      enableLights: true,
      largeIcon: FilePathAndroidBitmap(largeIconPath),
    );

    DarwinNotificationDetails iOSNotificationDetails =
    const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'message.aiff',
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      remoteNotification.hashCode,
      remoteNotification.title,
      remoteNotification.body,
      notificationDetails,
    );
  }
}
