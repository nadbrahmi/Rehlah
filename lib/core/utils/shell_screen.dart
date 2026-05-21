import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/shared_widgets.dart';

class ShellScreen extends StatelessWidget {
  final Widget child;
  const ShellScreen({super.key, required this.child});

  int _navIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/my-health') ||
        location.startsWith('/care') ||
        location.startsWith('/vitals')) {
      return 1;
    }
    if (location.startsWith('/connect')) { return 3; }
    if (location.startsWith('/profile')) { return 4; }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _navIndex(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4), // RColors.sand50
      extendBody: true,
      body: child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: idx,
        onTap: (i) {
          switch (i) {
            case 0: context.go('/'); break;
            case 1: context.go('/care'); break;
            case 3: context.go('/connect'); break;
            case 4: context.go('/profile'); break;
            case 5: context.push('/checkin'); break;
          }
        },
      ),
    );
  }
}
