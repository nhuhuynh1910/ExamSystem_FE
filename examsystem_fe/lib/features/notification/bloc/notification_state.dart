import '../models/notification_model.dart';

abstract class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;
  final String? message;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.message,
  });
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading({super.notifications}) : super(isLoading: true);
}

class NotificationsLoaded extends NotificationState {
  const NotificationsLoaded({required List<NotificationModel> notifications}) : super(notifications: notifications);
}

class NotificationError extends NotificationState {
  const NotificationError({required String error, super.notifications}) : super(error: error);
}

class NotificationOperationSuccess extends NotificationState {
  const NotificationOperationSuccess({required String message, super.notifications}) : super(message: message);
}
