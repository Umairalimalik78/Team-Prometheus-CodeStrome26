import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitat/core/constants/app_colors.dart';
import 'package:habitat/core/constants/app_text_styles.dart';
import 'package:habitat/features/auth/providers/auth_provider.dart';
import 'package:habitat/shared/widgets/primary_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Talk to Your AI Coach',
      description: 'Habitat conducts a deep intake interview to understand your exact goal, motivation, and personal blockers.',
    ),
    OnboardingPageData(
      icon: Icons.checklist_rounded,
      title: 'Get a Personalized Plan',
      description: 'Receive a fully tailored 25-day roadmap built on behavioral psychology principles (Atomic Habits & Tiny Habits).',
    ),
    OnboardingPageData(
      icon: Icons.local_fire_department_rounded,
      title: 'Build It for Life',
      description: 'Smart notifications taper off as you build autonomy. Verify internalization on Day 21 with a final check-in.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _finishOnboarding() {
    ref.read(authProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentIndex == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Top Bar with Skip button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isLastPage)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'Skip',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 48), // Match height spacing
                ],
              ),
              
              // Carousel PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Large Icon Graphic Container
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: AppColors.border, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Icon(
                            item.icon,
                            size: 80,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Title
                        Text(
                          item.title,
                          style: AppTextStyles.screenTitle.copyWith(
                            fontSize: 24,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            item.description,
                            style: AppTextStyles.bodyLarge.copyWith(
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Dot Indicators & CTA Button
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicators row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isSelected = _currentIndex == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8.0,
                        width: isSelected ? 24.0 : 8.0,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  // Button
                  PrimaryButton(
                    label: isLastPage ? 'Get Started' : 'Next',
                    onPressed: () {
                      if (isLastPage) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;

  OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
