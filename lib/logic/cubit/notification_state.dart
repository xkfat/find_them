
part of 'notification_cubit.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final String? filterType;

  const NotificationLoaded({
    required this.notifications,
    this.filterType,
  });

  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    String? filterType,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      filterType: filterType ?? this.filterType,
    );
  }

  @override
  List<Object?> get props => [notifications, filterType];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationEmpty extends NotificationState {
  final String? filterType;

  const NotificationEmpty({this.filterType});

  @override
  List<Object?> get props => [filterType];
}

class NotificationDeleting extends NotificationState {
  final int notificationId;

  const NotificationDeleting(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class NotificationDeleted extends NotificationState {
  final int deletedId;
  final List<NotificationModel> remainingNotifications;
  final int unreadCount;

  const NotificationDeleted({
    required this.deletedId,
    required this.remainingNotifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [deletedId, remainingNotifications, unreadCount];
}

class NotificationClearing extends NotificationState {}

class NotificationCleared extends NotificationState {}

class NotificationRefreshing extends NotificationState {
  final List<NotificationModel> currentNotifications;

  const NotificationRefreshing(this.currentNotifications);

  @override
  List<Object?> get props => [currentNotifications];
}

class NotificationNewReceived extends NotificationState {
  final NotificationModel newNotification;
  final List<NotificationModel> allNotifications;

  const NotificationNewReceived({
    required this.newNotification,
    required this.allNotifications,
  });

  @override
  List<Object?> get props => [newNotification, allNotifications];
}