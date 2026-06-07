import 'package:flutter_test/flutter_test.dart';
import 'package:ods/controllers/class_controller.dart';
import 'package:ods/models/class_model.dart';
import 'package:ods/utils/magic_calculator_util.dart';

void main() {
  final controller = ClassController();
  Class byName(String name) => controller.findOneByClassName(name);

  group('MagicCalculator', () {
    group('magiasPorDia()', () {
      test('Mago nível 1 com INT comum', () {
        final mago = byName('Mago');
        expect(
          MagicCalculator.magiasPorDia(
              classe: mago, nivel: 1, atributoConjurador: 10),
          [1, 0, 0, 0, 0],
        );
      });

      test('Mago nível 3 com INT alta ganha bônus nos círculos acessíveis', () {
        final mago = byName('Mago');
        // base nível 3 = [2,1,0,0,0]; INT 16 => +1 no 1º e 2º círculos
        expect(
          MagicCalculator.magiasPorDia(
              classe: mago, nivel: 3, atributoConjurador: 16),
          [3, 2, 0, 0, 0],
        );
      });

      test('bônus não se aplica a círculo ainda inacessível', () {
        final mago = byName('Mago');
        // nível 1 só acessa o 1º círculo, mesmo com INT 16
        expect(
          MagicCalculator.magiasPorDia(
              classe: mago, nivel: 1, atributoConjurador: 16),
          [2, 0, 0, 0, 0],
        );
      });

      test('Clérigo nível 5 com SAB 14', () {
        final clerigo = byName('Clérigo');
        // base nível 5 = [2,2,1,0,0]; SAB 14 => +1 no 1º círculo
        expect(
          MagicCalculator.magiasPorDia(
              classe: clerigo, nivel: 5, atributoConjurador: 14),
          [3, 2, 1, 0, 0],
        );
      });

      test('classe não conjuradora retorna lista vazia', () {
        final guerreiro = byName('Homem de Armas');
        expect(
          MagicCalculator.magiasPorDia(
              classe: guerreiro, nivel: 5, atributoConjurador: 18),
          isEmpty,
        );
      });
    });

    group('maiorCirculo()', () {
      test('Mago progride de círculo conforme o nível', () {
        final mago = byName('Mago');
        expect(MagicCalculator.maiorCirculo(classe: mago, nivel: 1), 1);
        expect(MagicCalculator.maiorCirculo(classe: mago, nivel: 5), 3);
        expect(MagicCalculator.maiorCirculo(classe: mago, nivel: 10), 5);
      });

      test('Clérigo no nível 10 acessa o 5º círculo', () {
        expect(
          MagicCalculator.maiorCirculo(classe: byName('Clérigo'), nivel: 10),
          5,
        );
      });

      test('não conjurador retorna 0', () {
        expect(
          MagicCalculator.maiorCirculo(classe: byName('Ladrão'), nivel: 10),
          0,
        );
      });
    });

    group('dados de conjuração das classes', () {
      test('Mago é conjurador arcano', () {
        final mago = byName('Mago');
        expect(mago.conjurador, isTrue);
        expect(mago.tipoMagia, 'arcana');
        expect(mago.magiasPorDia.length, 10);
      });

      test('Clérigo é conjurador divino', () {
        final clerigo = byName('Clérigo');
        expect(clerigo.conjurador, isTrue);
        expect(clerigo.tipoMagia, 'divina');
      });

      test('Guerreiro e Ladrão não são conjuradores', () {
        expect(byName('Homem de Armas').conjurador, isFalse);
        expect(byName('Ladrão').conjurador, isFalse);
      });
    });
  });
}
