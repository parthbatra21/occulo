import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthState { authenticated, unauthenticated, loading }

class StateChecker with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthState _authState = AuthState.loading;
  User? _user;
  String _userType = '';

  StateChecker() {
    checkAuthState();
  }

  AuthState get authState => _authState;
  User? get user => _user;
  String get userType => _userType;

  // Check if user is authenticated and get user type from shared preferences
  Future<void> checkAuthState() async {
    _authState = AuthState.loading;
    notifyListeners();

    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) async {
      _user = user;

      if (user != null) {
        // User is logged in
        await _getUserType();
        _authState = AuthState.authenticated;
      } else {
        // User is not logged in
        _authState = AuthState.unauthenticated;
        _userType = '';
      }

      notifyListeners();
    });
  }

  // Get user type from shared preferences
  Future<void> _getUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userType = prefs.getString('userType') ?? '';
    } catch (e) {
      debugPrint('Error getting user type: $e');
      _userType = '';
    }
  }

  // Save user type to shared preferences
  Future<void> saveUserType(String userType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userType', userType);
      _userType = userType;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving user type: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Auth state changes listener will handle the state update
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}
