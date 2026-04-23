import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const RehlahApp(),
    ),
  );
}

class RehlahApp extends StatelessWidget {
  const RehlahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      final isArabic = provider.isArabic;
      return L10nProvider(
        isArabic: isArabic,
        child: MaterialApp(
          title: isArabic ? 'رحلة يُسر' : 'Rehlah',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          home: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: _AppRoot(isArabic: isArabic),
          ),
        ),
      );
    });
  }
}

class _AppRoot extends StatelessWidget {
  final bool isArabic;
  const _AppRoot({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      if (provider.onboardingDone) {
        return const MainScreen();
      }
      return const WelcomeScreen();
    });
  }
}
