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
        key: Key('notification_${notification.id}'),
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
          // 🔥 FIX: No snackbar - instant silent dismiss
          if (onDismiss != null) {
            onDismiss!();
          }
        },
        confirmDismiss: (direction) async {
          // 🔥 FIX: No confirmation dialogs - instant dismiss for all notifications
          return true; // Always allow immediate dismissal
        },
        child: Card(
          elevation: 0,
          color: AppColors.lighterMint,
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
                    // 🔥 ALWAYS show actions for case_update notifications
                    if (_shouldShowActions()) const SizedBox(height: 16),
                    if (_shouldShowActions()) _buildActions(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 NEW: Determine if actions should be shown
  bool _shouldShowActions() {
    // Always show actions for case_update notifications
    if (notification.notificationType == 'case_update') {
      return true;
    }
    // Show actions if provided for other types
    return (onAction != null && actionText != null) || onDismiss != null;
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔥 RESTORED: Original icon design with teal background and opacity
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
              // 🔥 RESTORED: Original header layout with timeAgo and isRead indicator
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
                      // 🔥 RESTORED: Original unread indicator position and style
                      if (!notification.isRead) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
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
          // 🔥 NEW: Special handling for case_update notifications
          if (notification.notificationType == 'case_update') ...[
            // View Details Button for case updates
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to submitted cases screen
                  Navigator.pushNamed(context, '/submitted-cases');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Dismiss Button for case updates
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // 🔥 FIX: Immediate dismiss without confirmation
                  if (onDismiss != null) {
                    onDismiss!();
                  }
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
          ] else ...[
            // 🔥 EXISTING: Regular action buttons for other notification types
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
                    // 🔥 FIX: Immediate dismiss without confirmation
                    if (onDismiss != null) {
                      onDismiss!();
                    }
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
        ],
      ),
    );
  }
}
