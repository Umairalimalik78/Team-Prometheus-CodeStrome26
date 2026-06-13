import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitat/app.dart';
import 'package:habitat/core/services/supabase_service.dart';
import 'package:habitat/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service layer (dual mode Supabase/Mock)
  await SupabaseService.instance.initialize();

  // Initialize local notifications service
  await NotificationService.instance.init();

  runApp(
    const ProviderScope(
      child: HabitatApp(),
    ),
  );
}
