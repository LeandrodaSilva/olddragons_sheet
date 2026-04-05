import 'package:flutter_test/flutter_test.dart';
import 'package:ods/controllers/class_controller.dart';

void main() {
  group('ClassController', () {
    late ClassController controller;

    setUp(() {
      controller = ClassController();
    });

    group('classes list', () {
      test('has 4 classes', () {
        expect(controller.classes.length, 4);
      });

      test('contains Clérigo', () {
        final clerigo =
            controller.classes.firstWhere((c) => c.name == 'Clérigo');
        expect(clerigo.name, 'Clérigo');
        expect(clerigo.img, 'assets/images/cleric.png');
      });

      test('contains Homem de Armas', () {
        final warrior =
            controller.classes.firstWhere((c) => c.name == 'Homem de Armas');
        expect(warrior.name, 'Homem de Armas');
        expect(warrior.img, 'assets/images/warrior.png');
      });

      test('contains Ladrão', () {
        final thief =
            controller.classes.firstWhere((c) => c.name == 'Ladrão');
        expect(thief.name, 'Ladrão');
        expect(thief.img, 'assets/images/thief.png');
      });

      test('contains Mago', () {
        final mage = controller.classes.firstWhere((c) => c.name == 'Mago');
        expect(mage.name, 'Mago');
        expect(mage.img, 'assets/images/mage.png');
      });
    });

    group('findOneByClassName()', () {
      test('finds Clérigo by name', () {
        final result = controller.findOneByClassName('Clérigo');
        expect(result.name, 'Clérigo');
      });

      test('finds Homem de Armas by name', () {
        final result = controller.findOneByClassName('Homem de Armas');
        expect(result.name, 'Homem de Armas');
      });

      test('finds Ladrão by name', () {
        final result = controller.findOneByClassName('Ladrão');
        expect(result.name, 'Ladrão');
      });

      test('finds Mago by name', () {
        final result = controller.findOneByClassName('Mago');
        expect(result.name, 'Mago');
      });

      test('returns first class for unknown class name', () {
        final result = controller.findOneByClassName('Paladino');
        expect(result.name, controller.classes.first.name);
      });

      test('returns first class for empty name', () {
        final result = controller.findOneByClassName('');
        expect(result.name, controller.classes.first.name);
      });
    });
  });
}
