import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitat/core/services/supabase_service.dart';
import 'package:habitat/features/auth/providers/auth_provider.dart';
import 'package:habitat/features/habit_module/models/habit_module_model.dart';

class DashboardState {
  final AsyncValue<List<HabitModuleModel>> habits;
  final bool isMutating;

  DashboardState({
    required this.habits,
    this.isMutating = false,
  });

  DashboardState copyWith({
    AsyncValue<List<HabitModuleModel>>? habits,
    bool? isMutating,
  }) {
    return DashboardState(
      habits: habits ?? this.habits,
      isMutating: isMutating ?? this.isMutating,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final Ref _ref;

  DashboardNotifier(this._ref) : super(DashboardState(habits: const AsyncValue.loading())) {
    _init();
  }

  void _init() {
    final authState = _ref.read(authProvider);
    if (authState.user != null) {
      fetchHabits(authState.user!.id);
    }
  }

  Future<void> fetchHabits(String userId) async {
    state = state.copyWith(habits: const AsyncValue.loading());
    try {
      final list = await SupabaseService.instance.getHabits(userId);
      state = state.copyWith(habits: AsyncValue.data(list));
    } catch (e, stack) {
      state = state.copyWith(habits: AsyncValue.error(e, stack));
    }
  }

  Future<void> refresh() async {
    final authState = _ref.read(authProvider);
    if (authState.user == null) return;
    try {
      final list = await SupabaseService.instance.getHabits(authState.user!.id);
      state = state.copyWith(habits: AsyncValue.data(list));
    } catch (e, stack) {
      state = state.copyWith(habits: AsyncValue.error(e, stack));
    }
  }

  Future<void> markHabitDone(String moduleId, DateTime date, bool completed) async {
    final authState = _ref.read(authProvider);
    if (authState.user == null) return;
    
    // Optimistic UI update
    final currentHabits = state.habits.value ?? [];
    final updatedList = currentHabits.map((h) {
      if (h.id == moduleId) {
        int newStreak = h.streakCount;
        if (completed) {
          newStreak += 1;
        } else {
          newStreak = (newStreak - 1).clamp(0, 999);
        }
        return h.copyWith(streakCount: newStreak);
      }
      return h;
    }).toList();
    state = state.copyWith(habits: AsyncValue.data(updatedList));

    try {
      await SupabaseService.instance.markDayComplete(moduleId, authState.user!.id, date, completed);
      // Re-fetch to get correct sync
      await refresh();
    } catch (e) {
      // Revert in case of error
      fetchHabits(authState.user!.id);
    }
  }

  Future<void> deleteHabit(String moduleId) async {
    final authState = _ref.read(authProvider);
    if (authState.user == null) return;

    state = state.copyWith(isMutating: true);
    try {
      await SupabaseService.instance.deleteHabitModule(moduleId);
      // Remove from list locally
      final currentList = state.habits.value ?? [];
      final filteredList = currentList.where((h) => h.id != moduleId).toList();
      state = state.copyWith(
        habits: AsyncValue.data(filteredList),
        isMutating: false,
      );
    } catch (e, stack) {
      state = state.copyWith(
        habits: AsyncValue.error(e, stack),
        isMutating: false,
      );
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref);
});
