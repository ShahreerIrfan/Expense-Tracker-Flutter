import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings);
  }

  static Future<void> showBudgetAlert({
    required int id,
    required String categoryName,
    required double percentage,
    required double spent,
    required double budget,
  }) async {
    String title;
    String body;

    if (percentage >= 100) {
      title = 'Budget Exceeded!';
      body =
          'You have exceeded your $categoryName budget. Spent: $spent / $budget';
    } else if (percentage >= 80) {
      title = 'Budget Warning: 80%';
      body =
          'You have used 80% of your $categoryName budget. Spent: $spent / $budget';
    } else {
      title = 'Budget Alert: 50%';
      body =
          'You have used 50% of your $categoryName budget. Spent: $spent / $budget';
    }

    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Budget Alerts',
          channelDescription: 'Notifications for budget alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> showBillReminder({
    required int id,
    required String title,
    required double amount,
    required DateTime dueDate,
  }) async {
    await _notifications.show(
      id,
      'Bill Reminder: $title',
      'You have a bill of $amount due on ${dueDate.day}/${dueDate.month}/${dueDate.year}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'bill_reminders',
          'Bill Reminders',
          channelDescription: 'Notifications for bill reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> showDailySummary({
    required double totalSpent,
    required double totalIncome,
    required int transactionCount,
  }) async {
    await _notifications.show(
      9999,
      'Daily Summary',
      'Spent: $totalSpent | Earned: $totalIncome | $transactionCount transactions',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Daily Summary',
          channelDescription: 'Daily spending summary',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
