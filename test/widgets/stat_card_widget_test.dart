import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ods/widgets/stat_card_widget.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('StatCard', () {
    int? lastValue;

    Widget buildStatCard({
      String label = 'CA',
      int value = 14,
      IconData icon = Icons.shield,
    }) {
      lastValue = null;
      return wrapWithMaterialApp(
        Row(
          children: [
            StatCard(
              label: label,
              value: value,
              icon: icon,
              onChanged: (v) => lastValue = v,
            ),
          ],
        ),
      );
    }

    group('display', () {
      testWidgets('shows label', (tester) async {
        await tester.pumpWidget(buildStatCard(label: 'CA'));
        expect(find.text('CA'), findsOneWidget);
      });

      testWidgets('shows value', (tester) async {
        await tester.pumpWidget(buildStatCard(value: 14));
        expect(find.text('14'), findsOneWidget);
      });

      testWidgets('shows icon', (tester) async {
        await tester.pumpWidget(buildStatCard(icon: Icons.shield));
        expect(find.byIcon(Icons.shield), findsOneWidget);
      });
    });

    group('edit dialog', () {
      testWidgets('tapping opens edit dialog', (tester) async {
        await tester.pumpWidget(buildStatCard(label: 'CA', value: 14));

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        expect(find.text('CA'), findsWidgets); // label in card + dialog title
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Salvar'), findsOneWidget);
      });

      testWidgets('dialog pre-fills current value', (tester) async {
        await tester.pumpWidget(buildStatCard(value: 14));

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, '14');
      });

      testWidgets('Salvar calls onChanged with new value', (tester) async {
        await tester.pumpWidget(buildStatCard(value: 14));

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '18');
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        expect(lastValue, 18);
      });

      testWidgets('Cancelar does not call onChanged', (tester) async {
        await tester.pumpWidget(buildStatCard(value: 14));

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(lastValue, isNull);
      });

      testWidgets('empty input falls back to current value', (tester) async {
        await tester.pumpWidget(buildStatCard(value: 14));

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '');
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        expect(lastValue, 14);
      });
    });
  });
}
