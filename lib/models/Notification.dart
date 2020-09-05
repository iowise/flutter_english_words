import 'package:flutter_local_notifications/flutter_local_notifications.dart';

showNotification() async {
  var time = Time(9, 0, 0);
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'repeatDailyAtTime channel id',
      'repeatDailyAtTime channel name',
      'repeatDailyAtTime description');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  final flutterLocalNotificationsPlugin = await _createPlugin();
  await flutterLocalNotificationsPlugin.showDailyAtTime(
      0,
      "It's a good time to train your words",
      "It's a good time to train your words",
      time,
      platformChannelSpecifics);
}

Future<FlutterLocalNotificationsPlugin> _createPlugin() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
  return flutterLocalNotificationsPlugin;
}

Future onDidReceiveLocalNotification(int id, String title, String body, String payload) {
}

Future selectNotification(String payload) {
}
