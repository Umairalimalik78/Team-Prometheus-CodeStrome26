import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../features/habit_module/providers/habit_provider.dart';

class HabitDetailScreen extends ConsumerWidget {
  final String moduleId;

  const HabitDetailScreen({Key? key, required this.moduleId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(habitProvider);
    final module = modules.firstWhere(
      (element) => element.id == moduleId,
      orElse: () => demoHabitModule,
    );

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Habit Detail')),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(module.habitName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Why it matters: ${module.whyItMatters}'),
              ),
            ),
            const SizedBox(height: 16),
            Text('Goal', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 6),
            Text(module.goalDescription, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            if (module.todayTask != null) ...[
              Text('Today', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 6),
              Card(
                color: AppColors.inputBg,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Day ${module.todayTask!['day'] ?? 1}', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 4),
                      Text(module.todayTask!['task']?.toString() ?? '', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 6),
                      Text(module.todayTask!['tip']?.toString() ?? '', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text('Blockers', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 6),
            if (module.blockers.isEmpty)
              Text('No blockers listed yet.', style: Theme.of(context).textTheme.bodyMedium)
            else ...module.blockers.map((text) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text('• $text', style: Theme.of(context).textTheme.bodyMedium),
                )),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                minimumSize: const Size.fromHeight(54),
              ),
              child: const Text('Mark Today Done'),
            )
          ],
        ),
      ),
    );
  }
}
