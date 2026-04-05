import 'package:flutter/material.dart';
import 'package:ods/models/item_model.dart';
import 'package:ods/models/sheet_model.dart';

/// Wraps a widget in a MaterialApp for testing widgets that use
/// Navigator, showDialog, Theme, etc.
Widget wrapWithMaterialApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

/// Creates a Sheet with sane defaults for testing.
Sheet createTestSheet({
  String id = 'test-id',
  String name = 'Test Hero',
  int forca = 14,
  int destreza = 12,
  int constituicao = 10,
  int inteligencia = 10,
  int sabedoria = 10,
  int carisma = 10,
  int pvMax = 20,
  int pvAtual = 15,
  int ca = 14,
  int ba = 2,
  int jp = 13,
  int movimento = 9,
  int ouro = 50,
}) {
  return Sheet(
    id: id,
    name: name,
    race: 'Humano',
    classEspec: 'Homem de Armas',
    level: '3',
    forca: forca,
    destreza: destreza,
    constituicao: constituicao,
    inteligencia: inteligencia,
    sabedoria: sabedoria,
    carisma: carisma,
    pvMax: pvMax,
    pvAtual: pvAtual,
    ca: ca,
    ba: ba,
    jp: jp,
    movimento: movimento,
    ouro: ouro,
  );
}

/// Creates an Item with sane defaults for testing.
Item createTestItem({
  String id = 'item-1',
  String nome = 'Espada Longa',
  String tipo = 'arma',
  String dano = '1d8',
  String tipoDano = 'Co.',
  int bonusDefesa = 0,
  double peso = 2.0,
  int precoPO = 10,
  int quantidade = 1,
  bool equipado = false,
  String descricao = '',
  String critico = '',
  String especial = '',
  int reducaoMov = 0,
  int bonusMaxDes = 99,
  String tamanho = 'M',
}) {
  return Item(
    id: id,
    nome: nome,
    tipo: tipo,
    dano: dano,
    tipoDano: tipoDano,
    bonusDefesa: bonusDefesa,
    peso: peso,
    precoPO: precoPO,
    quantidade: quantidade,
    equipado: equipado,
    descricao: descricao,
    critico: critico,
    especial: especial,
    reducaoMov: reducaoMov,
    bonusMaxDes: bonusMaxDes,
    tamanho: tamanho,
  );
}
