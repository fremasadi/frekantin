import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Handler untuk background messages (harus dideklarasikan di level top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Pastikan Firebase diinisialisasi untuk background handler
  await Firebase.initializeApp();
  print('Handling background message: ${message.notification?.title}');
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // 1. Mendaftarkan background handler sebelum initializeApp
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // 2. Request permission untuk notifikasi
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // 3. Inisialisasi local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings();

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          print('Notification tapped: ${details.payload}');
        },
      );

      // 4. Set up handlers untuk berbagai kondisi
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _showNotification(message);
      });

      print('NotificationService initialized successfully');
    } catch (e) {
      print('Error initializing NotificationService: $e');
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    try {
      final AndroidNotificationDetails androidDetails =
          const AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(),
      );

      await _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        notificationDetails,
        payload: message.data.toString(),
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
}
