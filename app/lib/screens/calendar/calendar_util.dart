import 'dart:async';
import 'dart:io';

import 'package:core/core_dependencies.dart';
import 'package:core/util/date.dart';
import 'package:core/util/routing/router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kmpo_invent/screens/invent/select_objects_invent_screen.dart';
import 'package:kmpo_invent/utils/util.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract class CalendarUtil {
  static final storage = StorageListDynamic.create('CalendarUtil_calendar');

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const channelId = '1';
  static const channelName = 'localNotificationsChannel';

  static const AndroidNotificationDetails _androidNotificationDetails =
      AndroidNotificationDetails(channelId, channelName,
          channelDescription:
              'This channel is responsible for all the local notifications',
          importance: Importance.max,
          priority: Priority.high);

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: _androidNotificationDetails,
  );

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    tz.initializeTimeZones();

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
    );

    final notificationAppLaunchDetails = await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      await _onDidReceiveNotificationResponse(
          notificationAppLaunchDetails!.notificationResponse!);
    }

    await scheduleAll();
  }

  static Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final res = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return res ?? false;
    }

    return false;
  }

  static Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse response) async {
    Future.delayed(const Duration(milliseconds: 300), () async {
      if (await ParseUser.currentUser() == null) {
        return;
      }
      final event = DynamicModel.parseOrNull(response.payload!);
      if (event != null) {
        unawaited(SRRouter.push(
            SRRouter.mainNavigatorKey.currentContext!,
            SelectObjectsInventScreen(
              names: event.stringListOpt('comission') ?? [],
              mols: event.stringListOpt('mols') ?? [],
            )));
      }
    });
  }

  static Future<void> scheduleAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    final events = await storage.read() ?? [];

    if (events.isEmpty) {
      return;
    }

    if (!await _requestPermissions()) {
      return;
    }

    for (final event in events) {
      final date = event.stringOpt('date');
      final comission = event.stringListOpt('comission');
      final mols = event.stringListOpt('mols');

      if (date == null || comission == null || mols == null) {
        continue;
      }

      final eventDate = DateFormatUtil.dateFromStr(date);

      if (eventDate == null || eventDate.isBefore(DateTime.now())) {
        continue;
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        event.intOpt("id") ?? AppUtil.randomInt(),
        'Инвентаризация',
        'Комиссия: ${comission.join(', ')}, МОЛы: ${mols.join(', ')}',
        tz.TZDateTime.from(eventDate, tz.local),
        _notificationDetails,
        payload: event.toString(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      final reminderDate = eventDate.subtract(const Duration(days: 3));

      if (reminderDate.isAfter(DateTime.now())) {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          AppUtil.randomInt(),
          'Инвентаризация через 3 дня',
          'Комиссия: ${comission.join(', ')}, МОЛы: ${mols.join(', ')}',
          tz.TZDateTime.from(reminderDate, tz.local),
          _notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }
}

void _notificationTapBackground(NotificationResponse details) {
  //logger.d('_notificationTapBackground $details');
}
