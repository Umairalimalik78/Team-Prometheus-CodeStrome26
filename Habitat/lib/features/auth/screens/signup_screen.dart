import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habitat/core/constants/app_colors.dart';
import 'package:habitat/core/constants/app_text_styles.dart';
import 'package:habitat/features/auth/providers/auth_provider.dart';
import 'package:habitat/shared/widgets/primary_button.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await ref.read(authProvider.notifier).signup(email, password, name);
    if (!success && mounted) {
      final error = ref.read(authProvider).errorMessage ?? "Signup failed";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Nature image
          Positioned.fill(
            child: Image.asset(
              'assets/images/nature_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.primary,
                );
              },
            ),
          ),
          // Dark transparent overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          // Scrollable layout container
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header logo top padding
                      Padding(
                        padding: const EdgeInsets.only(top: 64.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.spa_rounded,
                                        color: AppColors.primary,
                                        size: 26,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Habitat',
                                  style: AppTextStyles.appName.copyWith(
                                    color: Colors.white,
                                    fontSize: 28,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // White sheet card at bottom
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 15,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Create Account',
                                style: AppTextStyles.screenTitle.copyWith(
                                  fontSize: 24,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Start building sustainable habits today.',
                                style: AppTextStyles.bodyMedium,
                              ),
                              const SizedBox(height: 20),
                              // Name field
                              TextFormField(
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Full Name',
                                  hintStyle: AppTextStyles.caption,
                                  filled: true,
                                  fillColor: AppColors.inputBg,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Enter your name';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: AppTextStyles.caption,
                                  filled: true,
                                  fillColor: AppColors.inputBg,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Enter your email';
                                  if (!val.contains('@')) return 'Enter a valid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle: AppTextStyles.caption,
                                  filled: true,
                                  fillColor: AppColors.inputBg,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Enter your password';
                                  if (val.length < 6) return 'Password must be at least 6 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              // Signup Action Button
                              PrimaryButton(
                                label: 'Create Account',
                                onPressed: _handleSignup,
                                isLoading: authState.isLoading,
                              ),
                              const SizedBox(height: 20),
                              // Navigate back to Login
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.go('/login'),
                                    child: Text(
                                      'Log In',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primaryWarm,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
