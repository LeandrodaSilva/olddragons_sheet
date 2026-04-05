import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ods/controllers/inventory_controller.dart';
import 'package:ods/models/item_model.dart';

void main() {
  group('InventoryController', () {
    late FakeFirebaseFirestore fakeFirestore;
    late InventoryController controller;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      controller = InventoryController(
        sheetId: 'sheet-1',
        firestore: fakeFirestore,
      );
      // Allow the snapshot listener to fire
      await Future.delayed(Duration.zero);
    });

    tearDown(() {
      controller.dispose();
    });

    group('items', () {
      test('starts with empty inventory', () {
        expect(controller.items, isEmpty);
      });

      test('items is unmodifiable', () {
        expect(
          () => controller.items.add(Item(nome: 'test')),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('pesoTotal', () {
      test('returns 0.0 for empty inventory', () {
        expect(controller.pesoTotal, 0.0);
      });

      test('calculates total weight correctly', () async {
        await fakeFirestore
            .collection('sheets')
            .doc('sheet-1')
            .collection('items')
            .add({'nome': 'Sword', 'peso': 2.5, 'quantidade': 1});
        await fakeFirestore
            .collection('sheets')
            .doc('sheet-1')
            .collection('items')
            .add({'nome': 'Arrows', 'peso': 0.5, 'quantidade': 20});

        await Future.delayed(Duration.zero);

        expect(controller.pesoTotal, 2.5 * 1 + 0.5 * 20);
      });

      test('handles items with zero weight', () async {
        await fakeFirestore
            .collection('sheets')
            .doc('sheet-1')
            .collection('items')
            .add({'nome': 'Scroll', 'peso': 0, 'quantidade': 1});

        await Future.delayed(Duration.zero);

        expect(controller.pesoTotal, 0.0);
      });
    });

    group('addItem()', () {
      test('writes item to Firestore', () async {
        final item = Item(nome: 'Espada Longa', tipo: 'arma', peso: 2.0);
        controller.addItem(item);

        await Future.delayed(Duration.zero);

        final snapshot = await fakeFirestore
            .collection('sheets')
            .doc('sheet-1')
            .collection('items')
            .get();

        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.data()['nome'], 'Espada Longa');
      });
    });

    group('removeItem()', () {
      test('deletes item from Firestore', () async {
        final docRef = await fakeFirestore
            .collection('sheets')
            .doc('sheet-1')
            .collection('items')
            .add({'nome': 'Adaga', 'peso': 0.5, 'quantidade': 1});

        await Future.delayed(Duration.zero);
        expect(controller.items.length, 1);

        final item = Item(id: docRef.id, nome: 'Adaga');
        controller.removeItem(item);

        await Future.delayed(Duration.zero);

        final snapshot = await fakeFirestore
            .collection('sheets')
            .doc('sheet-1')
            .collection('items')
            .get();

        expect(snapshot.docs, isEmpty);
      });
    });

    group('toggleEquipped()', () {
      test('flips equipped flag and updates Firestore', () async {
        final docRef = await fakeFirestore
            .collection('sheets')
            .doc('sheet-1')
            .collection('items')
            .add({
          'nome': 'Espada',
          'equipado': false,
          'peso': 2.0,
          'quantidade': 1,
        });

        await Future.delayed(Duration.zero);

        final item = controller.items.first;
        expect(item.equipado, false);

        controller.toggleEquipped(item);

        await Future.delayed(Duration.zero);

        final doc = await fakeFirestore
            .collection('sheets')
            .doc('sheet-1')
            .collection('items')
            .doc(docRef.id)
            .get();

        expect(doc.data()?['equipado'], true);
      });
    });

    group('updateQuantity()', () {
      test('updates quantity when > 0', () async {
        final docRef = await fakeFirestore
            .collection('sheets')
            .doc('sheet-1')
            .collection('items')
            .add({
          'nome': 'Flechas',
          'tipo': 'municao',
          'quantidade': 10,
          'peso': 0.5,
        });

        await Future.delayed(Duration.zero);

        final item = controller.items.first;
        controller.updateQuantity(item, 15);

        await Future.delayed(Duration.zero);

        final doc = await fakeFirestore
            .collection('sheets')
            .doc('sheet-1')
            .collection('items')
            .doc(docRef.id)
            .get();

        expect(doc.data()?['quantidade'], 15);
      });

      test('removes item when quantity is 0', () async {
        await fakeFirestore
            .collection('sheets')
            .doc('sheet-1')
            .collection('items')
            .add({
          'nome': 'Flechas',
          'tipo': 'municao',
          'quantidade': 1,
          'peso': 0.5,
        });

        await Future.delayed(Duration.zero);

        final item = controller.items.first;
        controller.updateQuantity(item, 0);

        await Future.delayed(Duration.zero);

        final snapshot = await fakeFirestore
            .collection('sheets')
            .doc('sheet-1')
            .collection('items')
            .get();

        expect(snapshot.docs, isEmpty);
      });

      test('removes item when quantity is negative', () async {
        await fakeFirestore
            .collection('sheets')
            .doc('sheet-1')
            .collection('items')
            .add({
          'nome': 'Flechas',
          'tipo': 'municao',
          'quantidade': 1,
          'peso': 0.5,
        });

        await Future.delayed(Duration.zero);

        final item = controller.items.first;
        controller.updateQuantity(item, -1);

        await Future.delayed(Duration.zero);

        final snapshot = await fakeFirestore
            .collection('sheets')
            .doc('sheet-1')
            .collection('items')
            .get();

        expect(snapshot.docs, isEmpty);
      });
    });

    group('Firestore sync', () {
      test('populates items from Firestore snapshots', () async {
        await fakeFirestore
            .collection('sheets')
            .doc('sheet-1')
            .collection('items')
            .add({'nome': 'Item 1', 'peso': 1.0, 'quantidade': 1});
        await fakeFirestore
            .collection('sheets')
            .doc('sheet-1')
            .collection('items')
            .add({'nome': 'Item 2', 'peso': 2.0, 'quantidade': 1});

        await Future.delayed(Duration.zero);

        expect(controller.items.length, 2);
        final names = controller.items.map((i) => i.nome).toSet();
        expect(names, containsAll(['Item 1', 'Item 2']));
      });
    });
  });
}
