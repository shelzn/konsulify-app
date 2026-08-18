import 'package:app/app/app.dart';
import 'package:app/features/category/presentation/providers/category_provider.dart';
import 'package:app/features/consultant/presentation/providers/consultant_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Konsulify app smoke test', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryProvider.overrideWith((ref) async => []),
          consultantListProvider.overrideWith((ref) async => []),
        ],
        child: const KonsulifyApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Konsulify'), findsWidgets);
  });
}
