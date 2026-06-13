import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitat/core/constants/app_colors.dart';
import 'package:habitat/core/constants/app_text_styles.dart';
import 'package:habitat/features/auth/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _checkNavigation();
      }
    });
  }

  void _checkNavigation() {
    final authState = ref.read(authProvider);
    if (authState.isLoading) {
      // If still loading auth state, wait another 500ms and check again
      Timer(const Duration(milliseconds: 500), _checkNavigation);
      return;
    }

    final loggedIn = authState.user != null;
    if (!loggedIn) {
      context.go('/login');
    } else {
      if (authState.showOnboarding) {
        context.go('/onboarding');
      } else {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Icon Box (Tiro-inspired)
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.spa_rounded, // Fallback organic leaf/plant icon
                      color: Colors.white,
                      size: 40,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Brand Name
            Text(
              'Habitat',
              style: AppTextStyles.appName.copyWith(
                color: AppColors.primary,
                fontSize: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
