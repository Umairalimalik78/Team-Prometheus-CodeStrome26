import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habitat/features/auth/models/user_model.dart';
import 'package:habitat/features/chat/models/message_model.dart';
import 'package:habitat/features/habit_module/models/habit_module_model.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  late final SharedPreferences _prefs;
  SupabaseClient? _supabaseClient;
  bool _isMockMode = true;

  // Local storage keys
  static const String _keyCurrentUser = 'habitat_mock_user';
  static const String _keyHabits = 'habitat_mock_habits';
  static const String _keyMessages = 'habitat_mock_messages';
  static const String _keyLogs = 'habitat_mock_logs';
  static const String _keyCheckins = 'habitat_mock_checkins';

  bool get isMockMode => _isMockMode;
  SupabaseClient get client {
    if (_supabaseClient == null) {
      throw Exception("Supabase is not initialized. Run initialize() first.");
    }
    return _supabaseClient!;
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    // Check for dart-define environments
    const url = String.fromEnvironment('SUPABASE_URL');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (url.isNotEmpty && anonKey.isNotEmpty) {
      try {
        await Supabase.initialize(
          url: url,
          anonKey: anonKey,
        );
        _supabaseClient = Supabase.instance.client;
        _isMockMode = false;
        debugPrint("Habitat: Supabase initialized in REAL mode.");
      } catch (e) {
        debugPrint("Habitat: Failed to initialize Supabase real mode, falling back to mock mode: $e");
        _isMockMode = true;
      }
    } else {
      debugPrint("Habitat: Running in MOCK DEMO mode (SUPABASE_URL/ANON_KEY not set).");
      _isMockMode = true;
    }
  }

  // ==========================================
  // AUTHENTICATION
  // ==========================================

  Future<UserModel?> getCurrentUser() async {
    if (_isMockMode) {
      final data = _prefs.getString(_keyCurrentUser);
      if (data == null) return null;
      return UserModel.fromJson(jsonDecode(data));
    } else {
      final session = client.auth.currentSession;
      if (session == null) return null;
      final user = session.user;
      
      // Fetch profile from database
      try {
        final res = await client.from('profiles').select().eq('id', user.id).maybeSingle();
        if (res != null) {
          return UserModel.fromJson(res);
        } else {
          // If profile doesn't exist, create it
          final newProfile = {
            'id': user.id,
            'name': user.email?.split('@').first ?? 'User',
            'timezone': 'Asia/Karachi',
            'created_at': DateTime.now().toIso8601String(),
          };
          await client.from('profiles').insert(newProfile);
          return UserModel.fromJson(newProfile);
        }
      } catch (e) {
        debugPrint("Error fetching user profile: $e");
        return UserModel(
          id: user.id,
          name: user.email?.split('@').first ?? 'User',
          timezone: 'Asia/Karachi',
          createdAt: DateTime.now(),
        );
      }
    }
  }

  Future<UserModel?> login(String email, String password) async {
    if (_isMockMode) {
      final mockId = 'mock_user_${email.hashCode}';
      final mockUser = UserModel(
        id: mockId,
        name: email.split('@').first,
        timezone: 'Asia/Karachi',
        createdAt: DateTime.now(),
      );
      await _prefs.setString(_keyCurrentUser, jsonEncode(mockUser.toJson()));
      return mockUser;
    } else {
      final response = await client.auth.signInWithPassword(email: email, password: password);
      if (response.user == null) return null;
      return getCurrentUser();
    }
  }

  Future<UserModel?> signup(String email, String password, String name) async {
    if (_isMockMode) {
      final mockId = 'mock_user_${email.hashCode}';
      final mockUser = UserModel(
        id: mockId,
        name: name,
        timezone: 'Asia/Karachi',
        createdAt: DateTime.now(),
      );
      await _prefs.setString(_keyCurrentUser, jsonEncode(mockUser.toJson()));
      return mockUser;
    } else {
      final response = await client.auth.signUp(email: email, password: password);
      if (response.user == null) return null;
      
      final profileData = {
        'id': response.user!.id,
        'name': name,
        'timezone': 'Asia/Karachi',
        'created_at': DateTime.now().toIso8601String(),
      };
      await client.from('profiles').insert(profileData);
      return UserModel.fromJson(profileData);
    }
  }

  Future<void> logout() async {
    if (_isMockMode) {
      await _prefs.remove(_keyCurrentUser);
    } else {
      await client.auth.signOut();
    }
  }

  Future<void> deleteAccount(String userId) async {
    if (_isMockMode) {
      await _prefs.remove(_keyCurrentUser);
      await _prefs.remove(_keyHabits);
      await _prefs.remove(_keyMessages);
      await _prefs.remove(_keyLogs);
      await _prefs.remove(_keyCheckins);
    } else {
      // Delete user's row in profiles (cascade deletes everything else)
      await client.from('profiles').delete().eq('id', userId);
      await client.auth.signOut();
    }
  }

  // ==========================================
  // HABIT MODULES
  // ==========================================

  Future<List<HabitModuleModel>> getHabits(String userId) async {
    if (_isMockMode) {
      final raw = _prefs.getStringList(_keyHabits) ?? [];
      return raw.map((e) => HabitModuleModel.fromJson(jsonDecode(e))).toList();
    } else {
      final res = await client.from('habit_modules').select().eq('user_id', userId);
      return (res as List).map((e) => HabitModuleModel.fromJson(e)).toList();
    }
  }

  Future<HabitModuleModel?> getHabitById(String id) async {
    if (_isMockMode) {
      final raw = _prefs.getStringList(_keyHabits) ?? [];
      for (final item in raw) {
        final habit = HabitModuleModel.fromJson(jsonDecode(item));
        if (habit.id == id) return habit;
      }
      return null;
    } else {
      final res = await client.from('habit_modules').select().eq('id', id).maybeSingle();
      if (res == null) return null;
      return HabitModuleModel.fromJson(res);
    }
  }

  Future<void> saveHabitModule(HabitModuleModel habit) async {
    if (_isMockMode) {
      final raw = _prefs.getStringList(_keyHabits) ?? [];
      // Remove if exists (replace)
      raw.removeWhere((e) => HabitModuleModel.fromJson(jsonDecode(e)).id == habit.id);
      raw.add(jsonEncode(habit.toJson()));
      await _prefs.setStringList(_keyHabits, raw);
    } else {
      await client.from('habit_modules').insert(habit.toJson());
    }
  }

  Future<void> updateHabitModule(HabitModuleModel habit) async {
    if (_isMockMode) {
      await saveHabitModule(habit);
    } else {
      await client.from('habit_modules').update(habit.toJson()).eq('id', habit.id);
    }
  }

  Future<void> deleteHabitModule(String id) async {
    if (_isMockMode) {
      final raw = _prefs.getStringList(_keyHabits) ?? [];
      raw.removeWhere((e) => HabitModuleModel.fromJson(jsonDecode(e)).id == id);
      await _prefs.setStringList(_keyHabits, raw);

      // Clean logs and messages
      final rawLogs = _prefs.getStringList(_keyLogs) ?? [];
      rawLogs.removeWhere((e) => jsonDecode(e)['module_id'] == id);
      await _prefs.setStringList(_keyLogs, rawLogs);

      final rawMsgs = _prefs.getStringList(_keyMessages) ?? [];
      rawMsgs.removeWhere((e) => jsonDecode(e)['module_id'] == id);
      await _prefs.setStringList(_keyMessages, rawMsgs);
    } else {
      await client.from('habit_modules').delete().eq('id', id);
    }
  }

  // ==========================================
  // DAILY COMPLETION LOGS
  // ==========================================

  Future<List<DateTime>> getCompletedDates(String moduleId) async {
    if (_isMockMode) {
      final raw = _prefs.getStringList(_keyLogs) ?? [];
      List<DateTime> completed = [];
      for (final item in raw) {
        final map = jsonDecode(item);
        if (map['module_id'] == moduleId && map['completed'] == true) {
          completed.add(DateTime.parse(map['log_date'] as String));
        }
      }
      return completed;
    } else {
      final res = await client
          .from('daily_logs')
          .select('log_date, completed')
          .eq('module_id', moduleId)
          .eq('completed', true);
      
      return (res as List).map((e) => DateTime.parse(e['log_date'] as String)).toList();
    }
  }

  Future<void> markDayComplete(String moduleId, String userId, DateTime date, bool completed) async {
    final dateString = date.toIso8601String().split('T')[0];

    if (_isMockMode) {
      final raw = _prefs.getStringList(_keyLogs) ?? [];
      // Remove existing for same date & module
      raw.removeWhere((e) {
        final m = jsonDecode(e);
        return m['module_id'] == moduleId && m['log_date'] == dateString;
      });
      
      raw.add(jsonEncode({
        'id': 'log_${DateTime.now().microsecondsSinceEpoch}',
        'module_id': moduleId,
        'user_id': userId,
        'log_date': dateString,
        'completed': completed,
        'created_at': DateTime.now().toIso8601String(),
      }));
      await _prefs.setStringList(_keyLogs, raw);

      // Now update streak count on habit
      final habits = await getHabits(userId);
      final index = habits.indexWhere((element) => element.id == moduleId);
      if (index != -1) {
        final habit = habits[index];
        int newStreak = habit.streakCount;
        if (completed) {
          newStreak += 1;
        } else {
          newStreak = max(0, newStreak - 1);
        }
        final updatedHabit = habit.copyWith(streakCount: newStreak);
        await updateHabitModule(updatedHabit);
      }
    } else {
      // Upsert into Supabase
      final data = {
        'module_id': moduleId,
        'user_id': userId,
        'log_date': dateString,
        'completed': completed,
      };
      
      await client.from('daily_logs').upsert(data, onConflict: 'module_id, log_date');

      // Update streak count on habit
      final res = await client.from('habit_modules').select('streak_count').eq('id', moduleId).single();
      int currentStreak = res['streak_count'] as int;
      int newStreak = completed ? currentStreak + 1 : max(0, currentStreak - 1);
      await client.from('habit_modules').update({'streak_count': newStreak}).eq('id', moduleId);
    }
  }

  // ==========================================
  // CHAT MESSAGES
  // ==========================================

  Future<List<MessageModel>> getChatMessages(String moduleId, String userId) async {
    if (_isMockMode) {
      final raw = _prefs.getStringList(_keyMessages) ?? [];
      return raw
          .map((e) => MessageModel.fromJson(jsonDecode(e)))
          .where((msg) => msg.moduleId == moduleId && msg.userId == userId)
          .toList();
    } else {
      final res = await client
          .from('chat_messages')
          .select()
          .eq('module_id', moduleId)
          .eq('user_id', userId)
          .order('created_at', ascending: true);
      return (res as List).map((e) => MessageModel.fromJson(e)).toList();
    }
  }

  Future<void> saveChatMessage(MessageModel message) async {
    if (_isMockMode) {
      final raw = _prefs.getStringList(_keyMessages) ?? [];
      raw.add(jsonEncode(message.toJson()));
      await _prefs.setStringList(_keyMessages, raw);
    } else {
      await client.from('chat_messages').insert(message.toJson());
    }
  }

  // ==========================================
  // CHECK-IN FLOW
  // ==========================================

  Future<void> saveCheckIn(String moduleId, String userId, int day, String userResponse, String aiDecision, String aiMessage) async {
    if (_isMockMode) {
      final raw = _prefs.getStringList(_keyCheckins) ?? [];
      raw.add(jsonEncode({
        'id': 'checkin_${DateTime.now().microsecondsSinceEpoch}',
        'module_id': moduleId,
        'user_id': userId,
        'checkin_day': day,
        'user_response': userResponse,
        'ai_decision': aiDecision,
        'ai_message': aiMessage,
        'created_at': DateTime.now().toIso8601String(),
      }));
      await _prefs.setStringList(_keyCheckins, raw);

      // Apply decision to habit status & phase
      final habits = await getHabits(userId);
      final index = habits.indexWhere((element) => element.id == moduleId);
      if (index != -1) {
        final habit = habits[index];
        String newStatus = habit.status;
        int newPhase = habit.phase;
        
        if (aiDecision == 'close') {
          newStatus = 'completed';
          newPhase = 5; // autonomous
        } else if (aiDecision == 'extend') {
          newStatus = 'active';
          newPhase = 3; // reducing (extend)
        } else if (aiDecision == 'restart') {
          newStatus = 'restarted';
          newPhase = 1; // restart fresh
        }
        
        await updateHabitModule(habit.copyWith(status: newStatus, phase: newPhase));
      }
    } else {
      await client.from('checkins').insert({
        'module_id': moduleId,
        'user_id': userId,
        'checkin_day': day,
        'user_response': userResponse,
        'ai_decision': aiDecision,
        'ai_message': aiMessage,
      });

      // Update habit module properties
      String newStatus = 'active';
      int newPhase = 1;
      
      if (aiDecision == 'close') {
        newStatus = 'completed';
        newPhase = 5;
      } else if (aiDecision == 'extend') {
        newStatus = 'active';
        newPhase = 3;
      } else if (aiDecision == 'restart') {
        newStatus = 'restarted';
        newPhase = 1;
      }

      await client.from('habit_modules').update({
        'status': newStatus,
        'phase': newPhase,
      }).eq('id', moduleId);
    }
  }

  // ==========================================
  // AI COACH SERVICE INTEGRATIONS (DENSE LOGIC)
  // ==========================================

  // Returns the next message from the AI Coach
  Future<String> sendIntakeMessage(List<MessageModel> history) async {
    if (_isMockMode) {
      await Future.delayed(const Duration(milliseconds: 1500)); // Simulate thinking latency

      final questions = [
        "What habit do you want to build, and why does it matter to you?",
        "Have you tried building this habit before? What stopped you?",
        "What are your biggest distractions or obstacles?",
        "What time of day works best for this habit?",
        "What does your environment look like — what helps or hurts?",
        "On a scale of 1-10, how motivated are you right now?",
      ];

      // Calculate how many user answers we have received
      final userAnswersCount = history.where((msg) => msg.role == 'user').length;

      if (userAnswersCount == 0) {
        return "Hello! I am Habitat, your AI habit coach. I'm here to build a personalized 25-day roadmap for you based on Atomic Habits. Let's start:\n\n${questions[0]}";
      }

      if (userAnswersCount < questions.length) {
        final nextQuestion = questions[userAnswersCount];
        String followUp = "";
        
        // Dynamic response snippets depending on what the user said
        if (userAnswersCount == 1) {
          followUp = "That sounds like a powerful motivator. Understanding the 'why' is crucial. Let me ask: ";
        } else if (userAnswersCount == 2) {
          followUp = "Previous blockers are completely normal. We will design around them. Next: ";
        } else if (userAnswersCount == 3) {
          followUp = "Acknowledge those triggers. We'll add them to your obstacle playbook. Let's coordinate schedules: ";
        } else if (userAnswersCount == 4) {
          followUp = "Perfect, timing is everything. Now about your space: ";
        } else if (userAnswersCount == 5) {
          followUp = "Environment design is the secret weapon. Got it. Lastly, to check readiness: ";
        }

        return "$followUp$nextQuestion";
      }

      return "INTERVIEW_COMPLETE";
    } else {
      // Call Supabase Edge function groq-intake
      final response = await client.functions.invoke(
        'groq-intake',
        body: {'messages': history.map((m) => {'role': m.role, 'content': m.content}).toList()},
      );
      
      final data = response.data as Map<String, dynamic>;
      return data['choices'][0]['message']['content'] as String;
    }
  }

  // Generates the Habit Module JSON
  Future<HabitModuleModel> generateHabitModule(List<MessageModel> history, String userId) async {
    if (_isMockMode) {
      await Future.delayed(const Duration(milliseconds: 3000)); // Simulate complex AI generation

      // Parse user's habit target
      String habitTarget = "Read Books";
      String motivation = "Gain knowledge and screen detox.";
      List<String> blockers = ["Phone distractions", "Being tired after work"];

      // Find user responses
      final userMsgs = history.where((m) => m.role == 'user').toList();
      if (userMsgs.isNotEmpty) {
        habitTarget = userMsgs[0].content;
        if (habitTarget.length > 50) {
          habitTarget = habitTarget.substring(0, 47) + "...";
        }
      }
      if (userMsgs.length > 1) motivation = userMsgs[1].content;
      if (userMsgs.length > 2) blockers = [userMsgs[2].content];

      // Dynamic generator templates based on keywords
      final query = habitTarget.toLowerCase();
      
      String title = habitTarget;
      List<String> envTips = [];
      List<DailyTask> dailyTasks = [];
      List<ObstacleItem> playbook = [];

      if (query.contains('read') || query.contains('book')) {
        title = "Read More, Use Phone Less";
        envTips = [
          "Place your book directly on your pillow in the morning.",
          "Keep your phone charger in a different room than your bedroom.",
          "Set up a comfortable, distraction-free reading corner."
        ];
        playbook = [
          ObstacleItem(trigger: "Feel too tired to read at night", response: "Open the book and read just one single page. Keeping the routine alive is more important than page count."),
          ObstacleItem(trigger: "Distracted by phone notifications", response: "Leave the phone in a desk drawer in the kitchen. Make screen access high-friction.")
        ];
        // Populate 25 progressive days
        for (int i = 1; i <= 25; i++) {
          int mins = i <= 7 ? 5 : (i <= 14 ? 10 : (i <= 21 ? 15 : 20));
          dailyTasks.add(DailyTask(
            day: i,
            task: "Read for $mins minutes in your designated spot.",
            tip: i <= 7 
                ? "Ensure your phone is placed in another room before opening the book." 
                : (i <= 15 ? "Combine with your evening tea (Habit Stacking)." : "Notice the calming transition from screens to pages.")
          ));
        }
      } else if (query.contains('exercise') || query.contains('gym') || query.contains('run') || query.contains('workout')) {
        title = "Sustainable Daily Movement";
        envTips = [
          "Lay out your workout clothes and shoes the night before.",
          "Create a music playlist that energizes you, reserved only for exercise.",
          "Set a specific visual trigger, like rolling out your yoga mat next to your bed."
        ];
        playbook = [
          ObstacleItem(trigger: "Don't feel like putting on gym clothes", response: "Tell yourself you will only do 5 minutes of stretching. Once you start, momentum usually takes over."),
          ObstacleItem(trigger: "Weather is bad outside", response: "Execute a 10-minute bodyweight home workout instead of running.")
        ];
        for (int i = 1; i <= 25; i++) {
          int mins = i <= 7 ? 10 : (i <= 14 ? 20 : (i <= 21 ? 30 : 40));
          dailyTasks.add(DailyTask(
            day: i,
            task: "Complete $mins minutes of active exercise (walk, run, or bodyweight).",
            tip: "Celebrate immediately after completing: 'I am someone who values my health!'"
          ));
        }
      } else if (query.contains('water') || query.contains('drink') || query.contains('hydrate')) {
        title = "Mindful Hydration Habits";
        envTips = [
          "Keep a filled 1L water bottle on your desk at all times.",
          "Drink a full glass of water immediately after brushing your teeth.",
          "Use a visual tally sheet or a rubber band on your bottle for tracking."
        ];
        playbook = [
          ObstacleItem(trigger: "Forget to drink because of meetings", response: "Set a water intake cue at the start of every calendar meeting. Drink 3 sips."),
          ObstacleItem(trigger: "Don't like the taste of plain water", response: "Infuse water with lemon slices, mint leaves, or cucumber slices.")
        ];
        for (int i = 1; i <= 25; i++) {
          double target = i <= 7 ? 1.5 : (i <= 14 ? 2.0 : 2.5);
          dailyTasks.add(DailyTask(
            day: i,
            task: "Drink $target Liters of water throughout the day.",
            tip: "Take a sip every time you look away from your computer screen."
          ));
        }
      } else {
        // General fallback template
        title = habitTarget.length > 25 ? habitTarget.substring(0, 22) + "..." : habitTarget;
        envTips = [
          "Set a clear physical trigger in your immediate surroundings.",
          "Reduce friction for starting: prepare your tools in advance.",
          "Eliminate alternative distractions from your workspace."
        ];
        playbook = [
          ObstacleItem(trigger: "Procrastinating starting the task", response: "Apply the 2-minute rule: do the easiest, simplest part of the habit first."),
          ObstacleItem(trigger: "Loss of motivation or streak fatigue", response: "Remember, never miss twice. A bad day is just one day. Get back on track immediately.")
        ];
        for (int i = 1; i <= 25; i++) {
          dailyTasks.add(DailyTask(
            day: i,
            task: "Work on building '$habitTarget' for a short, focused interval.",
            tip: "Tiny changes compound. Focus on the consistency of the trigger-routine loop."
          ));
        }
      }

      final mockModule = HabitModuleModel(
        id: 'habit_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        habitName: title,
        goalDescription: habitTarget,
        whyItMatters: motivation,
        blockers: blockers,
        dailyPlan: dailyTasks,
        obstaclePlaybook: playbook,
        envDesignTips: envTips,
        phase: 1,
        status: 'active',
        streakCount: 0,
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Save locally
      await saveHabitModule(mockModule);
      return mockModule;
    } else {
      // Call Supabase Edge function groq-generate
      final response = await client.functions.invoke(
        'groq-generate',
        body: {
          'messages': history.map((m) => {'role': m.role, 'content': m.content}).toList(),
          'user_id': userId,
        },
      );
      
      final data = response.data as Map<String, dynamic>;
      // Map to Model
      final habitData = {
        'id': 'habit_${DateTime.now().millisecondsSinceEpoch}', // Let edge function provide it, or set locally
        'user_id': userId,
        'habit_name': data['habit_name'],
        'goal_description': data['goal_description'],
        'why_it_matters': data['why_it_matters'],
        'blockers': data['blockers'],
        'env_design_tips': data['env_design_tips'],
        'daily_plan': data['daily_plan'],
        'obstacle_playbook': data['obstacle_playbook'],
        'phase': 1,
        'status': 'active',
        'streak_count': 0,
        'start_date': DateTime.now().toIso8601String().split('T')[0],
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final habitModule = HabitModuleModel.fromJson(habitData);
      await saveHabitModule(habitModule);
      return habitModule;
    }
  }

  // Checkin Evaluator
  Future<Map<String, dynamic>> sendCheckInMessage(String habitName, String userResponse) async {
    if (_isMockMode) {
      await Future.delayed(const Duration(milliseconds: 1500));
      
      final text = userResponse.toLowerCase();
      String decision = "extend";
      String message = "";
      
      if (text.contains("yes") || text.contains("great") || text.contains("easy") || text.contains("done") || text.contains("automatic") || text.contains("without")) {
        decision = "close";
        message = "Fantastic! You've successfully internalized the $habitName habit and transitioned into Autonomous Mode. The training wheels are coming off: you no longer need daily reminders. Keep honoring this habit as part of your identity!";
      } else if (text.contains("no") || text.contains("hard") || text.contains("fail") || text.contains("stopped") || text.contains("forgot")) {
        decision = "restart";
        message = "Building habits is a journey of trial and error. Since you encountered some blockers, let's recalibrate difficulty. We'll start a fresh, easier module of $habitName so we can build momentum.";
      } else {
        decision = "extend";
        message = "Consistency is building! Since you're partially there but still adjusting, we will extend your $habitName module for 7 more days. Keep practicing and refining your triggers.";
      }
      
      return {
        'decision': decision,
        'message': message,
        'reason': 'Analyzed responses for consistency keywords.'
      };
    } else {
      // Call Supabase Edge function groq-checkin
      final response = await client.functions.invoke(
        'groq-checkin',
        body: {
          'habit_name': habitName,
          'user_response': userResponse,
        },
      );
      
      return response.data as Map<String, dynamic>;
    }
  }
}
