import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:find_them/data/dataprovider/exception.dart';
import 'package:find_them/data/models/notification.dart';
import 'package:find_them/data/repositories/notification_repo.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super(NotificationInitial());

  Future<void> getNotifications({String? type}) async {
    emit(NotificationLoading());
    try {
      log('Fetching notifications${type != null ? ' of type: $type' : ''}');

      final allNotifications = await _repository.getNotifications(type: type);

      final filteredNotifications =
          allNotifications
              .where(
                (notification) => notification.notificationType != 'system',
              )
              .toList();

      emit(NotificationLoaded(notifications: filteredNotifications));
    } on UnauthorisedException catch (e) {
      emit(NotificationError("Authentication error: $e"));
    } on SocketException {
      emit(NotificationError("Network error: Check your internet connection"));
    } on TimeoutException {
      emit(NotificationError("Connection timed out"));
    } catch (e) {
      log("Error fetching notifications: $e");
      emit(NotificationError("An unexpected error occurred: $e"));
    }
  }

  Future<void> getNotificationById(int id) async {
    emit(NotificationLoading());
    try {
      final notification = await _repository.getNotificationById(id);
      emit(NotificationDetailLoaded(notification: notification));
    } catch (e) {
      emit(NotificationError("Failed to load notification: $e"));
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _repository.markAsRead(notificationId);

      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final updatedNotifications =
            currentState.notifications.map((notification) {
              if (notification.id == notificationId) {
                return notification.copyWith(isRead: true);
              }
              return notification;
            }).toList();

        emit(NotificationLoaded(notifications: updatedNotifications));
      }
    } catch (e) {
      emit(NotificationError("Failed to mark notification as read: $e"));
    }
  }
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final updatedNotifications = currentState.notifications
            .where((notification) => notification.id != notificationId)
            .toList();
        
        emit(NotificationLoaded(notifications: updatedNotifications));
      }
    } catch (e) {
      emit(NotificationError("Failed to delete notification: $e"));
    }
  }

  void dismissNotification(int notificationId) {
    deleteNotification(notificationId);
  }

  int get unreadCount {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      return currentState.notifications.where((n) => !n.isRead).length;
    }
    return 0;
  }

  void reset() {
    emit(NotificationInitial());
  }
}