import 'package:find_them/data/models/location_request.dart';

class LocationSharingModel {
  final int id;
  final int userId;
  final int friendId;
  final DateTime createdAt;
  final UserBasicInfo friendDetails;
  final bool isSharing;
  final bool canSeeYou;

  LocationSharingModel({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.createdAt,
    required this.friendDetails,
    required this.isSharing,
    required this.canSeeYou,
  });

  factory LocationSharingModel.fromJson(Map<String, dynamic> json) {
    return LocationSharingModel(
      id: json['id'],
      userId: json['user'],
      friendId: json['friend'],
      createdAt: DateTime.parse(json['created_at']),
      friendDetails: UserBasicInfo.fromJson(json['friend_details']),
      isSharing: json['is_sharing'] ?? false,  
      canSeeYou: json['can_see_you'] ?? false,
    );
  }
}
