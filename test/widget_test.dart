import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/app.dart';
import 'package:shopsphere/core/di/providers.dart';

void main() {
  testWidgets('ShopSphere app mounts and displays splash branding', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
        child: const ShopSphereApp(),
      ),
    );

    await tester.pump();

    expect(find.text('ShopSphere'), findsOneWidget);
    expect(find.text('Curated Shopping Experience'), findsOneWidget);
  });
}
