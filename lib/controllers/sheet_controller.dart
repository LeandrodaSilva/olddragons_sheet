import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/sheet_model.dart';

class SheetModel extends ChangeNotifier {
  final List<Sheet> _items = [];
  late String _uid;

  SheetModel() {
    User? user = FirebaseAuth.instance.currentUser;
    CollectionReference sheets =
        FirebaseFirestore.instance.collection('sheets');

    _uid = user!.uid;

    sheets.where("uid", isEqualTo: _uid).get().then((querySnapshots) {
      if (querySnapshots.docs.isNotEmpty) {
        for (var snapshot in querySnapshots.docs) {
          Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
          _items.add(Sheet.fromMap(snapshot.id, data));
        }
        notifyListeners();
      }
    });
  }

  UnmodifiableListView<Sheet> get items => UnmodifiableListView(_items);

  void add(Sheet item) {
    final data = item.toMap();
    data['uid'] = _uid;

    if (item.id.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('sheets')
          .doc(item.id)
          .update(data)
          .then((value) {
        _items.remove(item);
        _items.add(item);
        notifyListeners();
      });
    } else {
      FirebaseFirestore.instance.collection('sheets').add(data).then((value) {
        item.id = value.id;
        _items.add(item);
        notifyListeners();
      });
    }
  }

  void delete(Sheet item) {
    FirebaseFirestore.instance
        .collection('sheets')
        .doc(item.id)
        .delete()
        .then((value) {
      _items.remove(item);
      notifyListeners();
    });
  }

  void removeAll() {
    _items.clear();
    notifyListeners();
  }
}
