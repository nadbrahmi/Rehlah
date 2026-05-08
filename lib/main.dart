import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/env.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env — app runs in demo mode if the file is absent
  try {
    await dotenv.load(fileName: 'env');
  } catch (_) {}

  // Initialize Supabase — skipped gracefully if credentials are missing
  if (Env.hasSupabase) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );
    } catch (_) {}
  }

  // Session recovery — reload patient profile if previously activated
  if (Env.hasSupabase) {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('rehlah_patient_id');
      if (savedId != null) {
        final data = await SupabaseService.getPatientById(savedId);
        if (data != null) {
          await SupabaseService.applyPatientToSession(data);
        } else {
          await SupabaseService.applyPatientFromCache();
        }
      }
    } catch (_) {}
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const ProviderScope(child: RehlahApp()));
}

class RehlahApp extends StatelessWidget {
  const RehlahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Rehlah · رحلة',
      theme: buildAppTheme(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
    );
  }
}
