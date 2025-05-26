
class NotificationModel {
  final int id;
  final String user;
  final int? targetId;
  final String? targetModel;
  final String message;
  final String notificationType;
  final bool isRead;
  final DateTime dateCreated;

  const NotificationModel({
    required this.id,
    required this.user,
    this.targetId,
    this.targetModel,
    required this.message,
    required this.notificationType,
    required this.isRead,
    required this.dateCreated,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      user: json['user'] as String,
      targetId: json['target_id'] as int?,
      targetModel: json['target_model'] as String?,
      message: json['message'] as String,
      notificationType: json['notification_type'] as String,
      isRead: json['is_read'] as bool,
      dateCreated: DateTime.parse(json['date_created'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'target_id': targetId,
      'target_model': targetModel,
      'message': message,
      'notification_type': notificationType,
      'is_read': isRead,
      'date_created': dateCreated.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    int? id,
    String? user,
    int? targetId,
    String? targetModel,
    String? message,
    String? notificationType,
    bool? isRead,
    DateTime? dateCreated,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      user: user ?? this.user,
      targetId: targetId ?? this.targetId,
      targetModel: targetModel ?? this.targetModel,
      message: message ?? this.message,
      notificationType: notificationType ?? this.notificationType,
      isRead: isRead ?? this.isRead,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }

  bool get isMissingPersonNotification => notificationType == 'missing_person';
  bool get isLocationRequest => notificationType == 'location_request';
  bool get isLocationResponse => notificationType == 'location_response';
  bool get isLocationAlert => notificationType == 'location_alert';
  bool get isCaseUpdate => notificationType == 'case_update';
  bool get isReportNotification => notificationType == 'report';
  bool get isSystemNotification => notificationType == 'system';

  String get iconPath {
    switch (notificationType) {
      case 'missing_person':
        return 'assets/icons/alert.svg';
      case 'location_request':
        return 'assets/icons/location_pin.svg';
      case 'location_response':
        return 'assets/icons/check_circle.svg';
      case 'location_alert':
        return 'assets/icons/location_pin.svg';
      case 'case_update':
        return 'assets/icons/info.svg';
      case 'report':
        return 'assets/icons/flag.svg';
      case 'system':
      default:
        return 'assets/icons/bell.svg';
    }
  }

  String get title {
    switch (notificationType) {
      case 'missing_person':
        return 'New Missing Person';
      case 'location_request':
        return 'Location Sharing Request';
      case 'location_response':
        return 'Location Sharing Accepted';
      case 'location_alert':
        return 'Location Sharing Alert';
      case 'case_update':
        return 'Case Update';
      case 'report':
        return 'Report Notification';
      case 'system':
      default:
        return 'System Notification';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(dateCreated);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${(difference.inDays / 7).floor()} weeks ago';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationModel(id: $id, notificationType: $notificationType, message: $message)';
  }
}
