part of 'notification_cubit.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

final class NotificationInitial extends NotificationState {}

final class NotificationLoading extends NotificationState {}

final class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;

  const NotificationLoaded({required this.notifications});

  @override
  List<Object?> get props => [notifications];
}

final class NotificationDetailLoaded extends NotificationState {
  final NotificationModel notification;

  const NotificationDetailLoaded({required this.notification});

  @override
  List<Object?> get props => [notification];
}

final class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}