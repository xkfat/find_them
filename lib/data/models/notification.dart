import 'package:find_them/data/models/location_sharing.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final int id;
  final String user;
  final int? targetId;
  final String? targetModel;
  final String message;
  final String notificationType;
  final bool isRead;
  final DateTime dateCreated;
  final LocationSharingModel? friendData;

  const NotificationModel({
    required this.id,
    required this.user,
    this.targetId,
    this.targetModel,
    required this.message,
    required this.notificationType,
    required this.isRead,
    required this.dateCreated,
    this.friendData,
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

  factory NotificationModel.fromPushPayload(Map<String, dynamic> data) {
    return NotificationModel(
      id: int.tryParse(data['notification_id'] ?? '0') ?? 0,
      user: data['sender_name'] ?? data['receiver_name'] ?? 'System',
      targetId: int.tryParse(
        data['target_id'] ?? data['case_id'] ?? data['report_id'] ?? '0',
      ),
      targetModel:
          data['target_model'] ??
          _getModelFromType(data['notification_type'] ?? 'system'),
      message: data['message'] ?? data['body'] ?? 'New notification',
      notificationType: data['notification_type'] ?? 'system',
      isRead: false, 
      dateCreated: DateTime.now(),
    );
  }

  static String _getModelFromType(String type) {
    switch (type) {
      case 'missing_person':
      case 'case_update':
        return 'missingperson';
      case 'report':
        return 'report';
      case 'location_request':
      case 'location_response':
        return 'locationrequest';
      case 'location_alert':
        return 'user';
      default:
        return '';
    }
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
      case 'system':
      default:
        return 'FindThem Notification';
    }
  }

  IconData get icon {
    switch (notificationType) {
      case 'missing_person':
        return Icons.person_search;
      case 'location_request':
        return Icons.location_on;
      case 'location_response':
        return Icons.location_on;
      case 'location_alert':
        return Icons.warning_amber;
      case 'case_update':
        return Icons.update;
      case 'report':
        return Icons.report;
      case 'system':
      default:
        return Icons.notifications;
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

  String get navigationRoute {
    switch (notificationType) {
      case 'missing_person':
      case 'case_update':
        return '/missing-person-details';
      case 'report':
        return '/report-details';
      case 'location_request':
      case 'location_response':
        return '/location-sharing';
      case 'location_alert':
        return '/location-alert';
      default:
        return '/notifications';
    }
  }

  Map<String, dynamic>? get navigationArguments {
    if (targetId != null) {
      switch (notificationType) {
        case 'missing_person':
        case 'case_update':
          return {'caseId': targetId};
        case 'report':
          return {'reportId': targetId};
        case 'location_request':
        case 'location_response':
          return {'requestId': targetId};
        default:
          return null;
      }
    }
    return null;
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
