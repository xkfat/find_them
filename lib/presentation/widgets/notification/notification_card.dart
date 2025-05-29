import 'package:find_them/data/models/notification.dart';
import 'package:flutter/material.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionText;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Dismissible(
        key: Key('notification_${notification.id}'), // More specific key
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: AppColors.getMissingRedColor(context),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) {
          // Show immediate feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Notification deleted'),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.teal,
            ),
          );

          // Call the dismiss callback
          if (onDismiss != null) {
            onDismiss!();
          }
        },
        confirmDismiss: (direction) async {
          // Optional: Show confirmation dialog for important notifications
          if (notification.notificationType == 'missing_person' ||
              notification.notificationType == 'location_alert') {
            return await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: AppColors.getSurfaceColor(context),
                      title: Text(
                        'Delete Notification',
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to delete this ${notification.title.toLowerCase()}?',
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.getMissingRedColor(
                              context,
                            ),
                            foregroundColor: AppColors.white,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                ) ??
                false;
          }
          return true; // Allow dismiss for other notification types
        },
        child: Card(
          elevation: 0,
          color:
              AppColors
                  .lighterMint, // Using lighterMint for all cards as requested
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 12),
                    _buildMessage(context),
                    if (onAction != null && actionText != null ||
                        onDismiss != null)
                      const SizedBox(height: 16),
                    if (onAction != null && actionText != null ||
                        onDismiss != null)
                      _buildActions(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(notification.icon, size: 20, color: AppColors.teal),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Text(
                        notification.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getSecondaryTextColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (notification.user.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'From: ${notification.user}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getSecondaryTextColor(context),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 44),
      child: Text(
        notification.message,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.getTextColor(context),
          height: 1.5,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 44),
      child: Row(
        children: [
          if (onAction != null && actionText != null)
            Expanded(
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          if (onAction != null && actionText != null && onDismiss != null)
            const SizedBox(width: 12),
          if (onDismiss != null)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Show confirmation for manual dismiss button
                  _showManualDismissConfirmation(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.getSecondaryTextColor(
                      context,
                    ).withOpacity(0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  'Dismiss',
                  style: TextStyle(
                    color: AppColors.getSecondaryTextColor(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showManualDismissConfirmation(BuildContext context) {
    if (notification.notificationType == 'missing_person' ||
        notification.notificationType == 'location_alert') {
      // Show confirmation for important notifications
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.getSurfaceColor(context),
            title: Text(
              'Dismiss Notification',
              style: TextStyle(color: AppColors.getTextColor(context)),
            ),
            content: Text(
              'Are you sure you want to dismiss this ${notification.title.toLowerCase()}?',
              style: TextStyle(color: AppColors.getTextColor(context)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.getSecondaryTextColor(context),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onDismiss != null) {
                    onDismiss!();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getMissingRedColor(context),
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Dismiss'),
              ),
            ],
          );
        },
      );
    } else {
      // Direct dismiss for other notifications
      if (onDismiss != null) {
        onDismiss!();
      }
    }
  }
}
