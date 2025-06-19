import 'package:find_them/data/models/notification.dart';
import 'package:find_them/logic/cubit/notification_cubit.dart';
import 'package:find_them/presentation/widgets/notification/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // 🔥 NEW: Track locally dismissed notifications for immediate UI updates
  final Set<int> _dismissedNotifications = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<NotificationCubit>();

      if (cubit.isServiceReady) {
        cubit.loadNotifications();
      } else {}
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
          } else if (state is NotificationCleared) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('All notifications cleared'),
                backgroundColor: AppColors.teal,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<NotificationCubit>();

          if (!cubit.isServiceReady) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login,
                    size: 64,
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please log in to view notifications',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.getTextColor(context),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.teal),
                  const SizedBox(height: 16),
                  Text(
                    'Loading notifications...',
                    style: TextStyle(color: AppColors.getTextColor(context)),
                  ),
                ],
              ),
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
                    color: AppColors.getMissingRedColor(context),
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
                      context.read<NotificationCubit>().loadNotifications();
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
            // 🔥 NEW: Filter out locally dismissed notifications
            final visibleNotifications =
                state.notifications
                    .where(
                      (notification) =>
                          !_dismissedNotifications.contains(notification.id),
                    )
                    .toList();

            if (visibleNotifications.isEmpty) {
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
                // 🔥 NEW: Clear dismissed list on refresh
                _dismissedNotifications.clear();
                context.read<NotificationCubit>().refreshNotifications();
              },
              color: AppColors.teal,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: visibleNotifications.length,
                itemBuilder: (context, index) {
                  final notification = visibleNotifications[index];
                  return NotificationCard(
                    notification: notification,
                    onTap: () {
                      _handleNotificationTap(context, notification);
                    },

                    onDismiss: () {
                      setState(() {
                        _dismissedNotifications.add(notification.id);
                      });

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

          if (state is NotificationEmpty) {
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

          if (state is NotificationClearing) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.teal),
                  const SizedBox(height: 16),
                  Text(
                    'Clearing notifications...',
                    style: TextStyle(color: AppColors.getTextColor(context)),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Text(
              'Loading notifications...',
              style: TextStyle(color: AppColors.getTextColor(context)),
            ),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    switch (notification.notificationType) {
      case 'location_request':
      case 'location_response':
      case 'location_alert':
        Navigator.pushNamed(context, '/location-sharing');
        break;

      case 'missing_person':
        if (notification.targetId != null) {
          Navigator.pushNamed(
            context,
            '/case/details',
            arguments: notification.targetId,
          );
        } else {
          Navigator.pushNamed(context, '/notifications');
        }
        break;

      case 'case_update':
        Navigator.pushNamed(context, '/submitted-cases');
        break;

      default:
        Navigator.pushNamed(context, '/notifications');
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
        Navigator.pushNamed(context, '/map');
        break;
      case 'location_alert':
        Navigator.pushNamed(context, '/map');
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
        return 'View details';
      case 'location_response':
        return 'View on map';
      case 'location_alert':
        return 'View on map';
      default:
        return null;
    }
  }
}
