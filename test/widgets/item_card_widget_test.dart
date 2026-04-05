import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ods/widgets/item_card_widget.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('ItemCard', () {
    bool? toggleEquipCalled;
    bool? deleteCalled;
    int? lastQuantity;

    Widget buildItemCard({
      String tipo = 'arma',
      String nome = 'Espada Longa',
      String dano = '1d8',
      int bonusDefesa = 0,
      double peso = 2.0,
      int quantidade = 1,
      bool equipado = false,
      String descricao = '',
    }) {
      toggleEquipCalled = null;
      deleteCalled = null;
      lastQuantity = null;

      final item = createTestItem(
        tipo: tipo,
        nome: nome,
        dano: dano,
        bonusDefesa: bonusDefesa,
        peso: peso,
        quantidade: quantidade,
        equipado: equipado,
        descricao: descricao,
      );

      return wrapWithMaterialApp(
        ItemCard(
          item: item,
          onToggleEquip: () => toggleEquipCalled = true,
          onDelete: () => deleteCalled = true,
          onQuantityChanged: (v) => lastQuantity = v,
        ),
      );
    }

    group('display', () {
      testWidgets('shows item name', (tester) async {
        await tester.pumpWidget(buildItemCard(nome: 'Adaga'));
        expect(find.text('Adaga'), findsOneWidget);
      });

      testWidgets('shows dano in subtitle for weapons', (tester) async {
        await tester.pumpWidget(buildItemCard(dano: '1d8', peso: 2.0));
        expect(find.textContaining('Dano: 1d8'), findsOneWidget);
      });

      testWidgets('shows bonusDefesa in subtitle for armor', (tester) async {
        await tester.pumpWidget(buildItemCard(
          tipo: 'armadura',
          nome: 'Cota de Malha',
          dano: '',
          bonusDefesa: 5,
          peso: 15.0,
        ));
        expect(find.textContaining('+5 CA'), findsOneWidget);
      });

      testWidgets('shows peso in subtitle', (tester) async {
        await tester.pumpWidget(buildItemCard(peso: 2.0));
        expect(find.textContaining('2.0 kg'), findsOneWidget);
      });

      testWidgets('shows descricao when no other subtitle parts',
          (tester) async {
        await tester.pumpWidget(buildItemCard(
          tipo: 'geral',
          nome: 'Corda',
          dano: '',
          peso: 0,
          descricao: 'Uma corda de 15m',
        ));
        expect(find.textContaining('Uma corda de 15m'), findsOneWidget);
      });
    });

    group('equipped state', () {
      testWidgets('uses bold text when equipped', (tester) async {
        await tester.pumpWidget(buildItemCard(equipado: true));

        final textWidget = tester.widget<Text>(find.text('Espada Longa'));
        expect(textWidget.style?.fontWeight, FontWeight.bold);
      });

      testWidgets('uses normal text when not equipped', (tester) async {
        await tester.pumpWidget(buildItemCard(equipado: false));

        final textWidget = tester.widget<Text>(find.text('Espada Longa'));
        expect(textWidget.style?.fontWeight, FontWeight.normal);
      });

      testWidgets('has higher elevation when equipped', (tester) async {
        await tester.pumpWidget(buildItemCard(equipado: true));

        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, 6);
      });

      testWidgets('has lower elevation when not equipped', (tester) async {
        await tester.pumpWidget(buildItemCard(equipado: false));

        final card = tester.widget<Card>(find.byType(Card));
        expect(card.elevation, 2);
      });
    });

    group('equipment toggle', () {
      testWidgets('shows equip button for arma', (tester) async {
        await tester.pumpWidget(buildItemCard(tipo: 'arma'));
        // Should have a circle icon button for equip
        expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
      });

      testWidgets('shows equip button for armadura', (tester) async {
        await tester.pumpWidget(buildItemCard(
          tipo: 'armadura',
          nome: 'Couro',
          dano: '',
          bonusDefesa: 2,
        ));
        expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
      });

      testWidgets('shows equip button for escudo', (tester) async {
        await tester.pumpWidget(buildItemCard(
          tipo: 'escudo',
          nome: 'Escudo',
          dano: '',
          bonusDefesa: 1,
        ));
        expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
      });

      testWidgets('does not show equip button for municao', (tester) async {
        await tester.pumpWidget(buildItemCard(
          tipo: 'municao',
          nome: 'Flechas',
          dano: '',
          quantidade: 20,
        ));
        expect(find.byIcon(Icons.circle_outlined), findsNothing);
        expect(find.byIcon(Icons.check_circle), findsNothing);
      });

      testWidgets('does not show equip button for geral', (tester) async {
        await tester.pumpWidget(buildItemCard(
          tipo: 'geral',
          nome: 'Corda',
          dano: '',
        ));
        expect(find.byIcon(Icons.circle_outlined), findsNothing);
      });

      testWidgets('shows check_circle when equipped', (tester) async {
        await tester.pumpWidget(buildItemCard(equipado: true));
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('tapping equip button calls onToggleEquip', (tester) async {
        await tester.pumpWidget(buildItemCard());
        await tester.tap(find.byIcon(Icons.circle_outlined));

        expect(toggleEquipCalled, true);
      });
    });

    group('quantity controls', () {
      testWidgets('shows quantity controls for municao', (tester) async {
        await tester.pumpWidget(buildItemCard(
          tipo: 'municao',
          nome: 'Flechas',
          dano: '',
          quantidade: 20,
        ));

        expect(find.text('20'), findsOneWidget);
        expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
        expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      });

      testWidgets('shows quantity controls for geral', (tester) async {
        await tester.pumpWidget(buildItemCard(
          tipo: 'geral',
          nome: 'Tochas',
          dano: '',
          quantidade: 1,
        ));

        expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
        expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      });

      testWidgets('shows quantity controls when quantidade > 1',
          (tester) async {
        await tester.pumpWidget(buildItemCard(quantidade: 3));

        expect(find.text('3'), findsOneWidget);
        expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
      });

      testWidgets('does not show quantity controls for arma with qty 1',
          (tester) async {
        await tester.pumpWidget(buildItemCard(tipo: 'arma', quantidade: 1));

        expect(find.byIcon(Icons.remove_circle_outline), findsNothing);
        expect(find.byIcon(Icons.add_circle_outline), findsNothing);
      });

      testWidgets('add button calls onQuantityChanged with +1',
          (tester) async {
        await tester.pumpWidget(buildItemCard(
          tipo: 'municao',
          nome: 'Flechas',
          dano: '',
          quantidade: 10,
        ));
        await tester.tap(find.byIcon(Icons.add_circle_outline));

        expect(lastQuantity, 11);
      });

      testWidgets('remove button calls onQuantityChanged with -1',
          (tester) async {
        await tester.pumpWidget(buildItemCard(
          tipo: 'municao',
          nome: 'Flechas',
          dano: '',
          quantidade: 10,
        ));
        await tester.tap(find.byIcon(Icons.remove_circle_outline));

        expect(lastQuantity, 9);
      });
    });
  });
}
