import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../features/habit_module/providers/habit_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ref.watch(habitProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Home'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(backgroundColor: AppColors.border, child: const Text('JD')),
          )
        ],
      ),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => GoRouter.of(context).go('/chat'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good morning, John.', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text('You have ${modules.length} active habit(s).', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final m = modules[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircularPercentIndicator(radius: 36, lineWidth: 5, percent: 0.48, center: const Icon(Icons.spa), progressColor: AppColors.primary),
                        title: Text(m.habitName),
                        subtitle: Text(m.whyItMatters),
                        onTap: () => GoRouter.of(context).go('/habit/${m.id}'),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
