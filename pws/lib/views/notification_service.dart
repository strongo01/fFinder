import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

// Deze handler moet een top-level functie zijn (buiten een class).
// Het wordt aangeroepen wanneer een notificatie binnenkomt terwijl de app op de achtergrond of gesloten is.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.notification != null) {}
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Maak een Android Notification Channel aan voor voorgrondnotificaties.
  final AndroidNotificationChannel _androidChannel =
      const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description:
            'This channel is used for important notifications.', // description
        importance: Importance.high,
      );

  Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }
//Vraag permissie voor notificaties.
  await _firebaseMessaging.requestPermission();

  final dynamic currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));

  // Voor iOS: stel presentatie-opties in voor voorgrondnotificaties.
  await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true, // Toon een alert.
      badge: true, // Update de app-badge.
      sound: true, // Speel een geluid af.
    );

    // Initialiseer de local notifications plugin met iOS/Darwin instellingen.
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

    //Maak het Android channel aan.
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    // Stel de background en foreground message handlers in.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _setupForegroundMessageHandler();
  }

  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {}

      // Controleer op zowel Android als Apple notificatie details
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
    // Annuleer eerst alle bestaande meldingen om duplicaten te voorkomen.
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
    } else {}
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local); // Huidige tijd in lokale tijdzone
    tz.TZDateTime scheduledDate = tz.TZDateTime( // Geplande tijd vandaag
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Als de geplande tijd vandaag al voorbij is, plan het voor morgen.
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule( // Plan de notificatie
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_reminders_channel',
          'Maaltijdherinneringen',
          channelDescription: 'Dagelijkse herinneringen voor maaltijden.',
          importance: Importance.defaultImportance,
          priority: Priority.low,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: true,
          presentAlert: true,
          presentBadge: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // dagelijkse herhaling
    );
  }
}
