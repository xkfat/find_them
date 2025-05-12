import 'package:find_them/data/models/user.dart';

class LocationRequest {
  final int? id;
  final int senderId;
  final User? sender;
  final int receiverId;
  final User? receiver;
  final String status;
  final DateTime createdAt;

  LocationRequest({
    this.id,
    required this.senderId,
    this.sender,
    required this.receiverId,
    this.receiver,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory LocationRequest.fromJson(Map<String, dynamic> json) {
    return LocationRequest(
      id: json['id'],
      senderId: json['sender'],
      sender:
          json['sender_object'] != null
              ? User.fromJson(json['sender_object'])
              : null,
      receiverId: json['receiver'],
      receiver:
          json['receiver_object'] != null
              ? User.fromJson(json['receiver_object'])
              : null,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'sender': senderId,
      'receiver': receiverId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }
}
