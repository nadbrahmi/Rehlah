import 'package:flutter_test/flutter_test.dart';
import 'package:rehla_care/main.dart';
import 'package:provider/provider.dart';
import 'package:rehla_care/providers/app_provider.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    final provider = AppProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const RehlaApp(),
      ),
    );
    expect(find.byType(RehlaApp), findsOneWidget);
  });
}
