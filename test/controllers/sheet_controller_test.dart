import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ods/controllers/sheet_controller.dart';
import 'package:ods/models/sheet_model.dart';

/// Minimal mock for FirebaseAuth that returns a fake user.
/// This avoids adding firebase_auth_mocks as a dependency.
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
  group('SheetModel (SheetController)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FakeFirebaseAuth fakeAuth;
    late SheetModel sheetModel;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      fakeAuth = FakeFirebaseAuth(uid: 'user-123');
      sheetModel = SheetModel(firestore: fakeFirestore, auth: fakeAuth);
      await Future.delayed(Duration.zero);
    });

    tearDown(() {
      sheetModel.dispose();
    });

    group('items', () {
      test('starts with empty list', () {
        expect(sheetModel.items, isEmpty);
      });

      test('items is unmodifiable', () {
        expect(
          () => sheetModel.items.add(Sheet(name: 'test')),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('add()', () {
      test('creates new document when id is empty', () async {
        final sheet = Sheet(name: 'New Hero', race: 'Humano');

        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        expect(sheet.id, isNotEmpty);

        final snapshot = await fakeFirestore.collection('sheets').get();
        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.data()['name'], 'New Hero');
      });

      test('injects uid into document data', () async {
        final sheet = Sheet(name: 'Hero');

        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final snapshot = await fakeFirestore.collection('sheets').get();
        expect(snapshot.docs.first.data()['uid'], 'user-123');
      });

      test('updates existing document when id is not empty', () async {
        // First create a document
        final docRef = await fakeFirestore.collection('sheets').add({
          'uid': 'user-123',
          'name': 'Old Name',
          'race': 'Elfo',
        });

        await Future.delayed(Duration.zero);

        final sheet = Sheet(id: docRef.id, name: 'New Name', race: 'Elfo');
        await sheetModel.add(sheet);

        await Future.delayed(Duration.zero);

        final doc =
            await fakeFirestore.collection('sheets').doc(docRef.id).get();
        expect(doc.data()?['name'], 'New Name');
      });
    });

    group('delete()', () {
      test('removes document from Firestore', () async {
        final docRef = await fakeFirestore.collection('sheets').add({
          'uid': 'user-123',
          'name': 'To Delete',
        });

        await Future.delayed(Duration.zero);

        final sheet = Sheet(id: docRef.id, name: 'To Delete');
        sheetModel.delete(sheet);

        await Future.delayed(Duration.zero);

        final doc =
            await fakeFirestore.collection('sheets').doc(docRef.id).get();
        expect(doc.exists, false);
      });
    });

    group('removeAll()', () {
      test('clears local list', () async {
        await fakeFirestore.collection('sheets').add({
          'uid': 'user-123',
          'name': 'Hero 1',
        });

        await Future.delayed(Duration.zero);

        sheetModel.removeAll();
        expect(sheetModel.items, isEmpty);
      });
    });

    group('Firestore sync', () {
      test('populates items from Firestore filtered by uid', () async {
        // Add a sheet for our user
        await fakeFirestore.collection('sheets').add({
          'uid': 'user-123',
          'name': 'My Hero',
        });
        // Add a sheet for another user
        await fakeFirestore.collection('sheets').add({
          'uid': 'other-user',
          'name': 'Not Mine',
        });

        await Future.delayed(Duration.zero);

        // Only sheets with matching uid should appear
        final names = sheetModel.items.map((s) => s.name).toList();
        expect(names, contains('My Hero'));
        expect(names, isNot(contains('Not Mine')));
      });
    });
  });
}
