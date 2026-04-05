import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/firestore_constants.dart';
import '../models/item_model.dart';

class InventoryController extends ChangeNotifier {
  final List<Item> _items = [];
  final String sheetId;
  final FirebaseFirestore _firestore;
  StreamSubscription? _subscription;

  InventoryController({required this.sheetId, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _subscription = _collection.snapshots().listen((querySnapshots) {
      _items.clear();
      for (var snapshot in querySnapshots.docs) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        _items.add(Item.fromMap(snapshot.id, data));
      }
      notifyListeners();
    }, onError: (error) {
      debugPrint('InventoryController stream error: $error');
    });
  }

  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  CollectionReference get _collection => _firestore
      .collection(FirestoreConstants.sheetsCollection)
      .doc(sheetId)
      .collection(FirestoreConstants.itemsSubcollection);

  double get pesoTotal =>
      _items.fold(0.0, (total, item) => total + (item.peso * item.quantidade));

  Future<void> addItem(Item item) async {
    try {
      final value = await _collection.add(item.toMap());
      item.id = value.id;
    } catch (e) {
      debugPrint('InventoryController addItem error: $e');
      rethrow;
    }
  }

  Future<void> removeItem(Item item) async {
    try {
      await _collection.doc(item.id).delete();
    } catch (e) {
      debugPrint('InventoryController removeItem error: $e');
      rethrow;
    }
  }

  Future<void> toggleEquipped(Item item) async {
    try {
      item.equipado = !item.equipado;
      await _collection.doc(item.id).update({'equipado': item.equipado});
    } catch (e) {
      debugPrint('InventoryController toggleEquipped error: $e');
      rethrow;
    }
  }

  Future<void> updateQuantity(Item item, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeItem(item);
        return;
      }
      item.quantidade = newQuantity;
      await _collection.doc(item.id).update({'quantidade': newQuantity});
    } catch (e) {
      debugPrint('InventoryController updateQuantity error: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
