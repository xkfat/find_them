import 'package:find_them/data/models/enum.dart';

class User {
  final int? id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String? password;
  final String phoneNumber;
  final String? profilePhoto;
  final Language language;
  final Theme theme;
  final bool locationPermission;

  User({
    this.id,
    required this.username,
    this.password,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.profilePhoto,
    this.language = Language.english,
    this.theme = Theme.light,
    this.locationPermission = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profilePhoto: json['profile_photo'],
      language: LanguageExtension.fromValue(json['language'] ?? 'english'),
      theme: ThemeExtension.fromValue(json['theme'] ?? 'light'),
      locationPermission: json['location_permission'] ?? false,
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? phoneNumber,
    String? profilePhoto,
    Language? language,
    Theme? theme,
    bool? locationPermission,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      locationPermission: locationPermission ?? this.locationPermission,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic> {
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'language': language.value,
      'theme': theme.value,
      'location_permission': locationPermission,
    };

    if (id != null) {
      map['id'] = id;
    }

    if (profilePhoto != null) {
      map['profile_photo'] = profilePhoto;
    }

    if (password != null) {
      map['password'] = password;
    }

    return map;
  }

  String get fullName => '$firstName $lastName';
  
  String get profilePhotoUrl => profilePhoto ?? 'assets/images/default_profile.png';
}