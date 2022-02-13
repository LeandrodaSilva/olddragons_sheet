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
          var documentID = snapshot.id;
          Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
          Sheet item = Sheet(
            id: documentID,
            name: data['name'],
            player: data['player'],
            race: data['race'],
            classEspec: data['classEspec'],
            level: data['level'],
          );
          _items.add(item);
        }
        notifyListeners();
      }
    });
  }

  UnmodifiableListView<Sheet> get items => UnmodifiableListView(_items);

  void add(Sheet item) {
    if (item.id.isNotEmpty) {
      FirebaseFirestore.instance.collection('sheets').doc(item.id).update({
        'name': item.name,
        'uid': _uid,
        'player': item.player,
        'race': item.race,
        'align': item.align,
        'classEspec': item.classEspec,
        'level': item.level,
      }).then((value) {
        _items.remove(item);
        _items.add(item);
        notifyListeners();
      });
    } else {
      FirebaseFirestore.instance.collection('sheets').add({
        'name': item.name,
        'uid': _uid,
        'player': item.player,
        'race': item.race,
        'align': item.align,
        'classEspec': item.classEspec,
        'level': item.level,
      }).then((value) {
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

  /// Removes all items from the cart.
  void removeAll() {
    _items.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
