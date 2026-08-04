import 'dart:io';

import 'package:Notich/helpers/notification_initilizer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeTimezone() async {
    tz.initializeTimeZones();
    final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
  }

  Future<bool> verifyNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
    }

    bool exactAlarmGranted = false;
    bool nAlarmGranted = false;

    if (Platform.isAndroid) {
      final androidPlugin = plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      final bool? hasPermission = await androidPlugin
          ?.requestExactAlarmsPermission();
      exactAlarmGranted = hasPermission ?? false;

      final bool? nPermission = await androidPlugin
          ?.requestNotificationsPermission();
      nAlarmGranted = nPermission ?? false;
    } else if (Platform.isIOS) {
      final iosPlugin = plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      exactAlarmGranted = true;

      final bool? nPermission = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      nAlarmGranted = nPermission ?? false;
    }

    var schStatus = await Permission.scheduleExactAlarm.status;
    if (!schStatus.isGranted) {
      schStatus = await Permission.scheduleExactAlarm.request();
    }

    return status.isGranted &&
        exactAlarmGranted &&
        schStatus.isGranted &&
        nAlarmGranted;
  }

  Future<void> requestionNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
    }

    if (Platform.isAndroid) {
      final androidPlugin = plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestExactAlarmsPermission();
      await androidPlugin?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      final iosPlugin = plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<bool> notificationExists(int id) async {
    final pending = await plugin.pendingNotificationRequests();
    return pending.any((notification) => notification.id == id);
  }

  Future<void> init() async {
    await initializeTimezone();
    await plugin.initialize(
      settings: await initializeLocalSettings(),
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> cancelTodoAlarm(int id) async {
    await plugin.cancel(id: id);
  }

  Future<void> scheduleTodoAlarm({
    required int id,
    required String title,
    required DateTime time,
    bool bypassShield = false,
    String? backgroundTimezone,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'todo_reminder_channel',
        'Todo Reminder',
        channelDescription: 'Notifications for your scheduled todo task.',
        importance: Importance.max,
        priority: Priority.high,

        // playSound: true,
        // enableVibration: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.critical,
        sound: 'default',
      ),
    );

    final location = backgroundTimezone != null
        ? tz.getLocation(backgroundTimezone)
        : tz.local;

    final scheduledDate = tz.TZDateTime.from(time, location);

    if (scheduledDate.isBefore(tz.TZDateTime.now(location))) {
      return;
    }

    return await plugin.zonedSchedule(
      id: id,
      title: title,
      body: "Schedule for ${DateFormat('hh:mm a').format(time)}",
      payload: title,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
