import 'package:fFinder/l10n/app_localizations.dart';
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
        description: 'Dagelijkse herinneringen voor maaltijden.',
        importance: Importance.high,
      );

  final AndroidNotificationChannel _mealChannel =
      const AndroidNotificationChannel(
        'meal_reminders_channel_v2',
        'Maaltijdherinneringen',
        description: 'Dagelijkse herinneringen voor maaltijden.',
        importance: Importance.high,
        playSound: true,
      );

  Future<void> initialize() async {
    debugPrint('NotificationService: initialize() gestart');
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
      debugPrint('NotificationService: Tijdzone ingesteld op $timeZoneName');
    } catch (e) {
      debugPrint("Kon tijdzone niet ophalen: $e");
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
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
        );

    await _localNotifications.initialize(initializationSettings);

    // Haal de Android implementatie op
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // Maak beide kanalen expliciet aan
    await androidImplementation?.createNotificationChannel(_androidChannel);
    await androidImplementation?.createNotificationChannel(_mealChannel);

    // Expliciet permissie vragen voor lokale notificaties (Android 13+)
    await androidImplementation?.requestNotificationsPermission();
    //await androidImplementation?.requestExactAlarmsPermission();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _setupForegroundMessageHandler();
    debugPrint('NotificationService: initialize() voltooid');
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
              icon: '@mipmap/launcher_icon',
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

  Future<void> _maybeAskExactAlarmsPermission(BuildContext context) async {
    if (kIsWeb) return;

    final androidImpl = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImpl == null) return;

    // Toon korte uitleg aan de gebruiker
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title:  Text(AppLocalizations.of(context)!
              .exactAlarmsTitle),
          content:  Text(
            AppLocalizations.of(context)!
                .exactAlarmsMessage,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child:  Text(AppLocalizations.of(context)!
                  .exactAlarmsNotNow),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child:  Text(AppLocalizations.of(context)!
                  .exactAlarmsOpenSettings),
            ),
          ],
        );
      },
    );

    if (shouldOpen == true) {
      try {
        await androidImpl.requestExactAlarmsPermission();
        debugPrint('NotificationService: Exact alarms permission requested');
      } catch (e) {
        debugPrint(
          'NotificationService: Fout bij requestExactAlarmsPermission: $e',
        );
      }
    } else {
      debugPrint(
        'NotificationService: Gebruiker weigerde exact alarms settings te openen',
      );
    }
  }

  Future<void> scheduleMealReminders({
    required BuildContext context,
    required bool areEnabled,
    required TimeOfDay breakfastTime,
    required TimeOfDay lunchTime,
    required TimeOfDay dinnerTime,
  }) async {
    debugPrint(
      'NotificationService: scheduleMealReminders aangeroepen. Enabled: $areEnabled',
    );
    if (kIsWeb) {
      return;
    }

    await _localNotifications.cancelAll();
    debugPrint('NotificationService: Alle oude notificaties geannuleerd');

    if (areEnabled) {
      await _maybeAskExactAlarmsPermission(context);

      debugPrint(
        'NotificationService: Tijden instellen - Ontbijt: $breakfastTime, Lunch: $lunchTime, Diner: $dinnerTime',
      );
      final loc = AppLocalizations.of(context)!;
      final breakfastTitle = loc.notificationBreakfastTitle;
      final breakfastBody = loc.notificationBreakfastBody;
      final lunchTitle = loc.notificationLunchTitle;
      final lunchBody = loc.notificationLunchBody;
      final dinnerTitle = loc.notificationDinnerTitle;
      final dinnerBody = loc.notificationDinnerBody;

      await _scheduleDailyNotification(
        id: 1,
        title: breakfastTitle,
        body: breakfastBody,
        time: breakfastTime,
      );
      await _scheduleDailyNotification(
        id: 2,
        title: lunchTitle,
        body: lunchBody,
        time: lunchTime,
      );
      await _scheduleDailyNotification(
        id: 3,
        title: dinnerTitle,
        body: dinnerBody,
        time: dinnerTime,
      );
    } else {
      debugPrint('NotificationService: Notificaties zijn uitgeschakeld.');
    }
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    try {
      final bool? granted = await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.areNotificationsEnabled();

      debugPrint(
        'NotificationService: Permissies status voor Android: $granted',
      );

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
        debugPrint(
          'NotificationService: Tijdstip $time is al geweest vandaag. Gepland voor morgen: $scheduledDate',
        );
      } else {
        debugPrint(
          'NotificationService: Tijdstip $time is nog in de toekomst. Gepland voor vandaag: $scheduledDate',
        );
      }

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          // Let op: 'const' weggehaald hier
          android: AndroidNotificationDetails(
            _mealChannel.id, // Gebruik het nieuwe v2 kanaal
            _mealChannel.name,
            channelDescription: _mealChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: const DarwinNotificationDetails(
            presentSound: true,
            presentAlert: true,
            presentBadge: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('NotificationService: Succesvol gepland (ID: $id)');
    } catch (e, stackTrace) {
      debugPrint(
        'NotificationService: Fout bij plannen notificatie (ID: $id): $e',
      );
      debugPrint('StackTrace: $stackTrace');
    }
  }
}
