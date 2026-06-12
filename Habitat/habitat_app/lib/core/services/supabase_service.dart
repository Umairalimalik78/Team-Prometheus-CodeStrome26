import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';

class SupabaseService {
  static bool initialized = false;
  static late Dio dio;

  static Future<void> initialize() async {
    final url = const String.fromEnvironment('SUPABASE_URL');
    final anon = const String.fromEnvironment('SUPABASE_ANON_KEY');

    if (url.isNotEmpty && anon.isNotEmpty) {
      await Supabase.initialize(url: url, anonKey: anon);
      dio = Dio(BaseOptions(baseUrl: url, headers: {
        'Content-Type': 'application/json',
        'apikey': anon,
        'Authorization': 'Bearer $anon',
      }));
      initialized = true;
    } else {
      initialized = false; // will use mock auth
    }
  }

  /// Call a Supabase Edge Function by name. Returns parsed JSON or null on error.
  static Future<dynamic> callFunction(String name, Map<String, dynamic> body) async {
    if (!initialized) return null;
    try {
      final res = await dio.post('/functions/v1/$name', data: body);
      return res.data;
    } catch (e) {
      return null;
    }
  }

  /// Insert a row into Supabase table. Returns insert result or null.
  static Future<dynamic> insertRow(String table, Map<String, dynamic> data) async {
    if (!initialized) return null;
    try {
      final client = Supabase.instance.client;
      final res = await client.from(table).insert(data).select();
      if (res == null) return null;
      return res;
    } catch (e) {
      return null;
    }
  }
}

