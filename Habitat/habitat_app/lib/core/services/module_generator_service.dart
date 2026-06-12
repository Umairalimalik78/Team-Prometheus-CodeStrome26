import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../../features/habit_module/models/habit_module_model.dart';

class ModuleGeneratorService {
  /// Sends the interview messages to the Edge Function `groq-generate`
  /// and returns a HabitModuleModel on success, or null on failure.
  static Future<HabitModuleModel?> generateFromMessages(List<Map<String, dynamic>> messages) async {
    final payload = {'messages': messages};
    final result = await SupabaseService.callFunction('groq-generate', payload);
    if (result == null) return null;

    try {
      // result may already be a Map
      Map<String, dynamic> json;
      if (result is String) json = jsonDecode(result);
      else if (result is Map) json = Map<String, dynamic>.from(result);
      else json = Map<String, dynamic>.from(result as Map);

      // Ensure id exists
      if (json['id'] == null || (json['id'] as String).isEmpty) {
        json['id'] = DateTime.now().microsecondsSinceEpoch.toString();
      }

      // Map keys to the HabitModuleModel expected fields
      final module = HabitModuleModel.fromJson(json);

      // Persist to Supabase table
      await SupabaseService.insertRow('habit_modules', module.toJson());

      return module;
    } catch (e) {
      if (kDebugMode) print('Module generation parse error: $e');
      return null;
    }
  }
}
