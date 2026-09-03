import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vagabond/firebase_options.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    final token = await messaging.getToken();
    debugPrint('FCM TOKEN: $token');

    const androidSettings = AndroidInitializationSettings('@drawable/splash');

    const initializationSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // Handle the notification when the app is launched from a terminated state
        _handleNotificationTap(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Handle the notification when the app is opened from the background
      _handleNotificationTap(message);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('================================');
      debugPrint('FOREGROUND FCM RECEIVED');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');
      debugPrint('================================');

      showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
      );
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static void _handleNotificationTap(RemoteMessage message) {
    final action = message.data['action'];

    if (action == 'accept') {
      debugPrint('Notification accepted');
      // Call your API here
    } else if (action == 'reject') {
      debugPrint('Notification rejected');
      // Call your API here
    } else {
      debugPrint('Notification tapped');
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    final action = response.actionId;

    if (action == 'accept') {
      debugPrint('Notification accepted');
      // Call your API here
    } else if (action == 'reject') {
      debugPrint('Notification rejected');
      // Call your API here
    } else {
      debugPrint('Notification tapped');
    }
  }

  static Future<void> showNotification({required int id, required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'request_channel',
      'Request Notifications',
      channelDescription: 'Notifications with accept/reject actions',
      importance: Importance.high,
      priority: Priority.high,
      // actions: [AndroidNotificationAction('accept', 'Accept'), AndroidNotificationAction('reject', 'Reject')],
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(id: id, title: title, body: body, notificationDetails: details);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint('Handling a background message ${message.messageId}');
}
