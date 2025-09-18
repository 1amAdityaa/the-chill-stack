import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;
import '../services/supabase_auth_service.dart';

class SupabaseAuthProvider with ChangeNotifier {
  final SupabaseAuthService _authService = SupabaseAuthService();

  app_user.User? _user;
  bool _isLoading = false;
  String? _error;

  app_user.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  SupabaseAuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        await _loadUserProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        notifyListeners();
      }
    });

    // Check if user is already signed in
    if (_authService.currentUser != null) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    if (_authService.currentUser != null) {
      _user = await _authService.getUserProfile(_authService.currentUser!.id);
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required app_user.User userData,
  }) async {
    _setLoading(true);
    try {
      await _authService.signUp(
        email: email,
        password: password,
        userData: userData.toSupabaseJson(),
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _authService.signIn(email: email, password: password);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Update user profile
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (_user == null) return;

    _setLoading(true);
    try {
      await _authService.updateUserProfile(_user!.id, updates);
      await _loadUserProfile(); // Reload profile to get updated data
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
