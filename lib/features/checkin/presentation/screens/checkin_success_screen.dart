import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class CheckInSuccessScreen extends StatefulWidget {
  const CheckInSuccessScreen({super.key});
  @override
  State<CheckInSuccessScreen> createState() => _CheckInSuccessState();
}

class _CheckInSuccessState extends State<CheckInSuccessScreen> {
  int _countdown = 4;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) { t.cancel(); context.go('/'); }
      else setState(() => _countdown--);
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 76, height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.teal.withOpacity(0.18),
                      AppColors.primary.withOpacity(0.10),
                    ]),
                    border: Border.all(
                      color: AppColors.teal.withOpacity(0.28), width: 1.5),
                    boxShadow: [BoxShadow(
                      color: AppColors.teal.withOpacity(0.12),
                      blurRadius: 24,
                    )],
                  ),
                  child: const Center(
                    child: Text('🌿', style: TextStyle(fontSize: 30))),
                ),
                const SizedBox(height: 20),
                Text('Well done today',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 26, fontWeight: FontWeight.w700,
                    color: AppColors.primary, letterSpacing: -0.5)),
                const SizedBox(height: 10),
                Text(
                  'Your check-in helps your care team understand what you need. See you tomorrow.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w300,
                    color: AppColors.text2, height: 1.7),
                ),
                const SizedBox(height: 24),
                Text(
                  'Returning to home in $_countdown s...',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w300,
                    color: AppColors.text3),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Text('Go back now',
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500,
                      color: AppColors.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
