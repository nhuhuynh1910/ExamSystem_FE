abstract class NotificationEvent {
  const NotificationEvent();
}

class LoadNotificationsEvent extends NotificationEvent {
  const LoadNotificationsEvent();
}

class MarkAsReadEvent extends NotificationEvent {
  final int notificationId;
  const MarkAsReadEvent(this.notificationId);
}

class SendNotificationEvent extends NotificationEvent {
  final Map<String, dynamic> data;
  const SendNotificationEvent(this.data);
}
