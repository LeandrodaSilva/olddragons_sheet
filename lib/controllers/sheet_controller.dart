import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/firestore_constants.dart';
import '../models/sheet_model.dart';

class SheetModel extends ChangeNotifier {
  final List<Sheet> _items = [];
  late String _uid;
  final FirebaseFirestore _firestore;
  StreamSubscription? _subscription;

  SheetModel({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    final authInstance = auth ?? FirebaseAuth.instance;
    User? user = authInstance.currentUser;
    _uid = user!.uid;

    _subscription = _firestore
        .collection(FirestoreConstants.sheetsCollection)
        .where(FirestoreConstants.uidField, isEqualTo: _uid)
        .snapshots()
        .listen((querySnapshots) {
      _items.clear();
      for (var snapshot in querySnapshots.docs) {
        Map<String, dynamic> data = snapshot.data();
        _items.add(Sheet.fromMap(snapshot.id, data));
      }
      notifyListeners();
    }, onError: (error) {
      debugPrint('SheetModel stream error: $error');
    });
  }

  UnmodifiableListView<Sheet> get items => UnmodifiableListView(_items);

  Future<void> add(Sheet item) async {
    try {
      final data = item.toMap();
      data[FirestoreConstants.uidField] = _uid;

      if (item.id.isNotEmpty) {
        await _firestore
            .collection(FirestoreConstants.sheetsCollection)
            .doc(item.id)
            .update(data);
      } else {
        final value =
            await _firestore.collection(FirestoreConstants.sheetsCollection).add(data);
        item.id = value.id;
      }
    } catch (e) {
      debugPrint('SheetModel add error: $e');
      rethrow;
    }
  }

  Future<void> delete(Sheet item) async {
    try {
      await _firestore
          .collection(FirestoreConstants.sheetsCollection)
          .doc(item.id)
          .delete();
    } catch (e) {
      debugPrint('SheetModel delete error: $e');
      rethrow;
    }
  }

  void removeAll() {
    _items.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
