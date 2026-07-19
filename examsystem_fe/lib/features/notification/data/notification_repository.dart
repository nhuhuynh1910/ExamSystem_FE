import 'notification_api.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final NotificationApi _api = NotificationApi();

  Future<List<NotificationModel>> getNotifications() => _api.getNotifications();
  Future<void> markAsRead(int id) => _api.markAsRead(id);
  Future<void> sendNotification(Map<String, dynamic> data) => _api.sendNotification(data);
}
