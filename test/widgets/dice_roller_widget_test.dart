import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ods/controllers/dice_controller.dart';
import 'package:ods/widgets/dice_roller_widget.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('DiceRollerWidget', () {
    late DiceController diceController;

    Widget buildDiceRoller({
      int forca = 14,
      int destreza = 12,
      int ba = 2,
      int jp = 13,
    }) {
      diceController = DiceController();
      final sheet = createTestSheet(
        forca: forca,
        destreza: destreza,
        ba: ba,
        jp: jp,
      );

      return wrapWithMaterialApp(
        DiceRollerWidget(
          diceController: diceController,
          sheet: sheet,
        ),
      );
    }

    group('dice grid', () {
      testWidgets('renders all 6 dice buttons', (tester) async {
        await tester.pumpWidget(buildDiceRoller());

        expect(find.text('d4'), findsOneWidget);
        expect(find.text('d6'), findsOneWidget);
        expect(find.text('d8'), findsOneWidget);
        expect(find.text('d10'), findsOneWidget);
        expect(find.text('d12'), findsOneWidget);
        expect(find.text('d20'), findsOneWidget);
      });

      testWidgets('tapping d20 displays a result', (tester) async {
        await tester.pumpWidget(buildDiceRoller());

        // Initially shows dash
        expect(find.text('—'), findsOneWidget);

        await tester.tap(find.text('d20'));
        await tester.pump();

        // Dash should be gone, replaced by a number
        expect(find.text('—'), findsNothing);
      });

      testWidgets('tapping d6 adds to history', (tester) async {
        await tester.pumpWidget(buildDiceRoller());

        await tester.tap(find.text('d6'));
        await tester.pump();

        expect(diceController.historico.length, 1);
        expect(diceController.historico[0].expression, '1d6');
      });
    });

    group('combat shortcuts', () {
      testWidgets('renders combat shortcut buttons', (tester) async {
        await tester.pumpWidget(buildDiceRoller());

        expect(find.text('Iniciativa'), findsOneWidget);
        expect(find.text('Ataque C.a.C.'), findsOneWidget);
        expect(find.text('Ataque Dist.'), findsOneWidget);
      });

      testWidgets('JP button shows sheet JP value', (tester) async {
        await tester.pumpWidget(buildDiceRoller(jp: 13));

        expect(find.textContaining('JP (≥13)'), findsOneWidget);
      });

      testWidgets('tapping Iniciativa produces a result', (tester) async {
        await tester.pumpWidget(buildDiceRoller(destreza: 14));

        await tester.tap(find.text('Iniciativa'));
        await tester.pump();

        expect(find.text('—'), findsNothing);
      });

      testWidgets('tapping JP button produces SUCESSO or FALHA',
          (tester) async {
        await tester.pumpWidget(buildDiceRoller(jp: 13));

        await tester.tap(find.textContaining('JP'));
        await tester.pump();

        // The result expression should contain SUCESSO or FALHA
        final resultExpression = diceController.historico.first.expression;
        expect(
          resultExpression.contains('SUCESSO') ||
              resultExpression.contains('FALHA'),
          isTrue,
        );
      });
    });

    group('custom roll', () {
      testWidgets('renders custom roll input and button', (tester) async {
        await tester.pumpWidget(buildDiceRoller());

        expect(find.text('ROLAGEM CUSTOMIZADA'), findsOneWidget);
        expect(find.text('Rolar'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('empty expression does not produce a result',
          (tester) async {
        await tester.pumpWidget(buildDiceRoller());

        await tester.tap(find.text('Rolar'));
        await tester.pump();

        expect(find.text('—'), findsOneWidget);
        expect(diceController.historico, isEmpty);
      });

      testWidgets('entering expression and tapping Rolar produces result',
          (tester) async {
        await tester.pumpWidget(buildDiceRoller());

        await tester.enterText(find.byType(TextField), '2d6+3');
        await tester.tap(find.text('Rolar'));
        await tester.pump();

        expect(find.text('—'), findsNothing);
        expect(diceController.historico.length, 1);
      });
    });

    group('history', () {
      testWidgets('history section hidden when empty', (tester) async {
        await tester.pumpWidget(buildDiceRoller());

        expect(find.text('HISTÓRICO'), findsNothing);
      });

      testWidgets('history section appears after rolling', (tester) async {
        await tester.pumpWidget(buildDiceRoller());

        await tester.tap(find.text('d6'));
        await tester.pump();

        expect(find.text('HISTÓRICO'), findsOneWidget);
      });
    });
  });
}
