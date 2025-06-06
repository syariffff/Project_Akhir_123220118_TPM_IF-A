import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize notifications
  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();
    
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid = 
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Request permissions
    await requestNotificationPermissions();
  }

  // Request notification permissions
  Future<void> requestNotificationPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // Handle notification tap
  void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      // Handle notification tap - bisa navigate ke order detail
      print('Notification payload: $payload');
    }
  }

  // Schedule notification 15 minutes before pickup time
  Future<void> schedulePickupReminder({
    required int id,
    required String orderId,
    required DateTime pickupTime,
    required String title,
    required String body,
  }) async {
    // Calculate notification time (15 minutes before pickup)
    final DateTime notificationTime = pickupTime.subtract(const Duration(minutes: 15));
    
    // Only schedule if notification time is in the future
    if (notificationTime.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(notificationTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'pickup_reminder',
            'Pickup Reminder',
            channelDescription: 'Reminder for order pickup',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: orderId,
      );
    }
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Show immediate notification - Fungsi ini yang digunakan untuk status order
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'order_status',
        'Order Status Updates',
        channelDescription: 'Notifications for order status changes',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        sound: 'default.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Fungsi khusus untuk notifikasi order selesai
  Future<void> showOrderCompletedNotification({
    required String orderId,
    String? customerName,
  }) async {
    int notificationId = orderId.hashCode.abs();
    
    await showImmediateNotification(
      id: notificationId,
      title: 'Pesanan Selesai ✅',
      body: customerName != null 
          ? 'Pesanan $orderId untuk $customerName telah selesai dan siap diambil!'
          : 'Pesanan $orderId telah selesai dan siap diambil!',
      payload: orderId,
    );
  }

  // Fungsi khusus untuk notifikasi order dibatalkan
  Future<void> showOrderCancelledNotification({
    required String orderId,
    String? reason,
  }) async {
    int notificationId = orderId.hashCode.abs();
    
    await showImmediateNotification(
      id: notificationId,
      title: 'Pesanan Dibatalkan ❌',
      body: reason != null 
          ? 'Pesanan $orderId telah dibatalkan. Alasan: $reason'
          : 'Pesanan $orderId telah dibatalkan.',
      payload: orderId,
    );
  }
}