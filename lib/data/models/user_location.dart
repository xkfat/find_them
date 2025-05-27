class UserLocationModel {
  final int id;
  final int user;
  final String username;
  final double latitude;
  final double longitude;
  final DateTime lastUpdated;
  final bool isSharing;

  UserLocationModel({
    required this.id,
    required this.user,
    required this.username,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
    required this.isSharing,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      id: json['id'],
      user: json['user'],
      username: json['username'] ?? '',
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      lastUpdated: DateTime.parse(json['last_updated']),
      isSharing: json['is_sharing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'username': username,
      'latitude': latitude,
      'longitude': longitude,
      'last_updated': lastUpdated.toIso8601String(),
      'is_sharing': isSharing,
    };
  }

  UserLocationModel copyWith({
    int? id,
    int? user,
    String? username,
    double? latitude,
    double? longitude,
    DateTime? lastUpdated,
    bool? isSharing,
  }) {
    return UserLocationModel(
      id: id ?? this.id,
      user: user ?? this.user,
      username: username ?? this.username,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isSharing: isSharing ?? this.isSharing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserLocationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserLocationModel(id: $id, user: $user, username: $username, latitude: $latitude, longitude: $longitude, isSharing: $isSharing)';
  }
}