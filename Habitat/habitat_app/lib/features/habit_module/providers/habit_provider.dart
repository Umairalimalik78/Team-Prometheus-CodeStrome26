import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit_module_model.dart';
import '../../../core/services/supabase_service.dart';

final habitProvider = StateNotifierProvider<HabitNotifier, List<HabitModuleModel>>((ref) => HabitNotifier());

final demoHabitModule = HabitModuleModel(
  id: 'demo-1',
  habitName: 'Read more, use phone less',
  goalDescription: 'Read 15 minutes daily',
  whyItMatters: 'Improve focus and knowledge',
  blockers: ['Phone notifications', 'Evening tiredness'],
  dailyPlan: [
    {'day': 1, 'task': 'Read for 5 minutes', 'tip': 'Keep the book by your bed'},
  ],
);

class HabitNotifier extends StateNotifier<List<HabitModuleModel>> {
  HabitNotifier() : super([]) {
    _loadDemo();
  }

  void _loadDemo() {
    state = [
      HabitModuleModel(
        id: 'demo-1',
        habitName: 'Read more, use phone less',
        goalDescription: 'Read 15 minutes daily',
        whyItMatters: 'Improve focus and knowledge',
        blockers: ['Phone notifications', 'Evening tiredness'],
        dailyPlan: [
          {'day': 1, 'task': 'Read for 5 minutes', 'tip': 'Keep the book by your bed'},
        ],
      )
    ];
  }

  void addModule(HabitModuleModel module) {
    state = [...state, module];
    // Persist to Supabase if initialized
    try {
      SupabaseService.insertRow('habit_modules', module.toJson());
    } catch (_) {}
  }

  void removeModule(String id) {
    state = state.where((m) => m.id != id).toList();
  }
}
