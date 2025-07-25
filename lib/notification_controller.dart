import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wordini/main.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

Future<void> initializeNotifications() async {
  // Settings for Android
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // Settings for iOS
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // Initialize settings for both platforms
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  // Initialize the plugin
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap
      debugPrint('Notification clicked: ${response.payload}');
      if ((response.payload?.split('-') ?? []).length == 2) {
        if (response.payload!.split('-')[0] == 'wordReminder') {
          String word = response.payload!.split('-')[1];
          debugPrint('Word: $word');
          // TODO impliment reroute to word test page, needs rewrite of how the test page works
        }
      } else if (response.payload == 'wordReminder') {
        navigatorKey.currentState?.pushNamed(
          '/testing', // Your route name
          // arguments: word,
        );      
      }
    },
  );
}

void scheduleQuizNotification() async{
  final currentNotifs = await Hive.openBox<int>('active-notifications');
  if (currentNotifs.containsKey('wordReminder')) {
    debugPrint('Notification already scheduled for word reminder.');
    return; // Exit if notification is already scheduled
  }
  scheduleNotification(
    title: 'DO YOUR QUIZZES', 
    description: 'Your words are waiting for you.', 
    duration: Duration(days: 1), 
    androidPlatformChannelSpecifics: NotificationType.wordReminder.details, 
    payload: 'wordReminder',
  );
}

Future<void> showInstantNotification({
  required String title,
  required String description,
  required AndroidNotificationDetails androidPlatformChannelSpecifics,
  required String payload,
}) async {
  await requestNotificationPermission();

  NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  int id = await NotificationIdManager.getNextId();

  await flutterLocalNotificationsPlugin.show( // !here
    id, // Notification ID
    title, // Notification title
    description, // Notification body
    platformChannelSpecifics,
    payload: payload, // Data payload
  );
}

Future<void> scheduleNotification(
  {
    required String title,
    required String description,
    required Duration duration, 
    required AndroidNotificationDetails androidPlatformChannelSpecifics,
    required String payload,
    bool exact = false,
  }
  ) async {
  await requestNotificationPermission();
  // const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //     AndroidNotificationDetails(
  //   'your_scheduled_channel_id',
  //   'your_scheduled_channel_name',
  //   channelDescription: 'your_scheduled_channel_description',
  //   importance: Importance.max,
  //   priority: Priority.high,
  // );

  NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  int id = await NotificationIdManager.getNextId();
  AndroidScheduleMode scheduleMode = exact ? AndroidScheduleMode.exact : AndroidScheduleMode.inexactAllowWhileIdle;
  // Schedule notification 20 minutes from now
  await flutterLocalNotificationsPlugin.zonedSchedule(
    id, // Notification ID (different from instant notification)
    title,
    description,
    tz.TZDateTime.now(tz.local).add(duration),
    platformChannelSpecifics,
    androidScheduleMode: scheduleMode,
    payload: payload,
  );
  noteNotification(id, payload);
  debugPrint('Scheduled notification with ID: $id for $payload at $duration');
}

Future<void> noteNotification(int id, String payload) async {
  // Open the box if not already open
  Hive.openBox<int>('active-notifications');
  var box = await Hive.openBox<int>('active-notifications');
  await box.put(payload, id);
}

void removeNotif(String key) async {
  // Ensure the box is open before accessing it
  if (!Hive.isBoxOpen('active-notifications')) {
    await Hive.openBox<int>('active-notifications');
  }
  var box = Hive.box<int>('active-notifications');
  int? id = box.get(key);
  if (id != null) {
    flutterLocalNotificationsPlugin.cancel(id);
    box.delete(key);
  }
  debugPrint('Notification with ID: $id removed for word: $key');
}

Future<void> requestNotificationPermission() async {
  final androidImplementation = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  if (androidImplementation != null) {
    final bool? granted = await androidImplementation.requestExactAlarmsPermission();
    debugPrint('Notification permission granted: $granted');
  }
}

class NotificationType {
  final String id;
  final AndroidNotificationDetails details;

  const NotificationType._(this.id, this.details);

  static const NotificationType wordReminder = NotificationType._(
    'wordReminder',
    AndroidNotificationDetails(
      'Definition_Reminders_id',
      'Definition Reminders',
      channelDescription: 'mydescription',
      importance: Importance.max,
      priority: Priority.high,
    ),
  );
}


class NotificationIdManager {
  static const String _key = 'notification_id_counter';

  /// Get the next available notification ID
  static Future<int> getNextId() async {
    final prefs = await SharedPreferences.getInstance();
    int currentId = prefs.getInt(_key) ?? 0;
    int nextId = currentId + 1;
    await prefs.setInt(_key, nextId);
    return nextId;
  }

  /// Optionally reset the counter
  static Future<void> resetCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, 0);
  }
}
