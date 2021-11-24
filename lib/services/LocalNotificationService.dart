


import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:niovar/src/Home.dart';
import '../Global.dart' as  session;


class LocalNotificationService {
static final  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

static void initialize(BuildContext context){
  final InitializationSettings initializationSettings =
      InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher")
      );
_flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String? route) async{
  session.date_debut=route!;
Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => Home()
      ),
      ModalRoute.withName("/Home")
  );
});
}

static void display(RemoteMessage message) async {
  try{
    Random random = new Random();
    final int id = random.nextInt(100);
    final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "niovarchannel",
          "niovarchannel channel",
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        )
    );
    await _flutterLocalNotificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
      payload:message.data['date_debut'].toString()
    );

  }on Exception catch(e){
    print(e);
  }



}

}