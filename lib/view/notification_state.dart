

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../main.dart';

class NoticationState {
  static void initNotification(BuildContext context) {
     
    FirebaseMessaging.instance.subscribeToTopic("all");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      
      if (notification != null && android != null) {
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            andChannle.id, andChannle.name, 
            importance: Importance.max,
            playSound: true,
            color: Colors.blue,
            showProgress: true,
            priority: Priority.high,
            ticker: 'cilac');

        var iOSChannelSpecifics = const IOSNotificationDetails();
        var platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);
        plugins.show(notification.hashCode, notification.title, notification.body, platformChannelSpecifics,
            payload: "${notification.title}|${notification.body}");
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
 
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title.toString()),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [Text(notification.body.toString())],
                  ),
                ),
              );
            });
      }
    });
  }
}
