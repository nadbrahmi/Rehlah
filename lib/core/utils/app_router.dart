import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/welcome/presentation/screens/welcome_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/checkin/presentation/screens/checkin_screen.dart';
import '../../features/checkin/presentation/screens/checkin_sliders_screen.dart';
import '../../features/checkin/presentation/screens/checkin_success_screen.dart';
import '../../features/ai_chat/presentation/screens/ai_chat_screen.dart';
import '../../features/my_health/presentation/screens/my_health_journey_screen.dart';
import '../../features/my_health/presentation/screens/my_health_expect_screen.dart';
import '../../features/care/hub/presentation/screens/care_hub_screen.dart';
import '../../features/care/labs/presentation/screens/lab_results_screen.dart';
import '../../features/care/labs/presentation/screens/lab_history_screen.dart';
import '../../features/care/labs/presentation/screens/lab_add_screen.dart';
import '../../features/care/medications/presentation/screens/medications_screen.dart';
import '../../features/care/appointments/presentation/screens/appointments_screen.dart';
import '../../features/care/appointments/presentation/screens/prep_report_screen.dart';
import '../../features/connect/presentation/screens/connect_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/privacy_screen.dart';
import 'shell_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(path: '/welcome', builder: (c, s) => const WelcomeScreen()),
    GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
    GoRoute(path: '/checkin', builder: (c, s) => const CheckInScreen()),
    GoRoute(path: '/checkin/sliders', builder: (c, s) => const CheckInSlidersScreen()),
    GoRoute(path: '/checkin/success', builder: (c, s) => const CheckInSuccessScreen()),
    GoRoute(path: '/ai-chat', builder: (c, s) => const AiChatScreen()),
    GoRoute(path: '/care/labs', builder: (c, s) => const LabResultsScreen()),
    GoRoute(path: '/care/labs/history', builder: (c, s) => const LabHistoryScreen()),
    GoRoute(path: '/care/labs/add', builder: (c, s) => const LabAddScreen()),
    GoRoute(path: '/care/medications', builder: (c, s) => const MedicationsScreen()),
    GoRoute(path: '/care/appointments', builder: (c, s) => const AppointmentsScreen()),
    GoRoute(path: '/care/appointments/prep', builder: (c, s) => const PrepReportScreen()),
    GoRoute(path: '/profile/privacy', builder: (c, s) => const PrivacyScreen()),
    ShellRoute(
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
        GoRoute(path: '/my-health/journey', builder: (c, s) => const MyHealthJourneyScreen()),
        GoRoute(path: '/my-health/expect', builder: (c, s) => const MyHealthExpectScreen()),
        GoRoute(path: '/care', builder: (c, s) => const CareHubScreen()),
        GoRoute(path: '/connect', builder: (c, s) => const ConnectScreen()),
        GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
      ],
    ),
  ],
);
