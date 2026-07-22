import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc(this._repository) : super(const NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<SendNotificationEvent>(_onSendNotification);
  }

  Future<void> _onLoadNotifications(LoadNotificationsEvent event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading(notifications: state.notifications));
    try {
      final notifications = await _repository.getNotifications();
      emit(NotificationsLoaded(notifications: notifications));
    } catch (e) {
      emit(NotificationError(error: e.toString(), notifications: state.notifications));
    }
  }

  Future<void> _onMarkAsRead(MarkAsReadEvent event, Emitter<NotificationState> emit) async {
    try {
      await _repository.markAsRead(event.notificationId);
      final updatedList = state.notifications.map((n) {
        if (n.notificationId == event.notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      emit(NotificationsLoaded(notifications: updatedList));
    } catch (e) {
      emit(NotificationError(error: e.toString(), notifications: state.notifications));
    }
  }

  Future<void> _onSendNotification(SendNotificationEvent event, Emitter<NotificationState> emit) async {
    try {
      await _repository.sendNotification(event.data);
      emit(NotificationOperationSuccess(message: 'Gửi thông báo thành công', notifications: state.notifications));
      add(const LoadNotificationsEvent());
    } catch (e) {
      emit(NotificationError(error: e.toString(), notifications: state.notifications));
    }
  }
}
