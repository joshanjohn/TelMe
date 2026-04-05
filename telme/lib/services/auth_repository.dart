import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telme/models/profile_model.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  
  User? get currentUser => _supabase.auth.currentUser;

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role.name,
      },
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<Profile?> getProfile(String id) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', id)
        .single();
    return Profile.fromJson(response);
  }

  Future<List<Profile>> getAllProfiles() async {
    final response = await _supabase
        .from('profiles')
        .select()
        .order('full_name');
    return (response as List).map((json) => Profile.fromJson(json)).toList();
  }
}
