import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ods/widgets/attribute_card_widget.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AttributeCard', () {
    int? lastValue;

    Widget buildAttributeCard({
      String label = 'FOR',
      int value = 14,
    }) {
      lastValue = null;
      return wrapWithMaterialApp(
        SizedBox(
          width: 120,
          height: 120,
          child: AttributeCard(
            label: label,
            value: value,
            onChanged: (v) => lastValue = v,
          ),
        ),
      );
    }

    group('display', () {
      testWidgets('shows label', (tester) async {
        await tester.pumpWidget(buildAttributeCard(label: 'FOR'));
        expect(find.text('FOR'), findsOneWidget);
      });

      testWidgets('shows value', (tester) async {
        await tester.pumpWidget(buildAttributeCard(value: 16));
        expect(find.text('16'), findsOneWidget);
      });

      testWidgets('shows positive modifier with + sign', (tester) async {
        await tester.pumpWidget(buildAttributeCard(value: 14));
        expect(find.text('+2'), findsOneWidget);
      });

      testWidgets('shows negative modifier with - sign', (tester) async {
        await tester.pumpWidget(buildAttributeCard(value: 8));
        expect(find.text('-1'), findsOneWidget);
      });

      testWidgets('shows +0 for value 10', (tester) async {
        await tester.pumpWidget(buildAttributeCard(value: 10));
        expect(find.text('+0'), findsOneWidget);
      });

      testWidgets('shows correct modifier for value 18 (+4)',
          (tester) async {
        await tester.pumpWidget(buildAttributeCard(value: 18));
        expect(find.text('+4'), findsOneWidget);
      });
    });

    group('edit dialog', () {
      testWidgets('tapping card opens edit dialog', (tester) async {
        await tester.pumpWidget(buildAttributeCard(label: 'FOR', value: 14));

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        expect(find.text('FOR'), findsWidgets); // label in card + dialog title
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Salvar'), findsOneWidget);
      });

      testWidgets('dialog pre-fills current value', (tester) async {
        await tester.pumpWidget(buildAttributeCard(value: 14));

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, '14');
      });

      testWidgets('Salvar calls onChanged with new value', (tester) async {
        await tester.pumpWidget(buildAttributeCard(value: 14));

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '18');
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        expect(lastValue, 18);
      });

      testWidgets('Cancelar does not call onChanged', (tester) async {
        await tester.pumpWidget(buildAttributeCard(value: 14));

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(lastValue, isNull);
      });

      testWidgets('empty input falls back to current value', (tester) async {
        await tester.pumpWidget(buildAttributeCard(value: 14));

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
