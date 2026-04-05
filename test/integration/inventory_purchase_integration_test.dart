import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ods/controllers/inventory_controller.dart';
import 'package:ods/controllers/sheet_controller.dart';
import 'package:ods/controllers/shop_controller.dart';
import 'package:ods/models/item_model.dart';
import 'package:ods/models/sheet_model.dart';

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  final FakeUser _user;
  FakeFirebaseAuth({String uid = 'test-uid'}) : _user = FakeUser(uid: uid);

  @override
  User? get currentUser => _user;
}

class FakeUser extends Fake implements User {
  @override
  final String uid;
  FakeUser({required this.uid});
}

void main() {
  group('Integração Firebase — Inventário e compras na loja', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FakeFirebaseAuth fakeAuth;
    late SheetController sheetController;
    late InventoryController inventoryController;
    late ShopController shopController;
    late Sheet sheet;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      fakeAuth = FakeFirebaseAuth(uid: 'player-1');
      sheetController = SheetController(firestore: fakeFirestore, auth: fakeAuth);
      shopController = ShopController();

      // Cria uma ficha de personagem
      sheet = Sheet(
        name: 'Aventureiro',
        race: 'Humano',
        classEspec: 'Homem de Armas',
        level: '1',
        ouro: 180, // 3d6 × 10 (máximo)
        forca: 14,
        destreza: 12,
      );
      await sheetController.add(sheet);
      await Future.delayed(Duration.zero);

      // Cria controller de inventário para essa ficha
      inventoryController = InventoryController(
        sheetId: sheet.id,
        firestore: fakeFirestore,
      );
      await Future.delayed(Duration.zero);
    });

    tearDown(() {
      inventoryController.dispose();
      sheetController.dispose();
    });

    group('Compra de item na loja', () {
      test('comprar item adiciona ao inventário e reduz ouro', () async {
        // Encontra a Espada Longa no catálogo
        final armas = shopController.filtrarPorTipo('armas');
        final espadaLonga = armas.firstWhere((i) => i.nome == 'Espada Longa');

        // Verifica que o jogador pode comprar
        expect(sheet.ouro, greaterThanOrEqualTo(espadaLonga.precoPO));

        // Simula a compra (como _comprarItem faz no PlayScreen)
        final ouroAntes = sheet.ouro;
        sheet.ouro -= espadaLonga.precoPO;
        await sheetController.add(sheet);

        final copia = Item(
          nome: espadaLonga.nome,
          tipo: espadaLonga.tipo,
          dano: espadaLonga.dano,
          tipoDano: espadaLonga.tipoDano,
          peso: espadaLonga.peso,
          precoPO: espadaLonga.precoPO,
          tamanho: espadaLonga.tamanho,
          critico: espadaLonga.critico,
        );
        inventoryController.addItem(copia);
        await Future.delayed(Duration.zero);

        // Verifica que o ouro diminuiu
        final sheetData =
            await fakeFirestore.collection('sheets').doc(sheet.id).get();
        expect(sheetData.data()?['ouro'], ouroAntes - espadaLonga.precoPO);

        // Verifica que o item aparece no inventário
        final itemsSnapshot = await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .get();
        expect(itemsSnapshot.docs.length, 1);
        expect(itemsSnapshot.docs.first.data()['nome'], 'Espada Longa');
      });

      test('não pode comprar se não tem ouro suficiente', () async {
        // Gasta quase todo o ouro
        sheet.ouro = 5;
        await sheetController.add(sheet);
        await Future.delayed(Duration.zero);

        final armas = shopController.filtrarPorTipo('armas');
        final espadaLonga = armas.firstWhere((i) => i.nome == 'Espada Longa');

        // Verifica que não pode comprar
        expect(sheet.ouro < espadaLonga.precoPO, isTrue);
      });

      test('comprar múltiplos itens diferentes', () async {
        sheet.ouro = 500;
        await sheetController.add(sheet);
        await Future.delayed(Duration.zero);

        // Compra uma arma
        final armas = shopController.filtrarPorTipo('armas');
        final adaga = armas.firstWhere((i) => i.nome == 'Adaga');
        sheet.ouro -= adaga.precoPO;
        inventoryController.addItem(Item(
          nome: adaga.nome,
          tipo: adaga.tipo,
          dano: adaga.dano,
          peso: adaga.peso,
          precoPO: adaga.precoPO,
        ));

        // Compra uma armadura
        final armaduras = shopController.filtrarPorTipo('armaduras');
        final escudo =
            armaduras.firstWhere((i) => i.nome == 'Escudo de Aço');
        sheet.ouro -= escudo.precoPO;
        inventoryController.addItem(Item(
          nome: escudo.nome,
          tipo: escudo.tipo,
          bonusDefesa: escudo.bonusDefesa,
          peso: escudo.peso,
          precoPO: escudo.precoPO,
        ));

        await sheetController.add(sheet);
        await Future.delayed(Duration.zero);

        // Verifica os 2 itens no inventário
        final itemsSnapshot = await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .get();
        expect(itemsSnapshot.docs.length, 2);

        final nomes = itemsSnapshot.docs.map((d) => d.data()['nome']).toSet();
        expect(nomes, containsAll(['Adaga', 'Escudo de Aço']));
      });
    });

    group('Gerenciamento de inventário', () {
      test('equipar item atualiza flag no Firestore', () async {
        // Adiciona item ao inventário
        await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .add({
          'nome': 'Espada Longa',
          'tipo': 'arma',
          'equipado': false,
          'peso': 2.0,
          'quantidade': 1,
        });
        await Future.delayed(Duration.zero);

        expect(inventoryController.items.length, 1);
        expect(inventoryController.items.first.equipado, false);

        // Equipa o item
        inventoryController.toggleEquipped(inventoryController.items.first);
        await Future.delayed(Duration.zero);

        // Verifica no Firestore
        final items = await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .get();
        expect(items.docs.first.data()['equipado'], true);
      });

      test('desequipar item atualiza flag no Firestore', () async {
        await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .add({
          'nome': 'Cota de Malha',
          'tipo': 'armadura',
          'equipado': true,
          'peso': 15.0,
          'quantidade': 1,
        });
        await Future.delayed(Duration.zero);

        // Desequipa
        inventoryController.toggleEquipped(inventoryController.items.first);
        await Future.delayed(Duration.zero);

        final items = await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .get();
        expect(items.docs.first.data()['equipado'], false);
      });

      test('atualizar quantidade de munição', () async {
        await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .add({
          'nome': 'Flechas',
          'tipo': 'municao',
          'quantidade': 20,
          'peso': 0.5,
          'equipado': false,
        });
        await Future.delayed(Duration.zero);

        // Usa 5 flechas
        final flechas = inventoryController.items.first;
        inventoryController.updateQuantity(flechas, 15);
        await Future.delayed(Duration.zero);

        final items = await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .get();
        expect(items.docs.first.data()['quantidade'], 15);
      });

      test('item é removido quando quantidade chega a zero', () async {
        await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .add({
          'nome': 'Tochas',
          'tipo': 'geral',
          'quantidade': 1,
          'peso': 0.5,
          'equipado': false,
        });
        await Future.delayed(Duration.zero);

        final tochas = inventoryController.items.first;
        inventoryController.updateQuantity(tochas, 0);
        await Future.delayed(Duration.zero);

        final items = await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .get();
        expect(items.docs, isEmpty);
      });

      test('remover item do inventário', () async {
        await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .add({
          'nome': 'Adaga',
          'tipo': 'arma',
          'quantidade': 1,
          'peso': 0.5,
          'equipado': false,
        });
        await Future.delayed(Duration.zero);

        expect(inventoryController.items.length, 1);

        inventoryController.removeItem(inventoryController.items.first);
        await Future.delayed(Duration.zero);

        final items = await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .get();
        expect(items.docs, isEmpty);
      });
    });

    group('Peso total do inventário', () {
      test('peso total reflete itens no Firestore', () async {
        await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .add({
          'nome': 'Espada Longa',
          'tipo': 'arma',
          'quantidade': 1,
          'peso': 2.0,
          'equipado': false,
        });
        await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .add({
          'nome': 'Cota de Malha',
          'tipo': 'armadura',
          'quantidade': 1,
          'peso': 15.0,
          'equipado': true,
        });
        await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .add({
          'nome': 'Flechas',
          'tipo': 'municao',
          'quantidade': 20,
          'peso': 0.5,
          'equipado': false,
        });
        await Future.delayed(Duration.zero);

        // 2.0 * 1 + 15.0 * 1 + 0.5 * 20 = 27.0
        expect(inventoryController.pesoTotal, 27.0);
      });

      test('peso total atualiza após remover item', () async {
        await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .add({
          'nome': 'Espada',
          'tipo': 'arma',
          'quantidade': 1,
          'peso': 2.0,
          'equipado': false,
        });
        await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .add({
          'nome': 'Escudo',
          'tipo': 'escudo',
          'quantidade': 1,
          'peso': 3.0,
          'equipado': false,
        });
        await Future.delayed(Duration.zero);

        expect(inventoryController.pesoTotal, 5.0);

        // Remove escudo
        final escudo =
            inventoryController.items.firstWhere((i) => i.nome == 'Escudo');
        inventoryController.removeItem(escudo);
        await Future.delayed(Duration.zero);

        expect(inventoryController.pesoTotal, 2.0);
      });
    });

    group('Fluxo completo de sessão de jogo', () {
      test('simula sessão: compra + equipa + combate + loot', () async {
        sheet.ouro = 300;
        await sheetController.add(sheet);
        await Future.delayed(Duration.zero);

        // 1. Compra Espada Longa
        final armas = shopController.filtrarPorTipo('armas');
        final espada = armas.firstWhere((i) => i.nome == 'Espada Longa');
        sheet.ouro -= espada.precoPO;
        inventoryController.addItem(Item(
          nome: espada.nome,
          tipo: espada.tipo,
          dano: espada.dano,
          peso: espada.peso,
        ));
        await sheetController.add(sheet);
        await Future.delayed(Duration.zero);

        // 2. Equipa a espada
        final espadaInv = inventoryController.items.first;
        inventoryController.toggleEquipped(espadaInv);
        await Future.delayed(Duration.zero);

        // Verifica espada equipada
        final itemDoc = await fakeFirestore
            .collection('sheets')
            .doc(sheet.id)
            .collection('items')
            .get();
        expect(itemDoc.docs.first.data()['equipado'], true);

        // 3. Combate: leva dano
        sheet.pvAtual = (sheet.pvAtual - 12).clamp(0, sheet.pvMax);
        await sheetController.add(sheet);
        await Future.delayed(Duration.zero);

        var sheetData =
            await fakeFirestore.collection('sheets').doc(sheet.id).get();
        expect(sheetData.data()?['pvAtual'], lessThan(sheet.pvMax));

        // 4. Loot: ganha 50 PO e 200 XP
        sheet.ouro += 50;
        sheet.xpAtual += 200;
        await sheetController.add(sheet);
        await Future.delayed(Duration.zero);

        sheetData =
            await fakeFirestore.collection('sheets').doc(sheet.id).get();
        expect(sheetData.data()?['xpAtual'], 200);
        expect(sheetData.data()?['ouro'],
            300 - espada.precoPO + 50); // ouro final
      });
    });
  });
}
