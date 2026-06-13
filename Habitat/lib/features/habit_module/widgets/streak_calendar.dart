import 'package:flutter/material.dart';
import 'package:habitat/core/constants/app_colors.dart';
import 'package:habitat/core/constants/app_text_styles.dart';

class StreakCalendar extends StatelessWidget {
  final DateTime startDate;
  final List<DateTime> completedDates;

  const StreakCalendar({
    super.key,
    required this.startDate,
    required this.completedDates,
  });

  @override
  Widget build(BuildContext context) {
    // Determine what program day today is (1-indexed, clamp to 1-25)
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final habitStart = DateTime(startDate.year, startDate.month, startDate.day);
    final daysDifference = todayStart.difference(habitStart).inDays;
    final int todayProgramDay = (daysDifference + 1).clamp(1, 25);

    // Convert completedDates to date strings for easy matching
    final completedStrings = completedDates
        .map((d) => DateTime(d.year, d.month, d.day).toIso8601String().split('T')[0])
        .toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Streak Calendar',
          style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 25,
          itemBuilder: (context, index) {
            final dayNumber = index + 1;
            final itemDate = habitStart.add(Duration(days: index));
            final itemDateString = itemDate.toIso8601String().split('T')[0];

            final bool isCompleted = completedStrings.contains(itemDateString);
            final bool isToday = dayNumber == todayProgramDay;
            final bool isPast = dayNumber < todayProgramDay;
            final bool isFuture = dayNumber > todayProgramDay;

            // Box styling
            Color bgColor = Colors.white;
            Border border = Border.all(color: AppColors.border);
            Widget? child;

            if (isCompleted) {
              bgColor = AppColors.success;
              border = Border.all(color: Colors.transparent);
              child = const Icon(Icons.check, color: Colors.white, size: 20);
            } else if (isPast) {
              bgColor = AppColors.inputBg;
              border = Border.all(color: Colors.transparent);
              child = Text(
                '$dayNumber',
                style: AppTextStyles.caption.copyWith(color: AppColors.textHint, fontWeight: FontWeight.bold),
              );
            } else if (isToday) {
              bgColor = Colors.white;
              border = Border.all(color: AppColors.primary, width: 2);
              child = Text(
                '$dayNumber',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            } else if (isFuture) {
              bgColor = Colors.white;
              border = Border.all(color: AppColors.border);
              child = Text(
                '$dayNumber',
                style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
              );
            }

            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bgColor,
                border: border,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isToday && !isCompleted
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.15),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: child,
            );
          },
        ),
      ],
    );
  }
}
