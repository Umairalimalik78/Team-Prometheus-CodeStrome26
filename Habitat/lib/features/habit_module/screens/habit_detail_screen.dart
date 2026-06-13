import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:habitat/core/constants/app_colors.dart';
import 'package:habitat/core/constants/app_text_styles.dart';
import 'package:habitat/core/services/supabase_service.dart';
import 'package:habitat/core/services/notification_service.dart';
import 'package:habitat/features/dashboard/providers/dashboard_provider.dart';
import 'package:habitat/features/habit_module/models/habit_module_model.dart';
import 'package:habitat/features/habit_module/widgets/streak_calendar.dart';
import 'package:habitat/features/habit_module/widgets/daily_task_tile.dart';
import 'package:habitat/shared/widgets/app_scaffold.dart';
import 'package:habitat/shared/widgets/primary_button.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final String moduleId;

  const HabitDetailScreen({
    super.key,
    required this.moduleId,
  });

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DateTime> _completedDates = [];
  bool _isLoadingDates = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCompletedDates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCompletedDates() async {
    setState(() => _isLoadingDates = true);
    try {
      final dates = await SupabaseService.instance.getCompletedDates(widget.moduleId);
      setState(() {
        _completedDates = dates;
        _isLoadingDates = false;
      });
    } catch (e) {
      setState(() => _isLoadingDates = false);
    }
  }

  void _toggleTodayDone(bool isAlreadyCompleted) async {
    final today = DateTime.now();
    await ref.read(dashboardProvider.notifier).markHabitDone(widget.moduleId, today, !isAlreadyCompleted);
    
    // Send local demo notification if they completed the habit
    if (!isAlreadyCompleted) {
      final habitsState = ref.read(dashboardProvider).habits.value ?? [];
      final habit = habitsState.firstWhere((h) => h.id == widget.moduleId);
      await NotificationService.instance.showInstantNotification(
        "🎉 Goal Completed!",
        "Great job! You checked off today's plan: ${habit.habitName}.",
        payload: widget.moduleId,
      );
    }

    _loadCompletedDates();
  }

  void _showContextMenu(HabitModuleModel habit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined, color: AppColors.textSecondary),
                title: Text('Share Progress', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sharing options copied to clipboard!")),
                  );
                },
              ),
              const Divider(height: 1, color: AppColors.border),
              
              // Demo checkin simulator trigger
              ListTile(
                leading: const Icon(Icons.psychology_outlined, color: AppColors.primaryWarm),
                title: Text('Simulate Day 21 Check-in (Demo)', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryWarm)),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/checkin/${widget.moduleId}');
                },
              ),
              const Divider(height: 1, color: AppColors.border),

              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: Text('Delete Habit', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  _confirmDelete(habit);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(HabitModuleModel habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete Habit', style: AppTextStyles.cardTitle.copyWith(color: AppColors.error)),
        content: Text('Are you sure you want to delete this habit module? All streaks and progress history will be lost.', style: AppTextStyles.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await ref.read(dashboardProvider.notifier).deleteHabit(widget.moduleId);
              if (mounted) {
                context.go('/dashboard');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Delete', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(HabitModuleModel habit) {
    final today = DateTime.now();
    final todayString = today.toIso8601String().split('T')[0];
    final bool isTodayCompleted = _completedDates.any((d) => d.toIso8601String().split('T')[0] == todayString);

    // Calculate program day today
    final todayStart = DateTime(today.year, today.month, today.day);
    final habitStart = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
    final int todayProgramDay = (todayStart.difference(habitStart).inDays + 1).clamp(1, 25);

    final double completionRatio = (_completedDates.length / 25).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 21-Day Evaluation banner
          if (todayProgramDay >= 21 && habit.status != 'completed')
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryWarm.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryWarm, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🌱', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        'Day 21 Evaluation Ready',
                        style: AppTextStyles.cardTitle.copyWith(color: AppColors.primaryWarm, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your AI Coach is ready to evaluate whether this habit has been fully internalized. Let's do the check-in.",
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: PrimaryButton(
                      label: 'Launch Check-in',
                      backgroundColor: AppColors.primaryWarm,
                      onPressed: () => context.push('/checkin/${widget.moduleId}'),
                    ),
                  ),
                ],
              ),
            ),

          // Progress Circle Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 55.0,
                  lineWidth: 8.0,
                  percent: completionRatio,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '🔥',
                        style: GoogleFonts.dmSans(fontSize: 18),
                      ),
                      Text(
                        '${habit.streakCount}',
                        style: AppTextStyles.screenTitle.copyWith(fontSize: 22, height: 1.1),
                      ),
                    ],
                  ),
                  progressColor: AppColors.primary,
                  backgroundColor: AppColors.inputBg,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress Summary',
                        style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completed: ${_completedDates.length}/25 days',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Phase: Phase ${habit.phase}',
                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Streak Calendar Grid
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: _isLoadingDates
                ? const SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primary)),
                    ),
                  )
                : StreakCalendar(
                    startDate: habit.startDate,
                    completedDates: _completedDates,
                  ),
          ),
          const SizedBox(height: 20),

          // Why it matters container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF7F4),
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                left: BorderSide(color: AppColors.primary, width: 4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WHY IT MATTERS',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '"${habit.whyItMatters}"',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Mark Today Complete Button
          PrimaryButton(
            label: isTodayCompleted ? 'Completed for Today' : 'Mark Today Done',
            icon: isTodayCompleted ? Icons.check_circle : Icons.check_circle_outline,
            backgroundColor: isTodayCompleted ? AppColors.success : AppColors.primary,
            onPressed: () => _toggleTodayDone(isTodayCompleted),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDailyPlanTab(HabitModuleModel habit) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final habitStart = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
    final int todayProgramDay = (todayStart.difference(habitStart).inDays + 1).clamp(1, 25);

    // Date strings for complete logs checking
    final completedStrings = _completedDates
        .map((d) => DateTime(d.year, d.month, d.day).toIso8601String().split('T')[0])
        .toSet();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: habit.dailyPlan.length,
      itemBuilder: (context, index) {
        final task = habit.dailyPlan[index];
        final taskDate = habitStart.add(Duration(days: index));
        final taskDateString = taskDate.toIso8601String().split('T')[0];

        final bool isTaskCompleted = completedStrings.contains(taskDateString);
        final bool isTaskToday = task.day == todayProgramDay;

        return DailyTaskTile(
          task: task,
          isToday: isTaskToday,
          isCompleted: isTaskCompleted,
        );
      },
    );
  }

  Widget _buildTipsTab(HabitModuleModel habit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Environment Design Section
          Text(
            'Environment Design Tips',
            style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'BJ Fogg: Make the cue highly visible and reduce friction.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: habit.envDesignTips.map((tip) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: AppColors.primaryWarm, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tip,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Obstacle Playbook Section
          Text(
            'Obstacle Playbook',
            style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            "If-Then playbooks designed for your blockers.",
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 12),
          ...habit.obstaclePlaybook.map((play) {
            return ExpansionTile(
              shape: Border.all(color: Colors.transparent),
              collapsedShape: Border.all(color: Colors.transparent),
              title: Text(
                'If: "${play.trigger}"',
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              leading: const Icon(Icons.warning_amber_rounded, color: AppColors.error),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.inputBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Then response: ${play.response}',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final habits = dashboardState.habits.value ?? [];

    if (habits.isEmpty) {
      return AppScaffold(
        body: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primary))),
      );
    }

    final habitIndex = habits.indexWhere((h) => h.id == widget.moduleId);
    if (habitIndex == -1) {
      return AppScaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Habit Module not found.', style: AppTextStyles.cardTitle),
              const SizedBox(height: 12),
              PrimaryButton(label: 'Back to Home', onPressed: () => context.go('/dashboard')),
            ],
          ),
        ),
      );
    }

    final habit = habits[habitIndex];

    return AppScaffold(
      useSafeArea: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit.habitName,
              style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Started ${habit.startDate.day}/${habit.startDate.month}',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onPressed: () => _showContextMenu(habit),
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Container(
              height: 42,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(50),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textHint,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Daily Plan'),
                  Tab(text: 'Tips'),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(habit),
                _buildDailyPlanTab(habit),
                _buildTipsTab(habit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
