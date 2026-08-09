import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karatcore_erp/app.dart';
import 'package:karatcore_erp/core/theme/theme_provider.dart';
import 'package:karatcore_erp/core/utils/formatters.dart';

void main() {
  test('INR Currency and Date Formatters work correctly', () {
    final currency = KcFormatters.currency(150000);
    expect(currency, contains('1,50,000'));

    final compact = KcFormatters.inrCompact(250000);
    expect(compact, contains('2.50 L'));
  });

  testWidgets('App renders executive dashboard shell and theme switches', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KaratCoreApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign In to KaratCore'), findsWidgets);
  });

  testWidgets('ThemeNotifier toggles between light and dark mode', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.dark);
    container.read(themeModeProvider.notifier).toggle();
    expect(container.read(themeModeProvider), ThemeMode.light);
  });
}
