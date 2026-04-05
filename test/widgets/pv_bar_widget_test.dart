import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ods/widgets/pv_bar_widget.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('PvBar', () {
    int? lastPvAtual;
    int? lastPvMax;

    Widget buildPvBar({int pvAtual = 15, int pvMax = 20}) {
      lastPvAtual = null;
      lastPvMax = null;
      return wrapWithMaterialApp(
        PvBar(
          pvAtual: pvAtual,
          pvMax: pvMax,
          onPvAtualChanged: (v) => lastPvAtual = v,
          onPvMaxChanged: (v) => lastPvMax = v,
        ),
      );
    }

    group('display', () {
      testWidgets('shows current and max PV', (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 15, pvMax: 20));

        expect(find.text('15'), findsOneWidget);
        expect(find.text('20'), findsOneWidget);
        expect(find.text(' / '), findsOneWidget);
        expect(find.text('PV'), findsOneWidget);
      });

      testWidgets('shows heart icon', (tester) async {
        await tester.pumpWidget(buildPvBar());

        expect(find.byIcon(Icons.favorite), findsOneWidget);
      });

      testWidgets('shows four action buttons with icons', (tester) async {
        await tester.pumpWidget(buildPvBar());

        // 2 remove icons (for -1 and -5) + 2 add icons (for +1 and +5)
        expect(find.byIcon(Icons.remove), findsNWidgets(2));
        expect(find.byIcon(Icons.add), findsNWidgets(2));
      });
    });

    group('button callbacks', () {
      testWidgets('+1 calls onPvAtualChanged with incremented value',
          (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 15, pvMax: 20));

        // Find the +1 button (add icon with "1" text)
        final addButtons = find.byIcon(Icons.add);
        // First add button is +1 (index 0), second is +5 (index 1)
        await tester.tap(addButtons.first);
        await tester.pump();

        expect(lastPvAtual, 16);
      });

      testWidgets('-1 calls onPvAtualChanged with decremented value',
          (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 15, pvMax: 20));

        // Second remove button is -1 (first is -5)
        final removeButtons = find.byIcon(Icons.remove);
        await tester.tap(removeButtons.last);
        await tester.pump();

        expect(lastPvAtual, 14);
      });

      testWidgets('+5 calls onPvAtualChanged clamped at max',
          (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 17, pvMax: 20));

        final addButtons = find.byIcon(Icons.add);
        await tester.tap(addButtons.last);
        await tester.pump();

        expect(lastPvAtual, 20);
      });

      testWidgets('-5 calls onPvAtualChanged clamped at 0',
          (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 3, pvMax: 20));

        final removeButtons = find.byIcon(Icons.remove);
        await tester.tap(removeButtons.first);
        await tester.pump();

        expect(lastPvAtual, 0);
      });

      testWidgets('+1 clamps at max when already at max', (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 20, pvMax: 20));

        final addButtons = find.byIcon(Icons.add);
        await tester.tap(addButtons.first);
        await tester.pump();

        expect(lastPvAtual, 20);
      });

      testWidgets('-1 clamps at 0 when already at 0', (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 0, pvMax: 20));

        final removeButtons = find.byIcon(Icons.remove);
        await tester.tap(removeButtons.last);
        await tester.pump();

        expect(lastPvAtual, 0);
      });
    });

    group('edit dialog', () {
      testWidgets('tapping pvAtual opens edit dialog', (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 15, pvMax: 20));

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        expect(find.text('PV Atual'), findsOneWidget);
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Salvar'), findsOneWidget);
      });

      testWidgets('tapping pvMax opens edit dialog', (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 15, pvMax: 20));

        await tester.tap(find.text('20'));
        await tester.pumpAndSettle();

        expect(find.text('PV Máx'), findsOneWidget);
      });

      testWidgets('Salvar calls callback with new value', (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 15, pvMax: 20));

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '12');
        await tester.tap(find.text('Salvar'));
        await tester.pumpAndSettle();

        expect(lastPvAtual, 12);
      });

      testWidgets('Cancelar does not call callback', (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 15, pvMax: 20));

        await tester.tap(find.text('15'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(lastPvAtual, isNull);
      });
    });

    group('pulse animation', () {
      testWidgets('heart is wrapped in ScaleTransition', (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 4, pvMax: 20));

        // Find ScaleTransition that contains the heart icon
        final heartScaleTransition = find.ancestor(
          of: find.byIcon(Icons.favorite),
          matching: find.byType(ScaleTransition),
        );
        expect(heartScaleTransition, findsOneWidget);
      });

      testWidgets('heart scale is 1.0 when HP > 25% (no pulse)',
          (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 15, pvMax: 20));

        final heartScaleTransition = tester.widget<ScaleTransition>(
          find.ancestor(
            of: find.byIcon(Icons.favorite),
            matching: find.byType(ScaleTransition),
          ),
        );
        expect(heartScaleTransition.scale.value, 1.0);
      });
    });
  });
}
