import 'package:flutter_test/flutter_test.dart';
import 'package:ods/controllers/dice_controller.dart';

void main() {
  group('DiceResult', () {
    test('stores all fields correctly', () {
      final result = DiceResult(
        expression: '2d6+3',
        rolls: [4, 5],
        modifier: 3,
        total: 12,
      );

      expect(result.expression, '2d6+3');
      expect(result.rolls, [4, 5]);
      expect(result.modifier, 3);
      expect(result.total, 12);
    });

    test('modifier defaults to 0', () {
      final result = DiceResult(
        expression: '1d6',
        rolls: [3],
        total: 3,
      );

      expect(result.modifier, 0);
    });
  });

  group('DiceController', () {
    late DiceController controller;

    setUp(() {
      controller = DiceController();
    });

    group('rolar()', () {
      test('returns value between 1 and lados for d6', () {
        for (var i = 0; i < 100; i++) {
          final result = controller.rolar(6);
          expect(result, greaterThanOrEqualTo(1));
          expect(result, lessThanOrEqualTo(6));
        }
      });

      test('returns value between 1 and lados for d20', () {
        for (var i = 0; i < 100; i++) {
          final result = controller.rolar(20);
          expect(result, greaterThanOrEqualTo(1));
          expect(result, lessThanOrEqualTo(20));
        }
      });

      test('returns 1 for d1', () {
        final result = controller.rolar(1);
        expect(result, 1);
      });
    });

    group('rolarDado()', () {
      test('returns correct structure for d6', () {
        final result = controller.rolarDado(6);

        expect(result.expression, '1d6');
        expect(result.rolls.length, 1);
        expect(result.rolls[0], greaterThanOrEqualTo(1));
        expect(result.rolls[0], lessThanOrEqualTo(6));
        expect(result.total, result.rolls[0]);
        expect(result.modifier, 0);
      });

      test('returns correct structure for d20', () {
        final result = controller.rolarDado(20);

        expect(result.expression, '1d20');
        expect(result.rolls.length, 1);
        expect(result.rolls[0], greaterThanOrEqualTo(1));
        expect(result.rolls[0], lessThanOrEqualTo(20));
        expect(result.total, result.rolls[0]);
      });

      test('adds result to history', () {
        expect(controller.historico.length, 0);
        controller.rolarDado(6);
        expect(controller.historico.length, 1);
      });
    });

    group('rolarExpressao()', () {
      test('parses 1d6 correctly', () {
        final result = controller.rolarExpressao('1d6');

        expect(result.expression, '1d6');
        expect(result.rolls.length, 1);
        expect(result.rolls[0], greaterThanOrEqualTo(1));
        expect(result.rolls[0], lessThanOrEqualTo(6));
        expect(result.modifier, 0);
        expect(result.total, result.rolls[0]);
      });

      test('parses 2d6+3 correctly', () {
        final result = controller.rolarExpressao('2d6+3');

        expect(result.expression, '2d6+3');
        expect(result.rolls.length, 2);
        expect(result.modifier, 3);
        for (final roll in result.rolls) {
          expect(roll, greaterThanOrEqualTo(1));
          expect(roll, lessThanOrEqualTo(6));
        }
        final rollsSum = result.rolls.fold(0, (sum, r) => sum + r);
        expect(result.total, rollsSum + 3);
      });

      test('parses 3d8-2 correctly', () {
        final result = controller.rolarExpressao('3d8-2');

        expect(result.expression, '3d8-2');
        expect(result.rolls.length, 3);
        expect(result.modifier, -2);
        for (final roll in result.rolls) {
          expect(roll, greaterThanOrEqualTo(1));
          expect(roll, lessThanOrEqualTo(8));
        }
        final rollsSum = result.rolls.fold(0, (sum, r) => sum + r);
        expect(result.total, rollsSum - 2);
      });

      test('handles spaces in expression', () {
        final result = controller.rolarExpressao('2d6 + 3');

        expect(result.expression, '2d6 + 3');
        expect(result.rolls.length, 2);
        expect(result.modifier, 3);
      });

      test('returns zero result for invalid expression', () {
        final result = controller.rolarExpressao('abc');

        expect(result.expression, 'abc');
        expect(result.rolls, [0]);
        expect(result.total, 0);
      });

      test('returns zero result for empty expression', () {
        final result = controller.rolarExpressao('');

        expect(result.expression, '');
        expect(result.rolls, [0]);
        expect(result.total, 0);
      });

      test('returns zero result for malformed expression', () {
        final result = controller.rolarExpressao('d6');

        expect(result.rolls, [0]);
        expect(result.total, 0);
      });

      test('adds result to history', () {
        expect(controller.historico.length, 0);
        controller.rolarExpressao('1d6');
        expect(controller.historico.length, 1);
      });
    });

    group('history management', () {
      test('stores results newest first', () {
        controller.rolarDado(6);
        controller.rolarDado(20);

        expect(controller.historico.length, 2);
        expect(controller.historico[0].expression, '1d20');
        expect(controller.historico[1].expression, '1d6');
      });

      test('limits history to 5 entries', () {
        for (var i = 0; i < 7; i++) {
          controller.rolarDado(6);
        }

        expect(controller.historico.length, 5);
      });

      test('evicts oldest entry when exceeding limit', () {
        // Roll 6 different dice to distinguish entries
        controller.rolarDado(4);
        controller.rolarDado(6);
        controller.rolarDado(8);
        controller.rolarDado(10);
        controller.rolarDado(12);
        controller.rolarDado(20);

        expect(controller.historico.length, 5);
        // Oldest (d4) should be evicted, newest (d20) should be first
        expect(controller.historico[0].expression, '1d20');
        expect(controller.historico[4].expression, '1d6');
      });
    });
  });
}
