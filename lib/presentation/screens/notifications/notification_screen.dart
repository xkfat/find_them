import 'package:find_them/data/models/notification.dart';
import 'package:find_them/presentation/widgets/notification/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_them/logic/cubit/notification_cubit.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCubit>().getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.getSurfaceColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.getTextColor(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.getMissingRedColor(context),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            );
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationCubit>().getNotifications();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You\'re all caught up!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationCubit>().getNotifications();
              },
              color: AppColors.teal,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return NotificationCard(
                    notification: notification,
                    onTap: () {
                      if (!notification.isRead) {
                        context.read<NotificationCubit>().markAsRead(
                          notification.id,
                        );
                      }
                      _handleNotificationTap(context, notification);
                    },
                    onDismiss: () {
                      context.read<NotificationCubit>().deleteNotification(
                        notification.id,
                      );
                    },
                    onAction: () {
                      _handleNotificationAction(context, notification);
                    },
                    actionText: _getActionText(notification),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    switch (notification.notificationType) {
      case 'missing_person':
        if (notification.targetId != null) {
          Navigator.pushNamed(
            context,
            '/case/details',
            arguments: notification.targetId,
          );
        }
        break;
      case 'case_update':
        if (notification.targetId != null) {
          Navigator.pushNamed(context, '/submitted-cases');
        }
        break;
      case 'location_request':
      case 'location_response':
      case 'location_alert':
        Navigator.pushNamed(context, '/location-sharing');
        break;
      default:
        break;
    }
  }

  void _handleNotificationAction(
    BuildContext context,
    NotificationModel notification,
  ) {
    switch (notification.notificationType) {
      case 'missing_person':
        if (notification.targetId != null) {
          Navigator.pushNamed(
            context,
            '/case/details',
            arguments: notification.targetId,
          );
        }
        break;
      case 'location_request':
        Navigator.pushNamed(context, '/location-sharing');
        break;
      case 'location_response':
        Navigator.pushNamed(context, '/location-sharing');
        break;
      case 'location_alert':
        Navigator.pushNamed(context, '/location-sharing');
        break;
      default:
        break;
    }
  }

  String? _getActionText(NotificationModel notification) {
    switch (notification.notificationType) {
      case 'missing_person':
        return 'View details';
      case 'location_request':
        return 'Accept';
      case 'location_response':
        return 'View on map';
      case 'location_alert':
        return 'View on map';
      default:
        return null;
    }
  }
}
