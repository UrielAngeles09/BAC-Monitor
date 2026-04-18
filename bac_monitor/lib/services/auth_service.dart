import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // EMAIL SIGN UP
  Future<User?> signUp(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-input',
          message: 'Email and password cannot be empty',
        );
      }

      if (password.length < 6) {
        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Password must be at least 6 characters',
        );
      }

      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException (Sign Up): ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("Error during sign up: $e");
      rethrow;
    }
  }

  // EMAIL LOGIN
  Future<User?> signIn(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-input',
          message: 'Email and password cannot be empty',
        );
      }

      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException (Sign In): ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("Error during sign in: $e");
      rethrow;
    }
  }

  // GOOGLE SIGN IN
  Future<User?> signInWithGoogle() async {
    try {
      print("Starting Google Sign In...");

      // Sign out first to allow account selection
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print("Google sign in cancelled by user");
        return null;
      }

      print("Google user signed in: ${googleUser.email}");

      final googleAuth = await googleUser.authentication;

      print("Got Google authentication token");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      
      print("Firebase sign in successful: ${result.user?.email}");
      
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException (Google Sign In): ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("Error during Google sign in: $e");
      rethrow;
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print("Sign out successful");
    } catch (e) {
      print("Error during sign out: $e");
      rethrow;
    }
  }

  // CURRENT USER
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // CHECK IF USER IS LOGGED IN
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // GET CURRENT USER EMAIL
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }
}