import 'package:flutter_test/flutter_test.dart';
import 'package:ods/controllers/class_controller.dart';
import 'package:ods/models/class_model.dart';

void main() {
  group('Class', () {
    group('baseAtaque() e jpBase()', () {
      const classe = Class(
        'Teste',
        '',
        '',
        baPorNivel: [1, 2, 3],
        jpPorNivel: [5, 6, 7],
      );

      test('lê a tabela no nível informado', () {
        expect(classe.baseAtaque(2), 2);
        expect(classe.jpBase(2), 6);
      });

      test('limita ao último nível disponível', () {
        expect(classe.baseAtaque(99), 3);
        expect(classe.jpBase(99), 7);
      });

      test('trata níveis menores que 1', () {
        expect(classe.baseAtaque(0), 1);
        expect(classe.jpBase(0), 5);
      });
    });

    group('xpParaNivel() e nivelMaximo', () {
      const classe = Class('Teste', '', '', xpPorNivel: [0, 100, 300]);

      test('nível 1 sempre custa 0', () {
        expect(classe.xpParaNivel(1), 0);
      });

      test('retorna o XP acumulado de cada nível', () {
        expect(classe.xpParaNivel(2), 100);
        expect(classe.xpParaNivel(3), 300);
      });

      test('retorna null acima do nível máximo', () {
        expect(classe.xpParaNivel(4), isNull);
      });

      test('nivelMaximo reflete o tamanho da tabela de XP', () {
        expect(classe.nivelMaximo, 3);
      });
    });

    group('dados das classes do Livro Básico', () {
      final controller = ClassController();

      test('todas as classes vão até o nível 10', () {
        for (final classe in controller.classes) {
          expect(classe.nivelMaximo, 10,
              reason: '${classe.name} deveria ir até o nível 10');
          expect(classe.baPorNivel.length, 10);
          expect(classe.jpPorNivel.length, 10);
          expect(classe.xpPorNivel.length, 10);
          expect(classe.xpPorNivel.first, 0);
        }
      });

      test('limiares de XP conferem com o SRD', () {
        expect(controller.findOneByClassName('Homem de Armas').xpParaNivel(2),
            2000);
        expect(controller.findOneByClassName('Clérigo').xpParaNivel(2), 1500);
        expect(controller.findOneByClassName('Ladrão').xpParaNivel(2), 1000);
        expect(controller.findOneByClassName('Mago').xpParaNivel(2), 2500);
      });
    });
  });
}
