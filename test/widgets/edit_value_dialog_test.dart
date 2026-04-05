import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ods/widgets/edit_value_dialog.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('showEditValueDialog', () {
    int? result;

    Widget buildTestWidget({
      required int initialValue,
      required String title,
    }) {
      result = null;
      return wrapWithMaterialApp(
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await showEditValueDialog(
                context,
                title: title,
                currentValue: initialValue,
              );
            },
            child: const Text('Open'),
          );
        }),
      );
    }

    group('display', () {
      testWidgets('shows dialog with title', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialValue: 10,
          title: 'Editar CA',
        ));

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Editar CA'), findsOneWidget);
      });

      testWidgets('shows Cancelar and Salvar buttons', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialValue: 10,
          title: 'Editar CA',
        ));

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Salvar'), findsOneWidget);
      });

      testWidgets('pre-fills TextField with currentValue', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialValue: 42,
          title: 'Editar CA',
        ));

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, '42');
      });
    });

    group('actions', () {
      testWidgets('Salvar closes dialog', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialValue: 10,
          title: 'Editar CA',
        ));

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsNothing);
        expect(find.text('Salvar'), findsNothing);
      });

      testWidgets('Cancelar closes dialog', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialValue: 10,
          title: 'Editar CA',
        ));

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsNothing);
        expect(find.text('Salvar'), findsNothing);
      });

      testWidgets('entering new value and pressing Salvar returns it',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialValue: 10,
          title: 'Editar CA',
        ));

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '25');
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        expect(result, 25);
      });

      testWidgets('empty input falls back to currentValue on Salvar',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(
          initialValue: 10,
          title: 'Editar CA',
        ));

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '');
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        expect(result, 10);
      });
    });
  });
}
