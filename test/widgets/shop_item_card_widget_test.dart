import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ods/widgets/shop_item_card_widget.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('ShopItemCard', () {
    bool? buyCalled;

    Widget buildShopItemCard({
      String nome = 'Espada Longa',
      String tipo = 'arma',
      int precoPO = 10,
      String dano = '1d8',
      String tipoDano = 'Co.',
      double peso = 2.0,
      int bonusDefesa = 0,
      bool canBuy = true,
      String critico = '',
      String especial = '',
      int reducaoMov = 0,
      int bonusMaxDes = 99,
      String tamanho = 'M',
      String descricao = '',
    }) {
      buyCalled = null;
      final item = createTestItem(
        nome: nome,
        tipo: tipo,
        precoPO: precoPO,
        dano: dano,
        tipoDano: tipoDano,
        peso: peso,
        bonusDefesa: bonusDefesa,
        critico: critico,
        especial: especial,
        reducaoMov: reducaoMov,
        bonusMaxDes: bonusMaxDes,
        tamanho: tamanho,
        descricao: descricao,
      );

      return wrapWithMaterialApp(
        ShopItemCard(
          item: item,
          canBuy: canBuy,
          onBuy: () => buyCalled = true,
        ),
      );
    }

    group('price display', () {
      testWidgets('shows price in PO when precoPO > 0', (tester) async {
        await tester.pumpWidget(buildShopItemCard(precoPO: 15));
        expect(find.text('15 PO'), findsOneWidget);
      });

      testWidgets('shows "< 1 PO" when precoPO is 0', (tester) async {
        await tester.pumpWidget(buildShopItemCard(precoPO: 0));
        expect(find.text('< 1 PO'), findsOneWidget);
      });
    });

    group('buy button', () {
      testWidgets('shows Comprar button', (tester) async {
        await tester.pumpWidget(buildShopItemCard());
        expect(find.text('Comprar'), findsOneWidget);
      });

      testWidgets('button is enabled when canBuy is true', (tester) async {
        await tester.pumpWidget(buildShopItemCard(canBuy: true));

        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Comprar'),
        );
        expect(button.onPressed, isNotNull);
      });

      testWidgets('button is disabled when canBuy is false', (tester) async {
        await tester.pumpWidget(buildShopItemCard(canBuy: false));

        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Comprar'),
        );
        expect(button.onPressed, isNull);
      });

      testWidgets('tapping buy button calls onBuy', (tester) async {
        await tester.pumpWidget(buildShopItemCard(canBuy: true));
        await tester.tap(find.text('Comprar'));

        expect(buyCalled, true);
      });

      testWidgets('tapping disabled buy button does not call onBuy',
          (tester) async {
        await tester.pumpWidget(buildShopItemCard(canBuy: false));
        await tester.tap(find.text('Comprar'));

        expect(buyCalled, isNull);
      });
    });

    group('item info display', () {
      testWidgets('shows item name', (tester) async {
        await tester.pumpWidget(buildShopItemCard(nome: 'Adaga'));
        expect(find.text('Adaga'), findsOneWidget);
      });

      testWidgets('shows line2 with critico when present', (tester) async {
        await tester.pumpWidget(buildShopItemCard(critico: '19-20 x2'));
        expect(find.textContaining('Crit: 19-20 x2'), findsOneWidget);
      });

      testWidgets('shows reducaoMov in line2 for armor', (tester) async {
        await tester.pumpWidget(buildShopItemCard(
          tipo: 'armadura',
          nome: 'Cota de Malha',
          dano: '',
          bonusDefesa: 5,
          reducaoMov: 3,
          peso: 15.0,
        ));
        expect(find.textContaining('-3m mov'), findsOneWidget);
      });

      testWidgets('shows bonusMaxDes in line2 when < 99', (tester) async {
        await tester.pumpWidget(buildShopItemCard(
          tipo: 'armadura',
          nome: 'Armadura Pesada',
          dano: '',
          bonusDefesa: 7,
          bonusMaxDes: 2,
          peso: 20.0,
        ));
        expect(find.textContaining('Max DES +2'), findsOneWidget);
      });

      testWidgets('shows descricao when no other line1 parts',
          (tester) async {
        await tester.pumpWidget(buildShopItemCard(
          tipo: 'geral',
          nome: 'Corda',
          dano: '',
          tipoDano: '',
          peso: 0,
          bonusDefesa: 0,
          descricao: '15 metros',
        ));
        expect(find.textContaining('15 metros'), findsOneWidget);
      });
    });
  });
}
