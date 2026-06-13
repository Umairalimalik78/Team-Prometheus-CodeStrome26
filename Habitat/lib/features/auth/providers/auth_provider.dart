import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitat/core/services/supabase_service.dart';
import 'package:habitat/features/auth/models/user_model.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool showOnboarding;
  final String? errorMessage;

  AuthState({
    this.user,
    this.isLoading = true,
    this.showOnboarding = false,
    this.errorMessage,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? showOnboarding,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      showOnboarding: showOnboarding ?? this.showOnboarding,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await SupabaseService.instance.getCurrentUser();
      final prefs = await SharedPreferences.getInstance();
      
      // Onboarding flag is specific to the user
      bool showOnboarding = false;
      if (user != null) {
        showOnboarding = prefs.getBool('show_onboarding_${user.id}') ?? true;
      }

      state = AuthState(
        user: user,
        isLoading: false,
        showOnboarding: showOnboarding,
      );
    } catch (e) {
      state = AuthState(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await SupabaseService.instance.login(email, password);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final showOnboarding = prefs.getBool('show_onboarding_${user.id}') ?? false; // only show to fresh signups by default, or true if never seen
        state = AuthState(
          user: user,
          isLoading: false,
          showOnboarding: showOnboarding,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: "Invalid login credentials.");
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signup(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await SupabaseService.instance.signup(email, password, name);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        // New users always see onboarding
        await prefs.setBool('show_onboarding_${user.id}', true);
        
        state = AuthState(
          user: user,
          isLoading: false,
          showOnboarding: true,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, errorMessage: "Signup failed.");
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> completeOnboarding() async {
    if (state.user == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('show_onboarding_${state.user!.id}', false);
      state = state.copyWith(showOnboarding: false);
    } catch (e) {
      debugPrint("Error completing onboarding: $e");
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await SupabaseService.instance.logout();
      state = AuthState(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> deleteAccount() async {
    if (state.user == null) return false;
    final userId = state.user!.id;
    state = state.copyWith(isLoading: true);
    try {
      await SupabaseService.instance.deleteAccount(userId);
      state = AuthState(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
