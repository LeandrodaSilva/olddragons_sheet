import 'package:flutter_test/flutter_test.dart';
import 'package:ods/models/sheet_model.dart';

void main() {
  group('Sheet', () {
    group('constructor defaults', () {
      test('has correct default values', () {
        final sheet = Sheet();

        expect(sheet.id, '');
        expect(sheet.name, '');
        expect(sheet.player, '');
        expect(sheet.race, '');
        expect(sheet.classEspec, '');
        expect(sheet.level, '1');
        expect(sheet.align, '');
        expect(sheet.physicalCharacteristics, '');
        expect(sheet.forca, 10);
        expect(sheet.destreza, 10);
        expect(sheet.constituicao, 10);
        expect(sheet.inteligencia, 10);
        expect(sheet.sabedoria, 10);
        expect(sheet.carisma, 10);
        expect(sheet.pvMax, 0);
        expect(sheet.pvAtual, 0);
        expect(sheet.ca, 10);
        expect(sheet.ba, 0);
        expect(sheet.jp, 15);
        expect(sheet.movimento, 9);
        expect(sheet.platina, 0);
        expect(sheet.electrum, 0);
        expect(sheet.ouro, 0);
        expect(sheet.prata, 0);
        expect(sheet.cobre, 0);
        expect(sheet.xpAtual, 0);
        expect(sheet.notas, '');
      });
    });

    group('toMap()', () {
      test('serializes all fields correctly', () {
        final sheet = Sheet(
          name: 'Aragorn',
          player: 'Jogador1',
          race: 'Humano',
          classEspec: 'Homem de Armas',
          level: '5',
          align: 'Neutro',
          physicalCharacteristics: 'Alto',
          forca: 16,
          destreza: 14,
          constituicao: 15,
          inteligencia: 12,
          sabedoria: 13,
          carisma: 11,
          pvMax: 45,
          pvAtual: 30,
          ca: 16,
          ba: 3,
          jp: 12,
          movimento: 9,
          platina: 1,
          electrum: 2,
          ouro: 50,
          prata: 30,
          cobre: 100,
          xpAtual: 6500,
          notas: 'Líder do grupo',
        );

        final map = sheet.toMap();

        expect(map['name'], 'Aragorn');
        expect(map['player'], 'Jogador1');
        expect(map['race'], 'Humano');
        expect(map['classEspec'], 'Homem de Armas');
        expect(map['level'], '5');
        expect(map['align'], 'Neutro');
        expect(map['physicalCharacteristics'], 'Alto');
        expect(map['forca'], 16);
        expect(map['destreza'], 14);
        expect(map['constituicao'], 15);
        expect(map['inteligencia'], 12);
        expect(map['sabedoria'], 13);
        expect(map['carisma'], 11);
        expect(map['pvMax'], 45);
        expect(map['pvAtual'], 30);
        expect(map['ca'], 16);
        expect(map['ba'], 3);
        expect(map['jp'], 12);
        expect(map['movimento'], 9);
        expect(map['platina'], 1);
        expect(map['electrum'], 2);
        expect(map['ouro'], 50);
        expect(map['prata'], 30);
        expect(map['cobre'], 100);
        expect(map['xpAtual'], 6500);
        expect(map['notas'], 'Líder do grupo');
      });

      test('does not include id in map', () {
        final sheet = Sheet(id: 'abc123');
        final map = sheet.toMap();
        expect(map.containsKey('id'), false);
      });
    });

    group('fromMap()', () {
      test('deserializes all fields from complete map', () {
        final map = {
          'name': 'Legolas',
          'player': 'Jogador2',
          'race': 'Elfo',
          'classEspec': 'Ladrão',
          'level': '3',
          'align': 'Ordeiro',
          'physicalCharacteristics': 'Loiro',
          'forca': 12,
          'destreza': 18,
          'constituicao': 10,
          'inteligencia': 14,
          'sabedoria': 13,
          'carisma': 16,
          'pvMax': 20,
          'pvAtual': 15,
          'ca': 14,
          'ba': 2,
          'jp': 13,
          'movimento': 12,
          'platina': 0,
          'electrum': 5,
          'ouro': 100,
          'prata': 20,
          'cobre': 50,
          'xpAtual': 3000,
          'notas': 'Arqueiro',
        };

        final sheet = Sheet.fromMap('doc123', map);

        expect(sheet.id, 'doc123');
        expect(sheet.name, 'Legolas');
        expect(sheet.player, 'Jogador2');
        expect(sheet.race, 'Elfo');
        expect(sheet.classEspec, 'Ladrão');
        expect(sheet.level, '3');
        expect(sheet.align, 'Ordeiro');
        expect(sheet.physicalCharacteristics, 'Loiro');
        expect(sheet.forca, 12);
        expect(sheet.destreza, 18);
        expect(sheet.constituicao, 10);
        expect(sheet.inteligencia, 14);
        expect(sheet.sabedoria, 13);
        expect(sheet.carisma, 16);
        expect(sheet.pvMax, 20);
        expect(sheet.pvAtual, 15);
        expect(sheet.ca, 14);
        expect(sheet.ba, 2);
        expect(sheet.jp, 13);
        expect(sheet.movimento, 12);
        expect(sheet.platina, 0);
        expect(sheet.electrum, 5);
        expect(sheet.ouro, 100);
        expect(sheet.prata, 20);
        expect(sheet.cobre, 50);
        expect(sheet.xpAtual, 3000);
        expect(sheet.notas, 'Arqueiro');
      });

      test('uses defaults for missing fields', () {
        final sheet = Sheet.fromMap('doc456', {});

        expect(sheet.id, 'doc456');
        expect(sheet.name, '');
        expect(sheet.player, '');
        expect(sheet.race, '');
        expect(sheet.classEspec, '');
        expect(sheet.level, '1');
        expect(sheet.align, '');
        expect(sheet.physicalCharacteristics, '');
        expect(sheet.forca, 10);
        expect(sheet.destreza, 10);
        expect(sheet.constituicao, 10);
        expect(sheet.inteligencia, 10);
        expect(sheet.sabedoria, 10);
        expect(sheet.carisma, 10);
        expect(sheet.pvMax, 0);
        expect(sheet.pvAtual, 0);
        expect(sheet.ca, 10);
        expect(sheet.ba, 0);
        expect(sheet.jp, 15);
        expect(sheet.movimento, 9);
        expect(sheet.platina, 0);
        expect(sheet.electrum, 0);
        expect(sheet.ouro, 0);
        expect(sheet.prata, 0);
        expect(sheet.cobre, 0);
        expect(sheet.xpAtual, 0);
        expect(sheet.notas, '');
      });

      test('round-trip toMap/fromMap preserves data', () {
        final original = Sheet(
          name: 'Gimli',
          race: 'Halfling',
          classEspec: 'Homem de Armas',
          level: '7',
          forca: 18,
          destreza: 8,
          constituicao: 16,
          inteligencia: 10,
          sabedoria: 12,
          carisma: 8,
          pvMax: 60,
          pvAtual: 45,
          ca: 18,
          ba: 5,
          jp: 10,
          movimento: 6,
          ouro: 200,
          xpAtual: 12000,
          notas: 'Anão guerreiro',
        );

        final restored = Sheet.fromMap('id1', original.toMap());

        expect(restored.name, original.name);
        expect(restored.race, original.race);
        expect(restored.classEspec, original.classEspec);
        expect(restored.level, original.level);
        expect(restored.forca, original.forca);
        expect(restored.destreza, original.destreza);
        expect(restored.constituicao, original.constituicao);
        expect(restored.inteligencia, original.inteligencia);
        expect(restored.sabedoria, original.sabedoria);
        expect(restored.carisma, original.carisma);
        expect(restored.pvMax, original.pvMax);
        expect(restored.pvAtual, original.pvAtual);
        expect(restored.ca, original.ca);
        expect(restored.ba, original.ba);
        expect(restored.jp, original.jp);
        expect(restored.movimento, original.movimento);
        expect(restored.ouro, original.ouro);
        expect(restored.xpAtual, original.xpAtual);
        expect(restored.notas, original.notas);
      });
    });

    group('modificador()', () {
      test('returns -5 for value 1', () {
        expect(Sheet.modificador(1), -5);
      });

      test('returns -4 for values 2-3', () {
        expect(Sheet.modificador(2), -4);
        expect(Sheet.modificador(3), -4);
      });

      test('returns -3 for values 4-5', () {
        expect(Sheet.modificador(4), -3);
        expect(Sheet.modificador(5), -3);
      });

      test('returns -2 for values 6-7', () {
        expect(Sheet.modificador(6), -2);
        expect(Sheet.modificador(7), -2);
      });

      test('returns -1 for values 8-9', () {
        expect(Sheet.modificador(8), -1);
        expect(Sheet.modificador(9), -1);
      });

      test('returns 0 for values 10-11', () {
        expect(Sheet.modificador(10), 0);
        expect(Sheet.modificador(11), 0);
      });

      test('returns +1 for values 12-13', () {
        expect(Sheet.modificador(12), 1);
        expect(Sheet.modificador(13), 1);
      });

      test('returns +2 for values 14-15', () {
        expect(Sheet.modificador(14), 2);
        expect(Sheet.modificador(15), 2);
      });

      test('returns +3 for values 16-17', () {
        expect(Sheet.modificador(16), 3);
        expect(Sheet.modificador(17), 3);
      });

      test('returns +4 for values 18-19', () {
        expect(Sheet.modificador(18), 4);
        expect(Sheet.modificador(19), 4);
      });

      test('returns +5 for values 20-21', () {
        expect(Sheet.modificador(20), 5);
        expect(Sheet.modificador(21), 5);
      });

      test('handles overflow values above 21', () {
        expect(Sheet.modificador(22), 5);
        expect(Sheet.modificador(23), 6);
        expect(Sheet.modificador(25), 7);
      });

      test('returns -5 for zero', () {
        expect(Sheet.modificador(0), -5);
      });

      test('returns -5 for negative values', () {
        expect(Sheet.modificador(-1), -5);
        expect(Sheet.modificador(-10), -5);
        expect(Sheet.modificador(-100), -5);
      });

      test('handles very large values', () {
        // valor=100: 5 + ((100 - 21) ~/ 2) = 5 + 39 = 44
        expect(Sheet.modificador(100), 44);
        // valor=50: 5 + ((50 - 21) ~/ 2) = 5 + 14 = 19
        expect(Sheet.modificador(50), 19);
      });
    });
  });
}
