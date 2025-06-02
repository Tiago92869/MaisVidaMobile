import 'notification_model.dart';
import 'notification_service.dart';

class NotificationRepository {
  final NotificationService notificationService;

  NotificationRepository({required this.notificationService});

  Future<List<NotificationModel>> getNotifications() async {
    return await notificationService.fetchNotifications();
  }

  Future<void> removeNotification(String id) async {
    await notificationService.deleteNotification(id);
  }

  Future<NotificationModel> markNotificationAsRead(String id) async {
    return await notificationService.markAsRead(id);
  }
}
