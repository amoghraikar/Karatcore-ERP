import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:karatcore_erp/app.dart';

void main() {
  testWidgets('KaratCore ERP root app initializes cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KaratCoreApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(KaratCoreApp), findsOneWidget);
  });
}
