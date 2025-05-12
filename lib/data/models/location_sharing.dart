import 'package:find_them/data/models/user.dart';

class LocationSharing {
  final int? id;
  final int userId;
  final User? user;
  final int friendId;
  final User? friend;
  final DateTime createdAt;

  LocationSharing({
    this.id,
    required this.userId,
    this.user,
    required this.friendId,
    this.friend,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory LocationSharing.fromJson(Map<String, dynamic> json) {
    return LocationSharing(
      id: json['id'],
      userId: json['user'],
      user: json['user_object'] != null ? User.fromJson(json['user_object']) : null,
      friendId: json['friend'],
      friend: json['friend_object'] != null ? User.fromJson(json['friend_object']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic> {
      'user': userId,
      'friend': friendId,
      'created_at': createdAt.toIso8601String(),
    };
    
    if (id != null) {
      map['id'] = id;
    }
    
    return map;
  }
}