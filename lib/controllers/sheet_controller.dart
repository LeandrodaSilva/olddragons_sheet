import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/sheet_model.dart';

class SheetModel extends ChangeNotifier {
  final List<Sheet> _items = [];
  late String _uid;
  StreamSubscription? _subscription;

  SheetModel() {
    User? user = FirebaseAuth.instance.currentUser;
    _uid = user!.uid;

    _subscription = FirebaseFirestore.instance
        .collection('sheets')
        .where("uid", isEqualTo: _uid)
        .snapshots()
        .listen((querySnapshots) {
      _items.clear();
      for (var snapshot in querySnapshots.docs) {
        Map<String, dynamic> data = snapshot.data();
        _items.add(Sheet.fromMap(snapshot.id, data));
      }
      notifyListeners();
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
          .update(data);
    } else {
      FirebaseFirestore.instance.collection('sheets').add(data).then((value) {
        item.id = value.id;
      });
    }
  }

  void delete(Sheet item) {
    FirebaseFirestore.instance
        .collection('sheets')
        .doc(item.id)
        .delete();
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
