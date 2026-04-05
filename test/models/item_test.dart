import 'package:flutter_test/flutter_test.dart';
import 'package:ods/models/item_model.dart';

void main() {
  group('Item', () {
    group('constructor defaults', () {
      test('has correct default values', () {
        final item = Item();

        expect(item.id, '');
        expect(item.nome, '');
        expect(item.descricao, '');
        expect(item.tipo, 'geral');
        expect(item.tamanho, 'M');
        expect(item.quantidade, 1);
        expect(item.equipado, false);
        expect(item.dano, '');
        expect(item.tipoDano, '');
        expect(item.critico, '');
        expect(item.alcance, 0);
        expect(item.especial, '');
        expect(item.bonusDefesa, 0);
        expect(item.bonusMaxDes, 99);
        expect(item.reducaoMov, 0);
        expect(item.precoPO, 0);
        expect(item.peso, 0);
      });
    });

    group('toMap()', () {
      test('serializes weapon fields correctly', () {
        final item = Item(
          nome: 'Espada Longa',
          descricao: 'Uma espada afiada',
          tipo: 'arma',
          tamanho: 'M',
          quantidade: 1,
          equipado: true,
          dano: '1d8',
          tipoDano: 'Co.',
          critico: '19-20 x2',
          alcance: 0,
          especial: '',
          precoPO: 10,
          peso: 2.0,
        );

        final map = item.toMap();

        expect(map['nome'], 'Espada Longa');
        expect(map['descricao'], 'Uma espada afiada');
        expect(map['tipo'], 'arma');
        expect(map['tamanho'], 'M');
        expect(map['quantidade'], 1);
        expect(map['equipado'], true);
        expect(map['dano'], '1d8');
        expect(map['tipoDano'], 'Co.');
        expect(map['critico'], '19-20 x2');
        expect(map['alcance'], 0);
        expect(map['especial'], '');
        expect(map['precoPO'], 10);
        expect(map['peso'], 2.0);
      });

      test('serializes armor fields correctly', () {
        final item = Item(
          nome: 'Cota de Malha',
          tipo: 'armadura',
          bonusDefesa: 4,
          bonusMaxDes: 2,
          reducaoMov: 1,
          precoPO: 60,
          peso: 17,
        );

        final map = item.toMap();

        expect(map['bonusDefesa'], 4);
        expect(map['bonusMaxDes'], 2);
        expect(map['reducaoMov'], 1);
      });

      test('does not include id in map', () {
        final item = Item(id: 'item123');
        final map = item.toMap();
        expect(map.containsKey('id'), false);
      });
    });

    group('fromMap()', () {
      test('deserializes all fields from complete map', () {
        final map = {
          'nome': 'Adaga',
          'descricao': 'Pequena lâmina',
          'tipo': 'arma',
          'tamanho': 'P',
          'quantidade': 3,
          'equipado': true,
          'dano': '1d4',
          'tipoDano': 'Pe.',
          'critico': 'x2',
          'alcance': 6,
          'especial': 'Arremesso 3/6',
          'bonusDefesa': 0,
          'bonusMaxDes': 99,
          'reducaoMov': 0,
          'precoPO': 2,
          'peso': 0.5,
        };

        final item = Item.fromMap('itemDoc1', map);

        expect(item.id, 'itemDoc1');
        expect(item.nome, 'Adaga');
        expect(item.descricao, 'Pequena lâmina');
        expect(item.tipo, 'arma');
        expect(item.tamanho, 'P');
        expect(item.quantidade, 3);
        expect(item.equipado, true);
        expect(item.dano, '1d4');
        expect(item.tipoDano, 'Pe.');
        expect(item.critico, 'x2');
        expect(item.alcance, 6);
        expect(item.especial, 'Arremesso 3/6');
        expect(item.bonusDefesa, 0);
        expect(item.bonusMaxDes, 99);
        expect(item.reducaoMov, 0);
        expect(item.precoPO, 2);
        expect(item.peso, 0.5);
      });

      test('uses defaults for missing fields', () {
        final item = Item.fromMap('empty1', {});

        expect(item.id, 'empty1');
        expect(item.nome, '');
        expect(item.descricao, '');
        expect(item.tipo, 'geral');
        expect(item.tamanho, 'M');
        expect(item.quantidade, 1);
        expect(item.equipado, false);
        expect(item.dano, '');
        expect(item.tipoDano, '');
        expect(item.critico, '');
        expect(item.alcance, 0);
        expect(item.especial, '');
        expect(item.bonusDefesa, 0);
        expect(item.bonusMaxDes, 99);
        expect(item.reducaoMov, 0);
        expect(item.precoPO, 0);
        expect(item.peso, 0.0);
      });

      test('handles peso as int from Firestore', () {
        final item = Item.fromMap('id1', {'peso': 5});
        expect(item.peso, 5.0);
        expect(item.peso is double, true);
      });

      test('handles peso as double from Firestore', () {
        final item = Item.fromMap('id2', {'peso': 3.5});
        expect(item.peso, 3.5);
      });

      test('round-trip toMap/fromMap preserves data', () {
        final original = Item(
          nome: 'Arco Longo',
          descricao: 'Arco élfico',
          tipo: 'arma',
          tamanho: 'M',
          quantidade: 1,
          equipado: true,
          dano: '1d8',
          tipoDano: 'Pe.',
          critico: 'x3',
          alcance: 50,
          especial: 'Disparo 25/50, Duas Mãos',
          bonusDefesa: 0,
          bonusMaxDes: 99,
          reducaoMov: 0,
          precoPO: 60,
          peso: 1.5,
        );

        final restored = Item.fromMap('roundtrip', original.toMap());

        expect(restored.nome, original.nome);
        expect(restored.descricao, original.descricao);
        expect(restored.tipo, original.tipo);
        expect(restored.tamanho, original.tamanho);
        expect(restored.quantidade, original.quantidade);
        expect(restored.equipado, original.equipado);
        expect(restored.dano, original.dano);
        expect(restored.tipoDano, original.tipoDano);
        expect(restored.critico, original.critico);
        expect(restored.alcance, original.alcance);
        expect(restored.especial, original.especial);
        expect(restored.bonusDefesa, original.bonusDefesa);
        expect(restored.bonusMaxDes, original.bonusMaxDes);
        expect(restored.reducaoMov, original.reducaoMov);
        expect(restored.precoPO, original.precoPO);
        expect(restored.peso, original.peso);
      });
    });
  });
}
