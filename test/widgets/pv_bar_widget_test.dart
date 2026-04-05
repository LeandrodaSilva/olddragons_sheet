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

      testWidgets('shows all four adjustment buttons', (tester) async {
        await tester.pumpWidget(buildPvBar());

        expect(find.text('-5'), findsOneWidget);
        expect(find.text('-1'), findsOneWidget);
        expect(find.text('+1'), findsOneWidget);
        expect(find.text('+5'), findsOneWidget);
      });
    });

    group('color coding', () {
      testWidgets('uses green when HP > 50%', (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 15, pvMax: 20));

        final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        final animation = indicator.valueColor as AlwaysStoppedAnimation<Color>;
        expect(animation.value, Colors.green);
      });

      testWidgets('uses orange when HP > 25% and <= 50%', (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 8, pvMax: 20));

        final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        final animation = indicator.valueColor as AlwaysStoppedAnimation<Color>;
        expect(animation.value, Colors.orange);
      });

      testWidgets('uses red when HP <= 25%', (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 4, pvMax: 20));

        final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        final animation = indicator.valueColor as AlwaysStoppedAnimation<Color>;
        expect(animation.value, Colors.red);
      });

      testWidgets('uses red when HP is 0', (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 0, pvMax: 20));

        final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        final animation = indicator.valueColor as AlwaysStoppedAnimation<Color>;
        expect(animation.value, Colors.red);
      });
    });

    group('progress bar', () {
      testWidgets('shows 0% when pvMax is 0 (no division by zero)',
          (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 0, pvMax: 0));

        final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(indicator.value, 0.0);
      });

      testWidgets('clamps progress to 1.0 when pvAtual > pvMax',
          (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 25, pvMax: 20));

        final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(indicator.value, 1.0);
      });
    });

    group('button callbacks', () {
      testWidgets('+1 calls onPvAtualChanged with clamped value',
          (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 15, pvMax: 20));
        await tester.tap(find.text('+1'));

        expect(lastPvAtual, 16);
      });

      testWidgets('-1 calls onPvAtualChanged with clamped value',
          (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 15, pvMax: 20));
        await tester.tap(find.text('-1'));

        expect(lastPvAtual, 14);
      });

      testWidgets('+5 calls onPvAtualChanged with clamped value',
          (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 15, pvMax: 20));
        await tester.tap(find.text('+5'));

        expect(lastPvAtual, 20);
      });

      testWidgets('-5 calls onPvAtualChanged with clamped value',
          (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 15, pvMax: 20));
        await tester.tap(find.text('-5'));

        expect(lastPvAtual, 10);
      });

      testWidgets('+1 clamps at max when already at max', (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 20, pvMax: 20));
        await tester.tap(find.text('+1'));

        expect(lastPvAtual, 20);
      });

      testWidgets('-1 clamps at 0 when already at 0', (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 0, pvMax: 20));
        await tester.tap(find.text('-1'));

        expect(lastPvAtual, 0);
      });

      testWidgets('-5 clamps at 0 when pvAtual is 3', (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 3, pvMax: 20));
        await tester.tap(find.text('-5'));

        expect(lastPvAtual, 0);
      });

      testWidgets('+5 clamps at max when pvAtual is 18', (tester) async {
        await tester.pumpWidget(buildPvBar(pvAtual: 18, pvMax: 20));
        await tester.tap(find.text('+5'));

        expect(lastPvAtual, 20);
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

        // Clear the field and type new value
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
  });
}
