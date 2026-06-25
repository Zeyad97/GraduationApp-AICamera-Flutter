import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class FirebaseAuthService {
  static final FirebaseAuthService instance = FirebaseAuthService._init();
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirestoreService _firestore = FirestoreService.instance;

  FirebaseAuthService._init();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // ========== EMAIL/PASSWORD AUTHENTICATION ==========
  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final userModel = UserModel(
          id: userCredential.user!.uid,
          fullName: fullName,
          email: email,
          password: '', // Don't store password
          phoneNumber: phoneNumber,
          profileImage: null,
          createdAt: DateTime.now(),
        );

        // Save to Firestore
        await _firestore.saveUser(userModel);

        // Update Firebase user display name
        await userCredential.user!.updateDisplayName(fullName);
        await userCredential.user!.updatePhotoURL(null);

        return userModel;
      }
    } catch (e) {
      print('Error registering with email: $e');
      rethrow;
    }
    return null;
  }

  Future<UserModel?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Get user data from Firestore
        return await _firestore.getUserById(userCredential.user!.uid);
      }
    } catch (e) {
      print('Error logging in with email: $e');
      rethrow;
    }
    return null;
  }

  // ========== GOOGLE SIGN-IN ==========
  Future<UserModel?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final user = userCredential.user!;

        // Check if user already exists in Firestore
        var existingUser = await _firestore.getUserById(user.uid);

        if (existingUser == null) {
          // Create new user
          final newUser = UserModel(
            id: user.uid,
            fullName: user.displayName ?? 'User',
            email: user.email ?? '',
            password: '', // Not stored
            phoneNumber: '', // Empty initially
            profileImage: user.photoURL,
            createdAt: DateTime.now(),
          );

          await _firestore.saveUser(newUser);
          return newUser;
        }

        return existingUser;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
    return null;
  }

  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // ========== LOGOUT ==========
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error logging out: $e');
      rethrow;
    }
  }

  // ========== PASSWORD RESET ==========
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }

  // ========== SESSION STATE ==========
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isLoggedIn => _auth.currentUser != null;
}
