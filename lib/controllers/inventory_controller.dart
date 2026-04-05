import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    });
  }

  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  CollectionReference get _collection => _firestore
      .collection('sheets')
      .doc(sheetId)
      .collection('items');

  double get pesoTotal =>
      _items.fold(0.0, (total, item) => total + (item.peso * item.quantidade));

  void addItem(Item item) {
    _collection.add(item.toMap()).then((value) {
      item.id = value.id;
    });
  }

  void removeItem(Item item) {
    _collection.doc(item.id).delete();
  }

  void toggleEquipped(Item item) {
    item.equipado = !item.equipado;
    _collection.doc(item.id).update({'equipado': item.equipado});
  }

  void updateQuantity(Item item, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(item);
      return;
    }
    item.quantidade = newQuantity;
    _collection.doc(item.id).update({'quantidade': newQuantity});
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
