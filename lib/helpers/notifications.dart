import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sexual_health_assignment/utilities/utilities.dart';
// import 'package:sexual_health_assignment/models/models.dart';

class NotificationHelper {
  FirebaseMessaging _messaging = FirebaseMessaging.instance;
  Dialogs? _dialogs;
  // NotificationModel? _notificationInfo;

  NotificationHelper() {
    _notificationHandler();
    _dialogs = Dialogs.empty();
  }

  Future<void> _registerNotification() async {
    // On iOS, this helps to take the user permissions
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  onForegroundMessage(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        RemoteNotification notification = message.notification!;
        await _dialogs!.dialogInfo(
          context,
          notification.title,
          notification.body,
          'Cancel',
        );
      }
    });
  }

  onBackgroundMessage() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }

  // Future<dynamic> _onLaunch(Map<String, dynamic> message) async {
  //   print('onLaunch: $message');
  //   _notificationInfo = NotificationModel.fromJson(message);
  //   _notificationInfo.toString();
  // }

  // Future<dynamic> _onResume(Map<String, dynamic> message) async {
  //   print('onResume: $message');
  //   _notificationInfo = NotificationModel.fromJson(message);
  // }

  void _notificationHandler() async {
    await _registerNotification();
  }
}
