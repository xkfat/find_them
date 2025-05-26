
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
      child: Card(
        elevation: 0,
        color: _getCardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                _buildMessage(context),
                const SizedBox(height: 16),
                _buildActions(context),
              ],
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
        Icon(_getIconData(), size: 24, color: _getIconColor(context)),
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
        ),
      ],
    );
  }

  Widget _buildMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 36,
      ), 
      child: Text(
        notification.message,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.getTextColor(context),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 36), 
      child: Row(
        children: [
          if (onAction != null && actionText != null)
            Expanded(
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 14,
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
                onPressed: onDismiss,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkDivider
                            : AppColors.lightgrey,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Dismiss',
                  style: TextStyle(
                    color: AppColors.getSecondaryTextColor(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (notification.notificationType) {
      case 'missing_person':
        return isDark
            ? AppColors.missingRedBackgroundDark
            : AppColors.missingRedBackground;
      case 'location_request':
        return isDark
            ? AppColors.investigatingYellowBackgroundDark
            : AppColors.investigatingYellowBackground;
      case 'location_response':
        return isDark
            ? AppColors.foundGreenBackgroundDark
            : AppColors.foundGreenBackground;
      case 'location_alert':
        return isDark
            ? AppColors.investigatingYellowBackgroundDark
            : AppColors.investigatingYellowBackground;
      case 'case_update':
        return isDark ? AppColors.darkCardBackground : AppColors.lighterMint;
      case 'report':
        return isDark
            ? AppColors.investigatingYellowBackgroundDark
            : AppColors.investigatingYellowBackground;
      default:
        return AppColors.getCardColor(context);
    }
  }

  Color _getIconColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (notification.notificationType) {
      case 'missing_person':
        return isDark ? AppColors.missingRedDark : AppColors.missingRed;
      case 'location_request':
        return isDark ? AppColors.missingRedDark : AppColors.missingRed;
      case 'location_response':
        return isDark ? AppColors.foundGreenDark : AppColors.foundGreen;
      case 'location_alert':
        return isDark
            ? AppColors.investigatingYellowDark
            : AppColors.investigatingYellow;
      case 'case_update':
        return AppColors.teal;
      case 'report':
        return isDark ? AppColors.missingRedDark : AppColors.missingRed;
      default:
        return AppColors.getSecondaryTextColor(context);
    }
  }

  IconData _getIconData() {
    switch (notification.notificationType) {
      case 'missing_person':
        return Icons.warning_amber_rounded;
      case 'location_request':
        return Icons.push_pin_outlined;
      case 'location_response':
        return Icons.check_circle;
      case 'location_alert':
        return Icons.warning_amber_rounded;
      case 'case_update':
        return Icons.info_outline;
      case 'report':
        return Icons.flag_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}
