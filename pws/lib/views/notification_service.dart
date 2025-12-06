import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.notification != null) {}
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _androidChannel =
      const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );

  Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    await _firebaseMessaging.requestPermission();

    // --- 1. TIJDZONE CORRECTIE ---
    try {
      // We halen eerst het object op
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      // Daarna pakken we de identifier (de String "Europe/Amsterdam")
      final String timeZoneName = timezoneInfo.identifier;

      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      print("Kon tijdzone niet ophalen: $e");
      // Fallback
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    // -----------------------------

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
        );

    await _localNotifications.initialize(initializationSettings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _setupForegroundMessageHandler();
  }

  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {}

      if (notification != null &&
          (message.notification?.android != null ||
              message.notification?.apple != null)) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      }
    });
  }

  Future<void> scheduleMealReminders({
    required bool areEnabled,
    required TimeOfDay breakfastTime,
    required TimeOfDay lunchTime,
    required TimeOfDay dinnerTime,
  }) async {
    if (kIsWeb) {
      return;
    }

    await _localNotifications.cancelAll();

    if (areEnabled) {
      await _scheduleDailyNotification(
        id: 1,
        title: 'Tijd voor ontbijt!',
        body:
            'Start je dag goed met een voedzaam ontbijt. Vergeet je niet je ontbijt te loggen?',
        time: breakfastTime,
      );
      await _scheduleDailyNotification(
        id: 2,
        title: 'Lunchtijd!',
        body:
            'Tijd om je energie aan te vullen voor de middag en vergeet je niet je lunch te loggen?',
        time: lunchTime,
      );
      await _scheduleDailyNotification(
        id: 3,
        title: 'Eet smakelijk!',
        body: 'Geniet van je avondeten en natuurlijk ook het loggen ervan!',
        time: dinnerTime,
      );
    }
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_reminders_channel',
          'Maaltijdherinneringen',
          channelDescription: 'Dagelijkse herinneringen voor maaltijden.',
          importance: Importance.high,
          priority: Priority.high,
        ),

        iOS: DarwinNotificationDetails(
          presentSound: true,
          presentAlert: true,
          presentBadge: true,
        ),
      ),
      // --- 2. SCHEDULE MODE CORRECTIE ---
      // We gebruiken 'inexact' om crashes te voorkomen op jouw Android versie
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
