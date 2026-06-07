import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/firestore_constants.dart';
import '../models/spell_model.dart';

class SpellController extends ChangeNotifier {
  final List<Spell> _spells = [];
  final String sheetId;
  final FirebaseFirestore _firestore;
  StreamSubscription? _subscription;

  SpellController({required this.sheetId, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _subscription = _collection.snapshots().listen((querySnapshots) {
      _spells.clear();
      for (var snapshot in querySnapshots.docs) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        _spells.add(Spell.fromMap(snapshot.id, data));
      }
      _spells.sort((a, b) => a.circulo.compareTo(b.circulo));
      notifyListeners();
    }, onError: (error) {
      debugPrint('SpellController stream error: $error');
    });
  }

  UnmodifiableListView<Spell> get spells => UnmodifiableListView(_spells);

  /// Magias do círculo informado (1 a 5).
  List<Spell> doCirculo(int circulo) =>
      _spells.where((s) => s.circulo == circulo).toList();

  CollectionReference get _collection => _firestore
      .collection(FirestoreConstants.sheetsCollection)
      .doc(sheetId)
      .collection(FirestoreConstants.spellsSubcollection);

  Future<void> addSpell(Spell spell) async {
    try {
      final value = await _collection.add(spell.toMap());
      spell.id = value.id;
    } catch (e) {
      debugPrint('SpellController addSpell error: $e');
      rethrow;
    }
  }

  Future<void> removeSpell(Spell spell) async {
    try {
      await _collection.doc(spell.id).delete();
    } catch (e) {
      debugPrint('SpellController removeSpell error: $e');
      rethrow;
    }
  }

  Future<void> togglePreparada(Spell spell) async {
    try {
      spell.preparada = !spell.preparada;
      await _collection.doc(spell.id).update({'preparada': spell.preparada});
    } catch (e) {
      debugPrint('SpellController togglePreparada error: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
