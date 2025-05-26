class LocationRequestModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String status;
  final DateTime createdAt;
  final UserBasicInfo senderDetails;
  final UserBasicInfo receiverDetails;

  LocationRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.senderDetails,
    required this.receiverDetails,
  });

  factory LocationRequestModel.fromJson(Map<String, dynamic> json) {
    return LocationRequestModel(
      id: json['id'],
      senderId: json['sender'],
      receiverId: json['receiver'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      senderDetails: UserBasicInfo.fromJson(json['sender_details']),
      receiverDetails: UserBasicInfo.fromJson(json['receiver_details']),
    );
  }
}

class UserBasicInfo {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePhoto;

  UserBasicInfo({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePhoto,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get displayName => fullName.isNotEmpty ? fullName : username;

  factory UserBasicInfo.fromJson(Map<String, dynamic> json) {
    return UserBasicInfo(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'],
      profilePhoto: json['profile_photo'] as String?,
    );
  }
}
