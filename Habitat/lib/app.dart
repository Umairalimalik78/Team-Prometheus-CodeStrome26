import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:habitat/core/constants/app_colors.dart';
import 'package:habitat/features/auth/screens/login_screen.dart';
import 'package:habitat/features/auth/screens/signup_screen.dart';
import 'package:habitat/features/auth/providers/auth_provider.dart';
import 'package:habitat/features/onboarding/screens/splash_screen.dart';
import 'package:habitat/features/onboarding/screens/onboarding_screen.dart';
import 'package:habitat/features/dashboard/screens/dashboard_screen.dart';
import 'package:habitat/features/chat/screens/chat_screen.dart';
import 'package:habitat/features/habit_module/screens/habit_detail_screen.dart';
import 'package:habitat/features/habit_module/screens/checkin_screen.dart';
import 'package:habitat/features/profile/screens/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = authState.user != null;
      final goingToLogin = state.matchedLocation == '/login';
      final goingToSignup = state.matchedLocation == '/signup';
      final goingToSplash = state.matchedLocation == '/';

      // If checking auth state (initializing), wait on splash
      if (authState.isLoading && goingToSplash) {
        return null;
      }

      if (!loggedIn) {
        // Not logged in: allow access to login/signup or splash, else redirect to login
        if (goingToLogin || goingToSignup || goingToSplash) {
          return null;
        }
        return '/login';
      }

      // Logged in: redirect from splash, login, or signup to onboarding or dashboard
      if (goingToSplash || goingToLogin || goingToSignup) {
        final showOnboarding = authState.showOnboarding;
        if (showOnboarding) {
          return '/onboarding';
        }
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/chat/:moduleId',
        builder: (context, state) {
          final moduleId = state.pathParameters['moduleId'] ?? 'new';
          return ChatScreen(moduleId: moduleId);
        },
      ),
      GoRoute(
        path: '/habit/:moduleId',
        builder: (context, state) {
          final moduleId = state.pathParameters['moduleId']!;
          return HabitDetailScreen(moduleId: moduleId);
        },
      ),
      GoRoute(
        path: '/checkin/:moduleId',
        builder: (context, state) {
          final moduleId = state.pathParameters['moduleId']!;
          return CheckinScreen(moduleId: moduleId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

class HabitatApp extends ConsumerWidget {
  const HabitatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Habitat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.primaryWarm,
          background: AppColors.background,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        textTheme: GoogleFonts.dmSansTextTheme(Theme.of(context).textTheme).copyWith(
          titleLarge: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
