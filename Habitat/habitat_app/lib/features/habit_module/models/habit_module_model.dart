class HabitModuleModel {
  final String id;
  final String habitName;
  final String goalDescription;
  final String whyItMatters;
  final List<String> blockers;
  final List<Map<String, dynamic>> dailyPlan;
  final DateTime createdAt;

  HabitModuleModel({
    required this.id,
    required this.habitName,
    required this.goalDescription,
    required this.whyItMatters,
    this.blockers = const [],
    this.dailyPlan = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory HabitModuleModel.fromJson(Map<String, dynamic> json) {
    final rawDailyPlan = json['daily_plan'] ?? [];
    return HabitModuleModel(
      id: json['id']?.toString() ?? '',
      habitName: json['habit_name'] ?? '',
      goalDescription: json['goal_description'] ?? '',
      whyItMatters: json['why_it_matters'] ?? '',
      blockers: List<String>.from(json['blockers'] ?? []),
      dailyPlan: List<Map<String, dynamic>>.from(
        (rawDailyPlan as List).map((item) => Map<String, dynamic>.from(item as Map)),
      ),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'habit_name': habitName,
        'goal_description': goalDescription,
        'why_it_matters': whyItMatters,
        'blockers': blockers,
        'daily_plan': dailyPlan,
        'created_at': createdAt.toIso8601String(),
      };

  Map<String, dynamic>? get todayTask {
    if (dailyPlan.isEmpty) return null;
    return dailyPlan.first;
  }
}
