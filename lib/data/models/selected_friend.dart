import 'package:find_them/data/models/user.dart';
import 'package:find_them/data/models/user_location.dart';

class SelectedFriend {
  final int? id;
  final int userLocationId;
  final UserLocation? userLocation;
  final int friendId;
  final User? friend;

  SelectedFriend({
    this.id,
    required this.userLocationId,
    this.userLocation,
    required this.friendId,
    this.friend,
  });

  factory SelectedFriend.fromJson(Map<String, dynamic> json) {
    return SelectedFriend(
      id: json['id'],
      userLocationId: json['user_location'],
      userLocation: json['user_location_object'] != null 
          ? UserLocation.fromJson(json['user_location_object']) 
          : null,
      friendId: json['friend'],
      friend: json['friend_object'] != null ? User.fromJson(json['friend_object']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic> {
      'user_location': userLocationId,
      'friend': friendId,
    };
    
    if (id != null) {
      map['id'] = id;
    }
    
    return map;
  }
}