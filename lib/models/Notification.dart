import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/src/env.dart' as tzEnv;

Future<void> showNotification() async {
  tz.initializeTimeZones();

  final androidNotificationDetails = AndroidNotificationDetails(
    'repeatDailyAtTime channel id',
    'repeatDailyAtTime channel name',
    'repeatDailyAtTime description',
  );
  final iOSNotificationDetails = IOSNotificationDetails();
  final platformChannelSpecifics = NotificationDetails(
    android: androidNotificationDetails,
    iOS: iOSNotificationDetails,
  );
  final flutterLocalNotificationsPlugin = await _createPlugin();
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    "It's a good time to train your words",
    "It's a good time to train your words",
    time(9),
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.wallClockTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

Future<FlutterLocalNotificationsPlugin> _createPlugin() async {
  WidgetsFlutterBinding.ensureInitialized();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final initializationSettingsAndroid =
      AndroidInitializationSettings('ic_stat_name');
  final initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
  return flutterLocalNotificationsPlugin;
}

Future<void> onDidReceiveLocalNotification(
        int id, String? title, String? body, String? payload) =>
    Future.value();

Future<void> selectNotification(String? payload) => Future.value();

tz.TZDateTime time(int hour, [int minutes=0, int seconds=0]) {
  final time = tz.TZDateTime.now(tzEnv.UTC);
  return tz.TZDateTime.utc(time.year, time.month, time.day, 9);
}
