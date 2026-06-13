import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:habitat/core/constants/app_colors.dart';
import 'package:habitat/core/constants/app_text_styles.dart';
import 'package:habitat/features/auth/providers/auth_provider.dart';
import 'package:habitat/shared/widgets/app_scaffold.dart';
import 'package:habitat/shared/widgets/primary_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _dailyReminder = true;
  bool _soundEnabled = true;
  bool _darkMode = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _handleDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Account', style: AppTextStyles.cardTitle.copyWith(color: AppColors.error)),
        content: Text('Are you sure you want to permanently delete your account? This action is irreversible and all habit data will be destroyed.', style: AppTextStyles.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final success = await ref.read(authProvider.notifier).deleteAccount();
              if (success && mounted) {
                context.go('/');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Delete Account', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Get initials for profile avatar
    String initials = "U";
    if (user != null && user.name.isNotEmpty) {
      final parts = user.name.split(' ');
      if (parts.length > 1) {
        initials = (parts[0][0] + parts[1][0]).toUpperCase();
      } else {
        initials = parts[0][0].toUpperCase();
      }
    }

    return AppScaffold(
      useSafeArea: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Info Row
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      initials,
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'mock_user_${user?.id.hashCode}@habitat.com',
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (mounted) {
                        context.go('/');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Settings Header Title
              Text(
                'Reminders & Interface',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 12),
              
              // Settings card (toggles)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    // Daily reminders toggle
                    _buildToggleItem(
                      title: 'Daily Reminders',
                      value: _dailyReminder,
                      onChanged: (val) => setState(() => _dailyReminder = val),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    // Choose time tile
                    ListTile(
                      enabled: _dailyReminder,
                      title: Text(
                        'Reminder Time',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: _dailyReminder ? AppColors.textPrimary : AppColors.primaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _reminderTime.format(context),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _dailyReminder ? AppColors.primary : AppColors.textHint,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: _selectTime,
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    // Sound effects toggle
                    _buildToggleItem(
                      title: 'Sound Notifications',
                      value: _soundEnabled,
                      onChanged: (val) => setState(() => _soundEnabled = val),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    // Dark mode toggle
                    _buildToggleItem(
                      title: 'Dark Mode (Beta)',
                      value: _darkMode,
                      onChanged: (val) {
                        setState(() => _darkMode = val);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Dark mode theme will be available in v1.1 release!")),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Other Settings Section
              Text(
                'Other',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildResourceItem('Privacy Policy'),
                    const Divider(height: 1, color: AppColors.border),
                    _buildResourceItem('Terms of Service'),
                    const Divider(height: 1, color: AppColors.border),
                    _buildResourceItem('Rate App'),
                    const Divider(height: 1, color: AppColors.border),
                    _buildResourceItem('Share Habitat App'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Account Management / Deletion Section
              ExpansionTile(
                title: Text(
                  'Manage Account',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textHint,
                  ),
                ),
                shape: Border.all(color: Colors.transparent),
                collapsedShape: Border.all(color: Colors.transparent),
                childrenPadding: const EdgeInsets.only(bottom: 24),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dangerous Actions',
                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Deleting your account will delete all historical logs, habit streaks, custom playbooks, and profile details.',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 48,
                          child: PrimaryButton(
                            label: 'Delete Account',
                            backgroundColor: AppColors.error,
                            onPressed: _handleDeleteAccount,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: CupertinoSwitch(
        value: value,
        activeColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildResourceItem(String title) {
    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Opening $title...")),
        );
      },
    );
  }
}
