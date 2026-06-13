import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habitat/core/constants/app_colors.dart';
import 'package:habitat/core/constants/app_text_styles.dart';
import 'package:habitat/core/services/supabase_service.dart';
import 'package:habitat/features/auth/providers/auth_provider.dart';
import 'package:habitat/features/dashboard/providers/dashboard_provider.dart';
import 'package:habitat/features/dashboard/widgets/habit_card.dart';
import 'package:habitat/features/habit_module/models/habit_module_model.dart';
import 'package:habitat/shared/widgets/app_scaffold.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedTab = 'Active'; // 'Active' | 'Completed' | 'All'

  @override
  void initState() {
    super.initState();
    // Refresh list on open
    Future.microtask(() {
      ref.read(dashboardProvider.notifier).refresh();
    });
  }

  Widget _buildTabBar() {
    final tabs = ['Active', 'Completed', 'All'];
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  tab,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textHint,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHabitsList(List<HabitModuleModel> habits) {
    // Filter list
    final filteredHabits = habits.where((h) {
      if (_selectedTab == 'Active') {
        return h.status == 'active' || h.status == 'restarted';
      } else if (_selectedTab == 'Completed') {
        return h.status == 'completed';
      }
      return true; // All
    }).toList();

    if (filteredHabits.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.spa_outlined,
                size: 48,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedTab == 'Completed'
                  ? 'No completed habits yet.'
                  : 'Start building sustainable habits.',
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTab == 'Completed'
                  ? 'Consistency will get you here.'
                  : 'Tap the button below to interview your AI Coach.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredHabits.length,
      itemBuilder: (context, index) {
        final habit = filteredHabits[index];
        
        // FutureBuilder to load the logged completed dates count
        return FutureBuilder<List<DateTime>>(
          future: SupabaseService.instance.getCompletedDates(habit.id),
          builder: (context, snapshot) {
            final int completedDays = snapshot.data?.length ?? 0;
            return HabitCard(
              habit: habit,
              completedDays: completedDays,
              onTap: () => context.push('/habit/${habit.id}'),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final dashboardState = ref.watch(dashboardProvider);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: GestureDetector(
          onTap: () {
            // Dropdown Switching (Tiro-style visual folder menu)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Habitat workspace folders: Personal (Active)"),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Home',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.textPrimary),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.border,
                child: Text(
                  initials,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Greeting text
                Text(
                  'Good morning, ${user?.name ?? 'User'}.',
                  style: AppTextStyles.screenTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                dashboardState.habits.when(
                  data: (list) {
                    final activeCount = list.where((h) => h.status == 'active' || h.status == 'restarted').length;
                    return Text(
                      'You have $activeCount active habit${activeCount == 1 ? '' : 's'}.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    );
                  },
                  error: (_, __) => const SizedBox(),
                  loading: () => const SizedBox(),
                ),
                const SizedBox(height: 24),
                
                // Main Container Card holding tabs + list
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTabBar(),
                      const SizedBox(height: 16),
                      dashboardState.habits.when(
                        data: (list) => _buildHabitsList(list),
                        error: (err, _) => Container(
                          padding: const EdgeInsets.all(24),
                          alignment: Alignment.center,
                          child: Text('Error loading habits: $err'),
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Quick Actions Section (Tiro-style)
                Text(
                  'Quick Actions',
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
                      _buildQuickActionItem(
                        icon: Icons.add_box_outlined,
                        title: 'Start New Habit',
                        onTap: () => context.push('/chat/new'),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _buildQuickActionItem(
                        icon: Icons.calendar_month_outlined,
                        title: "Check Progress",
                        onTap: () => setState(() => _selectedTab = 'All'),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _buildQuickActionItem(
                        icon: Icons.person_outline,
                        title: 'Go to Profile',
                        onTap: () => context.push('/profile'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48), // Padding bottom spacing
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/chat/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Tiro-style slightly rounded square FAB
        ),
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
