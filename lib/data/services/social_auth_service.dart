// lib/data/services/social_auth_service.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class SocialAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Google Sign In
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Step 1: Get Google account
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Sign in canceled'};
      }

      // Step 2: Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Step 3: Manually create user data without using Firebase
      // Parse name parts safely
      String fullName = googleUser.displayName ?? '';
      List<String> nameParts = fullName.split(' ');
      String firstName = nameParts.isNotEmpty ? nameParts.first : '';
      String lastName = nameParts.length > 1 ? nameParts.last : '';

      Map<String, dynamic> userData = {
        'provider': 'google',
        'id': googleUser.id,
        'email': googleUser.email,
        'display_name': fullName,
        'photo_url': googleUser.photoUrl ?? '',
        'id_token': googleAuth.idToken ?? '',
        'phone_number': '',
        'first_name': firstName,
        'last_name': lastName,
        'username': googleUser.email.split('@').first,
      };

      // Step 4: Authenticate with your server
      bool serverAuth = await _authenticateWithServer(userData);
      return {'success': serverAuth, 'user': userData};
    } catch (e) {
      print("Google Sign In Error: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  // Facebook Sign In
  Future<Map<String, dynamic>> signInWithFacebook() async {
    try {
      // Step 1: Logout from any previous Facebook session
      await FacebookAuth.instance.logOut();

      // Step 2: Login to Facebook with permissions
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // Step 3: Get user data from Facebook
        final facebookUserData = await FacebookAuth.instance.getUserData(
          fields: "id,name,email,picture.width(200),first_name,last_name",
        );

        // Get email with null safety
        String email = facebookUserData['email'] ?? '';

        // Step 4: Manually create user data without using Firebase
        Map<String, dynamic> userData = {
          'provider': 'facebook',
          'id': facebookUserData['id'] ?? '',
          'email': email,
          'display_name': facebookUserData['name'] ?? '',
          'photo_url': facebookUserData['picture']?['data']?['url'] ?? '',
          'access_token': result.accessToken?.tokenString ?? '',
          'phone_number': '',
          'first_name': facebookUserData['first_name'] ?? '',
          'last_name': facebookUserData['last_name'] ?? '',
          'username':
              email.isNotEmpty
                  ? email.split('@').first
                  : 'fb_${facebookUserData['id'] ?? ''}',
        };

        // Step 5: Authenticate with your server
        bool serverAuth = await _authenticateWithServer(userData);
        return {'success': serverAuth, 'user': userData};
      }

      return {'success': false, 'message': 'Facebook sign in failed'};
    } catch (e) {
      print("Facebook Sign In Error: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> _authenticateWithServer(Map<String, dynamic> userData) async {
    try {
      // Simplify the data sent to match your backend expectations
      Map<String, dynamic> authData = {
        'id_token': userData['id_token'] ?? userData['access_token'],
        'provider': userData['provider'],
        'email': userData['email'],
        'name': userData['display_name'],
        'phone_number': userData['phone_number'] ?? '',
      };

      print("Sending to server: ${json.encode(authData)}");

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/accounts/social-auth/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(authData),
      );

      print("Server response code: ${response.statusCode}");
      print("Server response body: ${response.body}");

      // Simply return true if the server accepted the request
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Server Authentication Error: $e");
      return false;
    }
  }

Future<bool> updateUserPhone(String phoneNumber, String token) async {
  try {
    final response = await http.patch(
      Uri.parse('http://10.0.2.2:8000/api/accounts/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'phone_number': phoneNumber}),
    );

    print("Update phone response: ${response.statusCode} - ${response.body}");
    
    return response.statusCode == 200;
  } catch (e) {
    print("Error updating phone: $e");
    return false;
  }
}

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
  }
}
