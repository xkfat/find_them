import 'package:find_them/data/models/user.dart';
import 'package:find_them/data/models/enum.dart';

class Notification {
  final int? id;
  final int userId;
  final User? user;
  final String message;
  final bool isRead;
  final DateTime dateCreated;
  final String? contentType;
  final int? objectId;
  final NotificationType notificationType;

  Notification({
    this.id,
    required this.userId,
    this.user,
    required this.message,
    this.isRead = false,
    DateTime? dateCreated,
    this.contentType,
    this.objectId,
    this.notificationType = NotificationType.system,
  }) : dateCreated = dateCreated ?? DateTime.now();

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['user'],
      user: json['user_object'] != null ? User.fromJson(json['user_object']) : null,
      message: json['message'],
      isRead: json['is_read'] ?? false,
      dateCreated: DateTime.parse(json['date_created']),
      contentType: json['content_type'],
      objectId: json['object_id'],
      notificationType: NotificationTypeExtension.fromValue(json['notification_type'] ?? 'system'),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic> {
      'user': userId,
      'message': message,
      'is_read': isRead,
      'date_created': dateCreated.toIso8601String(),
      'notification_type': notificationType.value,
    };
    
    if (id != null) {
      map['id'] = id;
    }
    
    if (contentType != null) {
      map['content_type'] = contentType;
    }
    
    if (objectId != null) {
      map['object_id'] = objectId;
    }
    
    return map;
  }
  
  String get formattedDate => 
      '${dateCreated.day.toString().padLeft(2, '0')}/${dateCreated.month.toString().padLeft(2, '0')}/${dateCreated.year}';
      
  String get formattedTime => 
      '${dateCreated.hour.toString().padLeft(2, '0')}:${dateCreated.minute.toString().padLeft(2, '0')}';
      
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(dateCreated);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }
  
  bool get hasTarget => contentType != null && objectId != null;
  
  Notification copyWith({
    int? id,
    int? userId,
    User? user,
    String? message,
    bool? isRead,
    DateTime? dateCreated,
    String? contentType,
    int? objectId,
    NotificationType? notificationType,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      dateCreated: dateCreated ?? this.dateCreated,
      contentType: contentType ?? this.contentType,
      objectId: objectId ?? this.objectId,
      notificationType: notificationType ?? this.notificationType,
    );
  }
}