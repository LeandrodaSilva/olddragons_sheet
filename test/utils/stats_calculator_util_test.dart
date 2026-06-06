import 'package:flutter_test/flutter_test.dart';
import 'package:ods/controllers/class_controller.dart';
import 'package:ods/models/class_model.dart';
import 'package:ods/models/item_model.dart';
import 'package:ods/utils/stats_calculator_util.dart';

void main() {
  group('StatsCalculator', () {
    group('ca()', () {
      test('CA base é 10 sem armadura e DES neutra', () {
        expect(StatsCalculator.ca(destreza: 10, equipados: []), 10);
      });

      test('soma o modificador de DES', () {
        // DES 16 => +3
        expect(StatsCalculator.ca(destreza: 16, equipados: []), 13);
        // DES 6 => -2
        expect(StatsCalculator.ca(destreza: 6, equipados: []), 8);
      });

      test('soma o bônus de defesa das armaduras/escudos equipados', () {
        final couro = Item(tipo: 'armadura', bonusDefesa: 2);
        final escudo = Item(tipo: 'escudo', bonusDefesa: 1);
        // DES 14 (+2) + couro (2) + escudo (1) = 10 + 2 + 2 + 1
        expect(
          StatsCalculator.ca(destreza: 14, equipados: [couro, escudo]),
          15,
        );
      });

      test('limita o mod de DES pelo bônus máximo da armadura', () {
        final pesada = Item(tipo: 'armadura', bonusDefesa: 6, bonusMaxDes: 1);
        // DES 18 (+4) limitado a +1 => 10 + 1 + 6 = 17
        expect(
          StatsCalculator.ca(destreza: 18, equipados: [pesada]),
          17,
        );
      });

      test('aplica o ajuste manual (outros)', () {
        expect(
          StatsCalculator.ca(destreza: 10, equipados: [], outros: 2),
          12,
        );
      });
    });

    group('pvMax()', () {
      test('nível 1: dado de vida cheio + mod CON', () {
        // Guerreiro d10, CON 14 (+2) => 12
        expect(
          StatsCalculator.pvMax(dadoDeVida: 10, constituicao: 14, nivel: 1),
          12,
        );
      });

      test('acumula por nível até o 10º', () {
        // d10, CON 14 (+2), nível 3 => (10+2) * 3 = 36
        expect(
          StatsCalculator.pvMax(dadoDeVida: 10, constituicao: 14, nivel: 3),
          36,
        );
        // CON negativa: d6, CON 8 (-1), nível 2 => (6-1) * 2 = 10
        expect(
          StatsCalculator.pvMax(dadoDeVida: 6, constituicao: 8, nivel: 2),
          10,
        );
      });

      test('limita o ganho por nível ao 10º nível', () {
        // d10, CON 14 (+2), nível 12 => (10+2) * 10 = 120
        expect(
          StatsCalculator.pvMax(dadoDeVida: 10, constituicao: 14, nivel: 12),
          120,
        );
      });

      test('garante no mínimo 1 PV por nível mesmo com CON muito baixa', () {
        // d4, CON 1 (-5) => ganho por nível negativo => mínimo = nº de níveis
        expect(
          StatsCalculator.pvMax(dadoDeVida: 4, constituicao: 1, nivel: 1),
          1,
        );
        expect(
          StatsCalculator.pvMax(dadoDeVida: 4, constituicao: 1, nivel: 3),
          3,
        );
      });

      test('aplica o ajuste manual (outros)', () {
        expect(
          StatsCalculator.pvMax(
              dadoDeVida: 10, constituicao: 14, nivel: 1, outros: 5),
          17,
        );
      });
    });

    group('baseAtaque() e jpBase()', () {
      final classe = const Class(
        'Teste',
        '',
        '',
        dadoDeVida: 8,
        baPorNivel: [1, 2, 3],
        jpPorNivel: [5, 5, 6],
      );

      test('lê a tabela da classe no nível informado', () {
        expect(StatsCalculator.baseAtaque(classe: classe, nivel: 1), 1);
        expect(StatsCalculator.baseAtaque(classe: classe, nivel: 3), 3);
        expect(StatsCalculator.jpBase(classe: classe, nivel: 1), 5);
        expect(StatsCalculator.jpBase(classe: classe, nivel: 3), 6);
      });

      test('limita ao último nível disponível na tabela', () {
        expect(StatsCalculator.baseAtaque(classe: classe, nivel: 9), 3);
        expect(StatsCalculator.jpBase(classe: classe, nivel: 9), 6);
      });

      test('aplica o ajuste manual (outros)', () {
        expect(
          StatsCalculator.baseAtaque(classe: classe, nivel: 1, outros: 2),
          3,
        );
        expect(
          StatsCalculator.jpBase(classe: classe, nivel: 1, outros: 1),
          6,
        );
      });
    });

    group('movimento()', () {
      test('retorna a base da raça sem armadura', () {
        expect(StatsCalculator.movimento(baseRaca: 9, equipados: []), 9);
      });

      test('subtrai a redução das armaduras equipadas', () {
        final pesada = Item(tipo: 'armadura', reducaoMov: 3);
        expect(
          StatsCalculator.movimento(baseRaca: 9, equipados: [pesada]),
          6,
        );
      });

      test('nunca fica abaixo de zero', () {
        final exagerada = Item(tipo: 'armadura', reducaoMov: 20);
        expect(
          StatsCalculator.movimento(baseRaca: 9, equipados: [exagerada]),
          0,
        );
      });

      test('aplica o ajuste manual (outros)', () {
        expect(
          StatsCalculator.movimento(baseRaca: 9, equipados: [], outros: 3),
          12,
        );
      });
    });

    group('valores das classes do Livro Básico', () {
      final controller = ClassController();
      Class byName(String name) => controller.findOneByClassName(name);

      test('Homem de Armas (d10) — BA = nível, JP progride', () {
        final g = byName('Homem de Armas');
        expect(g.dadoDeVida, 10);
        expect(StatsCalculator.baseAtaque(classe: g, nivel: 1), 1);
        expect(StatsCalculator.baseAtaque(classe: g, nivel: 5), 5);
        expect(StatsCalculator.jpBase(classe: g, nivel: 1), 5);
        expect(StatsCalculator.jpBase(classe: g, nivel: 5), 8);
      });

      test('Clérigo (d8)', () {
        final c = byName('Clérigo');
        expect(c.dadoDeVida, 8);
        expect(StatsCalculator.baseAtaque(classe: c, nivel: 4), 3);
        expect(StatsCalculator.jpBase(classe: c, nivel: 4), 7);
      });

      test('Ladrão (d6)', () {
        final l = byName('Ladrão');
        expect(l.dadoDeVida, 6);
        expect(StatsCalculator.baseAtaque(classe: l, nivel: 9), 5);
        expect(StatsCalculator.jpBase(classe: l, nivel: 9), 11);
      });

      test('Mago (d4) — BA 0 no nível 1', () {
        final m = byName('Mago');
        expect(m.dadoDeVida, 4);
        expect(StatsCalculator.baseAtaque(classe: m, nivel: 1), 0);
        expect(StatsCalculator.baseAtaque(classe: m, nivel: 2), 1);
        expect(StatsCalculator.jpBase(classe: m, nivel: 10), 10);
      });
    });
  });
}
