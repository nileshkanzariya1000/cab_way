import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Function to handle Google sign-in
  Future<void> signIn() async {
    try {
      final GoogleSignInAccount? user = await _googleSignIn.signIn();
      if (user != null) {
        // Handle sign-in success (user object contains user info)
        print('Signed in as: ${user.displayName}');
        // You might want to return user info or navigate to another screen here
      }
    } catch (error) {
      print('Google sign-in error: $error');
      // Handle sign-in error
    }
  }

  // Function to handle Google sign-out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      print('Signed out');
    } catch (error) {
      print('Google sign-out error: $error');
      // Handle sign-out error
    }
  }
}
