import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitat/core/constants/app_colors.dart';
import 'package:habitat/core/constants/app_text_styles.dart';
import 'package:habitat/features/auth/providers/auth_provider.dart';
import 'package:habitat/shared/widgets/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _showCredentials = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final success = await ref.read(authProvider.notifier).login(email, password);
    if (!success && mounted) {
      final error = ref.read(authProvider).errorMessage ?? "Login failed";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleMockGoogle() async {
    // Authenticate with a mock google account
    final success = await ref.read(authProvider.notifier).login("google_user@gmail.com", "google_password_123");
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Logged in with Google (Demo Mode)"),
          backgroundColor: AppColors.success,
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
          // Full-screen nature background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/nature_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback elegant gradient if image fails
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryMed, AppColors.primary],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                );
              },
            ),
          ),
          // Semi-transparent dark overlay (gradient)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top back button if credentials form is visible
                          Align(
                            alignment: Alignment.topLeft,
                            child: _showCredentials
                                ? IconButton(
                                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                                    onPressed: () => setState(() => _showCredentials = false),
                                  )
                                : const SizedBox(height: 48),
                          ),
                          // Brand Center Logo & Tagline
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        'assets/images/logo.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(
                                          Icons.spa_rounded,
                                          color: AppColors.primary,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Habitat',
                                    style: AppTextStyles.appName.copyWith(
                                      color: Colors.white,
                                      fontSize: 32,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Build habits that stick.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Bottom Options or Credentials Form
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!_showCredentials) ...[
                                // Google Sign In Button
                                SizedBox(
                                  height: 54,
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _handleMockGoogle,
                                    icon: const Icon(Icons.g_mobiledata_rounded, size: 36, color: AppColors.textPrimary),
                                    label: Text(
                                      'Continue with Google',
                                      style: AppTextStyles.buttonText.copyWith(color: AppColors.textPrimary),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.textPrimary,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Email Sign In Button
                                SizedBox(
                                  height: 54,
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => setState(() => _showCredentials = true),
                                    icon: const Icon(Icons.email_outlined, size: 22, color: AppColors.textPrimary),
                                    label: Text(
                                      'Continue with Email',
                                      style: AppTextStyles.buttonText.copyWith(color: AppColors.textPrimary),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.textPrimary,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No card required · Start for free',
                                  style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.8)),
                                ),
                                const SizedBox(height: 24),
                              ] else ...[
                                // Credentials Form
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
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
                                      const SizedBox(height: 16),
                                      // Login Button
                                      PrimaryButton(
                                        label: 'Log In',
                                        onPressed: _handleLogin,
                                        isLoading: authState.isLoading,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ],
                              // Signup Navigation Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.go('/signup'),
                                    child: Text(
                                      'Sign Up',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primaryLight,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Fine print
                              Text(
                                'By continuing you agree to Terms & Privacy Policy',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
