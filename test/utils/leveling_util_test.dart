import 'package:flutter_test/flutter_test.dart';
import 'package:ods/controllers/class_controller.dart';
import 'package:ods/models/class_model.dart';
import 'package:ods/utils/leveling_util.dart';

void main() {
  group('Leveling', () {
    final controller = ClassController();
    Class byName(String name) => controller.findOneByClassName(name);

    group('xpProximoNivel()', () {
      test('retorna o XP acumulado do próximo nível', () {
        final guerreiro = byName('Homem de Armas');
        expect(
          Leveling.xpProximoNivel(classe: guerreiro, nivelAtual: 1),
          2000,
        );
        expect(
          Leveling.xpProximoNivel(classe: guerreiro, nivelAtual: 9),
          100000,
        );
      });

      test('retorna null no nível máximo', () {
        final guerreiro = byName('Homem de Armas');
        expect(
          Leveling.xpProximoNivel(classe: guerreiro, nivelAtual: 10),
          isNull,
        );
      });
    });

    group('podeSubir()', () {
      final mago = byName('Mago');

      test('falso quando o XP é insuficiente', () {
        expect(
          Leveling.podeSubir(classe: mago, nivelAtual: 1, xpAtual: 0),
          isFalse,
        );
        expect(
          Leveling.podeSubir(classe: mago, nivelAtual: 1, xpAtual: 2499),
          isFalse,
        );
      });

      test('verdadeiro quando o XP atinge o limiar', () {
        expect(
          Leveling.podeSubir(classe: mago, nivelAtual: 1, xpAtual: 2500),
          isTrue,
        );
        expect(
          Leveling.podeSubir(classe: mago, nivelAtual: 1, xpAtual: 9999),
          isTrue,
        );
      });

      test('falso no nível máximo, mesmo com muito XP', () {
        expect(
          Leveling.podeSubir(classe: mago, nivelAtual: 10, xpAtual: 999999),
          isFalse,
        );
      });
    });
  });
}
