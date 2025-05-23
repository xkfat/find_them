/*
import 'package:find_them/data/models/selected_friend.dart';
import 'package:find_them/data/models/user.dart';


class UserLocation {
  final int? id;
  final int userId;
  final User? user;
  final double? latitude;
  final double? longitude;
  final DateTime lastUpdated;
  final bool isSharing;
  final bool shareWithAllFriends;
  final List<SelectedFriend>? selectedFriends;

  UserLocation({
    this.id,
    required this.userId,
    this.user,
    this.latitude,
    this.longitude,
    DateTime? lastUpdated,
    this.isSharing = false,
    this.shareWithAllFriends = true,
    this.selectedFriends,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      id: json['id'],
      userId: json['user'],
      user: json['user_object'] != null ? User.fromJson(json['user_object']) : null,
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      lastUpdated: DateTime.parse(json['last_updated']),
      isSharing: json['is_sharing'] ?? false,
      shareWithAllFriends: json['share_with_all_friends'] ?? true,
      selectedFriends: json['selected_friends'] != null 
          ? (json['selected_friends'] as List).map((e) => SelectedFriend.fromJson(e)).toList() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic> {
      'user': userId,
      'is_sharing': isSharing,
      'share_with_all_friends': shareWithAllFriends,
      'last_updated': lastUpdated.toIso8601String(),
    };
    
    if (id != null) {
      map['id'] = id;
    }
    
    if (latitude != null) {
      map['latitude'] = latitude;
    }
    
    if (longitude != null) {
      map['longitude'] = longitude;
    }
    
    return map;
  }
  
  bool get hasLocation => latitude != null && longitude != null;
}
*/