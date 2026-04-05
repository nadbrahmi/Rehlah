import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/lab_provider.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/journey_created_screen.dart';
import 'screens/home/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final appProvider = AppProvider();
  await appProvider.init();

  final labProvider = LabProvider();
  await labProvider.init();

  // Seed demo data if in demo mode or no lab data yet
  if (appProvider.isDemoMode || !labProvider.hasData) {
    await labProvider.seedDemoData();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appProvider),
        ChangeNotifierProvider.value(value: labProvider),
      ],
      child: const RehlaApp(),
    ),
  );
}

class RehlaApp extends StatelessWidget {
  const RehlaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          title: 'Rehla',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          initialRoute: provider.onboardingComplete ? '/main' : '/',
          routes: {
            '/': (ctx) => const WelcomeScreen(),
            '/onboarding': (ctx) => const OnboardingScreen(),
            '/journey_created': (ctx) => const JourneyCreatedScreen(),
            '/main': (ctx) => const MainScreen(),
          },
        );
      },
    );
  }
}
