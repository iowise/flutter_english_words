import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/src/env.dart' as tzEnv;

Future<void> showNotification() async {
  tz.initializeTimeZones();
  final _timezone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(_timezone));

  final androidNotificationDetails = AndroidNotificationDetails(
    'repeatDailyAtTime channel id',
    'repeatDailyAtTime channel name',
    channelDescription: 'repeatDailyAtTime description',
  );
  final iOSNotificationDetails = DarwinNotificationDetails();
  final platformChannelSpecifics = NotificationDetails(
    android: androidNotificationDetails,
    iOS: iOSNotificationDetails,
  );
  final flutterLocalNotificationsPlugin = await _createPlugin();
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    "It's a good time to train your words",
    "It's a good time to train your words",
    time(7),
    platformChannelSpecifics,
    androidScheduleMode: AndroidScheduleMode.alarmClock,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

Future<FlutterLocalNotificationsPlugin> _createPlugin() async {
  WidgetsFlutterBinding.ensureInitialized();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final initializationSettingsAndroid =
      AndroidInitializationSettings('ic_stat_name');
  final initializationSettingsIOS = DarwinInitializationSettings();
  final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  return flutterLocalNotificationsPlugin;
}

tz.TZDateTime time(int hour, [int minutes=0, int seconds=0]) {
  final time = tz.TZDateTime.now(tzEnv.local);
  return tz.TZDateTime.local(time.year, time.month, time.day, 9);
}
