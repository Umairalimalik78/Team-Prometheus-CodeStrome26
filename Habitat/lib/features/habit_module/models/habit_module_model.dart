class DailyTask {
  final int day;
  final String task;
  final String tip;

  DailyTask({
    required this.day,
    required this.task,
    required this.tip,
  });

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      day: json['day'] as int? ?? json['Day'] as int? ?? 1,
      task: json['task'] as String? ?? json['Task'] as String? ?? '',
      tip: json['tip'] as String? ?? json['Tip'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'task': task,
        'tip': tip,
      };
}

class ObstacleItem {
  final String trigger;
  final String response;

  ObstacleItem({
    required this.trigger,
    required this.response,
  });

  factory ObstacleItem.fromJson(Map<String, dynamic> json) {
    return ObstacleItem(
      trigger: json['trigger'] as String? ?? json['Trigger'] as String? ?? '',
      response: json['response'] as String? ?? json['Response'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'trigger': trigger,
        'response': response,
      };
}

class HabitModuleModel {
  final String id;
  final String userId;
  final String habitName;
  final String goalDescription;
  final String whyItMatters;
  final List<String> blockers;
  final List<DailyTask> dailyPlan;
  final List<ObstacleItem> obstaclePlaybook;
  final List<String> envDesignTips;
  final int phase; // 1=high, 2=moderate, 3=reducing, 4=tapering, 5=autonomous
  final String status; // 'active' | 'autonomous' | 'completed' | 'restarted'
  final int streakCount;
  final DateTime startDate;
  final DateTime createdAt;

  HabitModuleModel({
    required this.id,
    required this.userId,
    required this.habitName,
    required this.goalDescription,
    required this.whyItMatters,
    required this.blockers,
    required this.dailyPlan,
    required this.obstaclePlaybook,
    required this.envDesignTips,
    required this.phase,
    required this.status,
    required this.streakCount,
    required this.startDate,
    required this.createdAt,
  });

  factory HabitModuleModel.fromJson(Map<String, dynamic> json) {
    var rawPlan = json['daily_plan'] as List? ?? [];
    List<DailyTask> plan = rawPlan.map((e) => DailyTask.fromJson(Map<String, dynamic>.from(e))).toList();

    var rawPlaybook = json['obstacle_playbook'] as List? ?? [];
    List<ObstacleItem> playbook = rawPlaybook.map((e) => ObstacleItem.fromJson(Map<String, dynamic>.from(e))).toList();

    var rawBlockers = json['blockers'] as List? ?? [];
    List<String> blockersList = rawBlockers.map((e) => e.toString()).toList();

    var rawTips = json['env_design_tips'] as List? ?? [];
    List<String> tipsList = rawTips.map((e) => e.toString()).toList();

    return HabitModuleModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      habitName: json['habit_name'] as String,
      goalDescription: json['goal_description'] as String? ?? '',
      whyItMatters: json['why_it_matters'] as String? ?? '',
      blockers: blockersList,
      dailyPlan: plan,
      obstaclePlaybook: playbook,
      envDesignTips: tipsList,
      phase: json['phase'] as int? ?? 1,
      status: json['status'] as String? ?? 'active',
      streakCount: json['streak_count'] as int? ?? 0,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'habit_name': habitName,
      'goal_description': goalDescription,
      'why_it_matters': whyItMatters,
      'blockers': blockers,
      'daily_plan': dailyPlan.map((e) => e.toJson()).toList(),
      'obstacle_playbook': obstaclePlaybook.map((e) => e.toJson()).toList(),
      'env_design_tips': envDesignTips,
      'phase': phase,
      'status': status,
      'streak_count': streakCount,
      'start_date': startDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
    };
  }

  HabitModuleModel copyWith({
    String? id,
    String? userId,
    String? habitName,
    String? goalDescription,
    String? whyItMatters,
    List<String>? blockers,
    List<DailyTask>? dailyPlan,
    List<ObstacleItem>? obstaclePlaybook,
    List<String>? envDesignTips,
    int? phase,
    String? status,
    int? streakCount,
    DateTime? startDate,
    DateTime? createdAt,
  }) {
    return HabitModuleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      habitName: habitName ?? this.habitName,
      goalDescription: goalDescription ?? this.goalDescription,
      whyItMatters: whyItMatters ?? this.whyItMatters,
      blockers: blockers ?? this.blockers,
      dailyPlan: dailyPlan ?? this.dailyPlan,
      obstaclePlaybook: obstaclePlaybook ?? this.obstaclePlaybook,
      envDesignTips: envDesignTips ?? this.envDesignTips,
      phase: phase ?? this.phase,
      status: status ?? this.status,
      streakCount: streakCount ?? this.streakCount,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
