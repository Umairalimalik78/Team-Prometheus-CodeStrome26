import 'package:flutter/material.dart';
import 'package:habitat/core/constants/app_colors.dart';
import 'package:habitat/core/constants/app_text_styles.dart';
import 'package:habitat/features/habit_module/models/habit_module_model.dart';

class HabitCard extends StatelessWidget {
  final HabitModuleModel habit;
  final int completedDays;
  final VoidCallback onTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.completedDays,
    required this.onTap,
  });

  String _getPhaseName(int phase) {
    switch (phase) {
      case 1:
        return 'Phase 1: High';
      case 2:
        return 'Phase 2: Mod';
      case 3:
        return 'Phase 3: Red';
      case 4:
        return 'Phase 4: Tape';
      case 5:
        return 'Autonomous';
      default:
        return 'Active';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (completedDays / 25).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Accent Bar (Tiro-style)
              Container(
                width: 4,
                color: habit.status == 'completed' ? AppColors.success : AppColors.primary,
              ),
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: Title + Phase Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                habit.habitName,
                                style: AppTextStyles.cardTitle.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Phase Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: habit.status == 'completed'
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.inputBg,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                _getPhaseName(habit.phase),
                                style: AppTextStyles.caption.copyWith(
                                  color: habit.status == 'completed'
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Row 2: Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              habit.status == 'completed' ? AppColors.success : AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Row 3: Streak + Completion
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Streak Count
                            Row(
                              children: [
                                const Text('🔥', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 4),
                                Text(
                                  '${habit.streakCount} day streak',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryWarm,
                                  ),
                                ),
                              ],
                            ),
                            // Day ratio
                            Text(
                              'Day $completedDays/25',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textHint,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
