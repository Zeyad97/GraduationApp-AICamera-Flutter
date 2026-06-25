import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _errorMessage;
  bool _hasSeenOnboarding = false;

  final SharedPreferences _prefs;
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService.instance;
  final DatabaseService _database = DatabaseService.instance;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  AuthProvider(this._prefs) {
    _loadOnboardingStatus();
    _checkLoggedInUser();
  }

  // ========== INITIALIZATION ==========
  void _loadOnboardingStatus() {
    _hasSeenOnboarding = _prefs.getBool('hasSeenOnboarding') ?? false;
  }

  Future<void> _checkLoggedInUser() async {
    final userId = _prefs.getString('currentUserId');
    if (userId != null && _firebaseAuth.isLoggedIn) {
      // Restore user from local cache or Firebase
      _currentUser = await _database.getUserById(userId);
      _isLoggedIn = _currentUser != null;
      notifyListeners();
    }
  }

  // ========== REGISTRATION ==========
  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _firebaseAuth.registerWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      if (user != null) {
        // Save to local database as fallback
        await _database.insertUser(user);

        _currentUser = user;
        _isLoggedIn = true;

        // Save session
        await _prefs.setString('currentUserId', user.id);
        await _prefs.setString('userEmail', user.email);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = _parseErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ========== LOGIN ==========
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _firebaseAuth.loginWithEmail(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;

        // Save session
        await _prefs.setString('currentUserId', user.id);
        await _prefs.setString('userEmail', user.email);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = _parseErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ========== GOOGLE SIGN-IN ==========
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _firebaseAuth.signInWithGoogle();

      if (user != null) {
        // Check if user exists in local DB, if not create
        var localUser = await _database.getUserById(user.id);
        if (localUser == null) {
          await _database.insertUser(user);
        }

        _currentUser = user;
        _isLoggedIn = true;

        // Save session
        await _prefs.setString('currentUserId', user.id);
        await _prefs.setString('userEmail', user.email);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = _parseErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ========== LOGOUT ==========
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseAuth.logout();

      _currentUser = null;
      _isLoggedIn = false;

      // Clear session
      await _prefs.remove('currentUserId');
      await _prefs.remove('userEmail');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = _parseErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== ONBOARDING ==========
  Future<void> completeOnboarding() async {
    await _prefs.setBool('hasSeenOnboarding', true);
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  // ========== HELPER METHODS ==========
  String _parseErrorMessage(String error) {
    if (error.contains('email-already-in-use')) {
      return 'This email is already registered';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak';
    } else if (error.contains('user-not-found')) {
      return 'User not found';
    } else if (error.contains('wrong-password')) {
      return 'Invalid password';
    } else if (error.contains('too-many-requests')) {
      return 'Too many login attempts. Please try later';
    }
    return 'An error occurred. Please try again';
  }

  Future<void> clearError() async {
    _errorMessage = null;
    notifyListeners();
  }
}
