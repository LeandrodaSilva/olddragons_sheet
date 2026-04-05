import 'package:flutter_test/flutter_test.dart';
import 'package:ods/controllers/shop_controller.dart';

void main() {
  group('ShopController', () {
    late ShopController controller;

    setUp(() {
      controller = ShopController();
    });

    group('catalogo', () {
      test('has items in the catalog', () {
        expect(ShopController.catalogo.isNotEmpty, true);
      });

      test('all items have a nome', () {
        for (final item in ShopController.catalogo) {
          expect(item.nome.isNotEmpty, true,
              reason: 'Item at index ${ShopController.catalogo.indexOf(item)} has empty nome');
        }
      });

      test('all items have unique names', () {
        final nomes = ShopController.catalogo.map((i) => i.nome).toList();
        final uniqueNomes = nomes.toSet();
        expect(uniqueNomes.length, nomes.length,
            reason: 'Duplicate item names found in catalog');
      });

      test('all weapons have peso > 0', () {
        final weapons = ShopController.catalogo.where((i) => i.tipo == 'arma');
        for (final item in weapons) {
          expect(item.peso, greaterThan(0),
              reason: '${item.nome} (arma) has peso ${item.peso}');
        }
      });

      test('all armors have bonusDefesa > 0', () {
        final armors = ShopController.catalogo.where((i) => i.tipo == 'armadura');
        for (final item in armors) {
          expect(item.bonusDefesa, greaterThan(0),
              reason: '${item.nome} (armadura) has bonusDefesa ${item.bonusDefesa}');
        }
      });

      test('no items have negative prices', () {
        for (final item in ShopController.catalogo) {
          expect(item.precoPO, greaterThanOrEqualTo(0),
              reason: '${item.nome} has negative price ${item.precoPO}');
        }
      });

      test('all items have a valid tipo', () {
        final validTypes = {'arma', 'municao', 'armadura', 'escudo', 'geral'};
        for (final item in ShopController.catalogo) {
          expect(validTypes.contains(item.tipo), true,
              reason: '${item.nome} has invalid tipo: ${item.tipo}');
        }
      });
    });

    group('filtrarPorTipo()', () {
      test('todos returns all items', () {
        final result = controller.filtrarPorTipo('todos');
        expect(result.length, ShopController.catalogo.length);
      });

      test('armas returns weapons and ammunition', () {
        final result = controller.filtrarPorTipo('armas');

        expect(result.isNotEmpty, true);
        for (final item in result) {
          expect(
            item.tipo == 'arma' || item.tipo == 'municao',
            true,
            reason: '${item.nome} has tipo ${item.tipo}, expected arma or municao',
          );
        }
      });

      test('armaduras returns armor and shields', () {
        final result = controller.filtrarPorTipo('armaduras');

        expect(result.isNotEmpty, true);
        for (final item in result) {
          expect(
            item.tipo == 'armadura' || item.tipo == 'escudo',
            true,
            reason: '${item.nome} has tipo ${item.tipo}, expected armadura or escudo',
          );
        }
      });

      test('geral returns general items only', () {
        final result = controller.filtrarPorTipo('geral');

        expect(result.isNotEmpty, true);
        for (final item in result) {
          expect(item.tipo, 'geral',
              reason: '${item.nome} has tipo ${item.tipo}, expected geral');
        }
      });

      test('all categories together equal total', () {
        final armas = controller.filtrarPorTipo('armas');
        final armaduras = controller.filtrarPorTipo('armaduras');
        final geral = controller.filtrarPorTipo('geral');
        final todos = controller.filtrarPorTipo('todos');

        expect(armas.length + armaduras.length + geral.length, todos.length);
      });

      test('unknown type returns empty list', () {
        final result = controller.filtrarPorTipo('magias');
        expect(result.isEmpty, true);
      });

      test('armas includes specific known weapons', () {
        final result = controller.filtrarPorTipo('armas');
        final nomes = result.map((i) => i.nome).toList();

        expect(nomes.contains('Espada Longa'), true);
        expect(nomes.contains('Adaga'), true);
      });

      test('armaduras includes specific known armor', () {
        final result = controller.filtrarPorTipo('armaduras');
        final nomes = result.map((i) => i.nome).toList();

        expect(nomes.contains('Cota de Malha'), true);
        expect(nomes.contains('Escudo de Aço'), true);
      });
    });
  });
}
