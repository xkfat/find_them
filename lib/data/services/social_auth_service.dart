import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class SocialAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Sign in canceled'};
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

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

      bool serverAuth = await _authenticateWithServer(userData);
      return {'success': serverAuth, 'user': userData};
    } catch (e) {
      log("Google Sign In Error: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> signInWithFacebook() async {
    try {
      await FacebookAuth.instance.logOut();

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final facebookUserData = await FacebookAuth.instance.getUserData(
          fields: "id,name,email,picture.width(200),first_name,last_name",
        );

        String email = facebookUserData['email'] ?? '';

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

        bool serverAuth = await _authenticateWithServer(userData);
        return {'success': serverAuth, 'user': userData};
      }

      return {'success': false, 'message': 'Facebook sign in failed'};
    } catch (e) {
      log("Facebook Sign In Error: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> _authenticateWithServer(Map<String, dynamic> userData) async {
    try {
      Map<String, dynamic> authData = {
        'id_token': userData['id_token'] ?? userData['access_token'],
        'provider': userData['provider'],
        'email': userData['email'],
        'name': userData['display_name'],
        'phone_number': userData['phone_number'] ?? '',
      };

      log("Sending to server: ${json.encode(authData)}");

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/accounts/social-auth/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(authData),
      );

      log("Server response code: ${response.statusCode}");
      log("Server response body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log("Server Authentication Error: $e");
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

    log("Update phone response: ${response.statusCode} - ${response.body}");
    
    return response.statusCode == 200;
  } catch (e) {
    log("Error updating phone: $e");
    return false;
  }
}

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
  }
}
