import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;

class SupabaseAuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );

      // Note: Profile will be created automatically via trigger
      // The trigger will use the userData from raw_user_meta_data
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Get user profile from the new schema
  Future<app_user.User?> getUserProfile(String userId) async {
    try {
      final response =
          await _client.from('profiles').select().eq('id', userId).single();

      return app_user.User.fromSupabaseJson(response);
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> updates) async {
    await _client.from('profiles').update(updates).eq('id', userId);
  }
}
