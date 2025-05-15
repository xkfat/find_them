import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Google sign in
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google sign-in flow');
      
      // Step 1: Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google sign-in cancelled by user');
        return null; // User cancelled
      }

      print('Getting Google authentication');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in with Firebase using Google credentials');
      // Step 2: Get Firebase user credentials
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google sign-in error: $e');
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

 // Facebook sign in
Future<UserCredential?> signInWithFacebook() async {
  try {
    print('Starting Facebook sign-in flow');
    
    // Step 1: Sign in with Facebook - use a try-catch specifically for this part
    LoginResult? result;
    try {
      result = await FacebookAuth.instance.login();
    } catch (e) {
      print('Error in FacebookAuth.login(): $e');
      return null;
    }
    
    if (result.status != LoginStatus.success) {
      print('Facebook sign-in cancelled or failed: ${result.status}');
      return null;
    }
    
    // Safely check access token
    if (result.accessToken == null || result.accessToken!.tokenString.isEmpty) {
      print('Facebook access token is null or empty');
      return null;
    }
    
    // Step 2: Create Firebase credential from Facebook token
    try {
      print('Creating Firebase credential from Facebook token');
      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );
      
      print('Signing in with Firebase using Facebook credentials');
      // Step 3: Sign in with the credential
      try {
        return await _auth.signInWithCredential(credential);
      } catch (e) {
        print('Firebase credential error: $e');
        return null; // Return null instead of throwing
      }
    } catch (e) {
      print('Error creating credentials: $e');
      return null;
    }
  } catch (e) {
    print('Facebook sign-in error: $e');
    return null; // Return null instead of throwing
  }
}
  // Sign out from Firebase
  Future<void> signOut() async {
    try {
      print('Signing out from Google');
      await _googleSignIn.signOut();
      print('Signing out from Facebook');
      await FacebookAuth.instance.logOut();
      print('Signing out from Firebase');
      await _auth.signOut();
    } catch (e) {
      print('Firebase signout error: $e');
      throw Exception('Firebase sign out failed: ${e.toString()}');
    }
  }
}