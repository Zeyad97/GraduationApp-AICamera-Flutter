import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  final SharedPreferences _prefs;
  UserModel? _currentUser;
  bool _isLoading = false;

  AuthProvider(this._prefs) {
    _loadCurrentUser();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get hasSeenOnboarding => _prefs.getBool(_hasSeenOnboardingKey) ?? false;

  Future<void> _loadCurrentUser() async {
    final isLoggedIn = _prefs.getBool(_isLoggedInKey) ?? false;
    if (isLoggedIn) {
      final userId = _prefs.getString(_userIdKey);
      if (userId != null) {
        _currentUser = await DatabaseService.instance.getUserById(userId);
        notifyListeners();
      }
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    String? profileImage,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if email already exists
      final existingUser = await DatabaseService.instance.getUserByEmail(email);
      if (existingUser != null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: fullName,
        email: email,
        password: password, // In production, hash this!
        phoneNumber: phoneNumber,
        profileImage: profileImage,
        createdAt: DateTime.now(),
      );

      await DatabaseService.instance.insertUser(user);
      await _setLoggedIn(user);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await DatabaseService.instance.getUserByEmail(email);
      if (user != null && user.password == password) {
        await _setLoggedIn(user);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _setLoggedIn(UserModel user) async {
    _currentUser = user;
    await _prefs.setBool(_isLoggedInKey, true);
    await _prefs.setString(_userIdKey, user.id);
  }

  Future<void> logout() async {
    _currentUser = null;
    await _prefs.setBool(_isLoggedInKey, false);
    await _prefs.remove(_userIdKey);
    notifyListeners();
  }

  Future<void> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? profileImage,
  }) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber,
      profileImage: profileImage,
    );

    await DatabaseService.instance.updateUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }

  Future<void> markOnboardingAsSeen() async {
    await _prefs.setBool(_hasSeenOnboardingKey, true);
    notifyListeners();
  }
}
