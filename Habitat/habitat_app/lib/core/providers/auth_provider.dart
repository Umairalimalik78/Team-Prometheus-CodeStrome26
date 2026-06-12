import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  Future<void> signInMock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mock_signed_in', true);
    state = true;
  }

  Future<void> signOut() async {
    if (SupabaseService.initialized) {
      await Supabase.instance.client.auth.signOut();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mock_signed_in');
    state = false;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    if (SupabaseService.initialized) {
      final response = await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      if (response.session != null) {
        state = true;
        return true;
      }
      return false;
    }

    await signInMock();
    return true;
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    if (SupabaseService.initialized) {
      final response = await Supabase.instance.client.auth.signUp(email: email, password: password);
      return response.user != null;
    }

    await signInMock();
    return true;
  }

  Future<void> restore() async {
    if (SupabaseService.initialized) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        state = true;
        return;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('mock_signed_in') ?? false;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  final notifier = AuthNotifier();
  notifier.restore();
  return notifier;
});
