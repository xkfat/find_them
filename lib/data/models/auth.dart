import 'package:find_them/data/models/user.dart';

class AuthData {
  final String token;
  final String refreshToken;
  final User user;
  final DateTime expiryTime;
  
  AuthData({
    required this.token,
    required this.refreshToken,
    required this.user,
    required this.expiryTime,
  });
  
  bool get isExpired => DateTime.now().isAfter(expiryTime);
  
  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['access'],
      refreshToken: json['refresh'],
      user: User.fromJson(json['user']),
      expiryTime: DateTime.now().add(Duration(minutes: 60)),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'access': token,
      'refresh': refreshToken,
      'user': user.toJson(),
      'expiry_time': expiryTime.toIso8601String(),
    };
  }
}

class LoginCredentials {
  final String username;
  final String password;
  
  LoginCredentials({
    required this.username,
    required this.password,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class RegisterData {
  final String username;
  final String password;
  final String passwordConfirmation;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  
  RegisterData({
    required this.username,
    required this.password,
    required this.passwordConfirmation,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'password2': passwordConfirmation,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
    };
  }
}