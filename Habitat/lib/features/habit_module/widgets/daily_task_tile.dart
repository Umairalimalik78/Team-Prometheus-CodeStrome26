import 'package:flutter/material.dart';
import 'package:habitat/core/constants/app_colors.dart';
import 'package:habitat/core/constants/app_text_styles.dart';
import 'package:habitat/features/habit_module/models/habit_module_model.dart';

class DailyTaskTile extends StatelessWidget {
  final DailyTask task;
  final bool isToday;
  final bool isCompleted;

  const DailyTaskTile({
    super.key,
    required this.task,
    required this.isToday,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isToday ? AppColors.surface : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday ? AppColors.primary : AppColors.border,
          width: isToday ? 1.5 : 1.0,
        ),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left Day Indicator
            Container(
              width: 50,
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.primary
                    : (isCompleted ? AppColors.success.withOpacity(0.1) : AppColors.inputBg),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'D${task.day}',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isToday
                      ? Colors.white
                      : (isCompleted ? AppColors.success : AppColors.textSecondary),
                ),
              ),
            ),
            // Middle Task Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      task.task,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: AppColors.textPrimary,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.tip.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.tip,
                        style: AppTextStyles.caption.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Right Checkmark
            if (isCompleted)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
              ),
          ],
        ),
      ),
    );
  }
}
