import 'package:flutter_test/flutter_test.dart';
import 'package:ods/controllers/character_controller.dart';

void main() {
  group('CharacterController', () {
    late CharacterController controller;

    setUp(() {
      controller = CharacterController();
    });

    group('characters list', () {
      test('has 4 races', () {
        expect(controller.characters.length, 4);
      });

      test('contains Orc', () {
        final orc = controller.characters.firstWhere((c) => c.name == 'Orc');
        expect(orc.name, 'Orc');
        expect(orc.img, 'assets/images/orc.png');
        expect(orc.movementSpeed, 9);
      });

      test('contains Elfo', () {
        final elfo = controller.characters.firstWhere((c) => c.name == 'Elfo');
        expect(elfo.name, 'Elfo');
        expect(elfo.img, 'assets/images/elf.png');
        expect(elfo.movementSpeed, 9);
      });

      test('contains Halfling', () {
        final halfling =
            controller.characters.firstWhere((c) => c.name == 'Halfling');
        expect(halfling.name, 'Halfling');
        expect(halfling.img, 'assets/images/halfling.png');
        expect(halfling.movementSpeed, 9);
      });

      test('contains Humano', () {
        final humano =
            controller.characters.firstWhere((c) => c.name == 'Humano');
        expect(humano.name, 'Humano');
        expect(humano.img, 'assets/images/human.png');
        expect(humano.movementSpeed, 9);
      });
    });

    group('findOneByRaceName()', () {
      test('finds Orc by name', () {
        final result = controller.findOneByRaceName('Orc');
        expect(result.name, 'Orc');
      });

      test('finds Elfo by name', () {
        final result = controller.findOneByRaceName('Elfo');
        expect(result.name, 'Elfo');
      });

      test('finds Halfling by name', () {
        final result = controller.findOneByRaceName('Halfling');
        expect(result.name, 'Halfling');
      });

      test('finds Humano by name', () {
        final result = controller.findOneByRaceName('Humano');
        expect(result.name, 'Humano');
      });

      test('returns first character for unknown race name', () {
        final result = controller.findOneByRaceName('Anão');
        expect(result.name, controller.characters.first.name);
      });

      test('returns first character for empty name', () {
        final result = controller.findOneByRaceName('');
        expect(result.name, controller.characters.first.name);
      });
    });
  });
}
