import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ods/controllers/character_controller.dart';
import 'package:ods/controllers/dice_controller.dart';
import 'package:ods/controllers/shop_controller.dart';
import 'package:ods/controllers/inventory_controller.dart';
import 'package:ods/controllers/sheet_controller.dart';
import 'package:ods/widgets/attribute_card_widget.dart';
import 'package:ods/widgets/pv_bar_widget.dart';
import 'package:ods/widgets/stat_card_widget.dart';
import 'package:provider/provider.dart';

import '../models/item_model.dart';
import '../models/sheet_model.dart';
import '../widgets/dice_roller_widget.dart';
import '../widgets/item_card_widget.dart';
import '../widgets/shop_item_card_widget.dart';

class PlayScreen extends StatefulWidget {
  final Sheet sheet;

  const PlayScreen({Key? key, required this.sheet}) : super(key: key);

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  int _currentTab = 0;
  String _filtroLoja = 'todos';
  late Sheet sheet;
  late InventoryController inventoryController;
  StreamSubscription? _sheetSubscription;
  bool _isSaving = false;
  final CharacterController _characterController = CharacterController();
  final ShopController _shopController = ShopController();
  final DiceController _diceController = DiceController();

  @override
  void initState() {
    super.initState();
    sheet = widget.sheet;
    inventoryController = InventoryController(sheetId: sheet.id);
    _listenToSheetChanges();
  }

  void _listenToSheetChanges() {
    _sheetSubscription = FirebaseFirestore.instance
        .collection('sheets')
        .doc(sheet.id)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists || _isSaving) return;
      final data = snapshot.data()!;
      setState(() {
        sheet = Sheet.fromMap(snapshot.id, data);
      });
    });
  }

  Future<void> _saveSheet() async {
    _isSaving = true;
    final sm = Provider.of<SheetModel>(context, listen: false);
    await sm.add(sheet);
    if (mounted) {
      _isSaving = false;
    }
  }

  @override
  void dispose() {
    _sheetSubscription?.cancel();
    inventoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildFichaTab(),
      _buildInventarioTab(),
      _buildLojaTab(),
      DiceRollerWidget(diceController: _diceController, sheet: sheet),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("${sheet.name} — Nv.${sheet.level}"),
      ),
      body: tabs[_currentTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromRGBO(172, 25, 20, 1),
        onTap: (index) => setState(() => _currentTab = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Ficha"),
          BottomNavigationBarItem(icon: Icon(Icons.backpack), label: "Inventário"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Loja"),
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: "Dados"),
        ],
      ),
    );
  }

  Widget _buildFichaTab() {
    final raceImg = _characterController.findOneByRaceName(sheet.race);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === CABEÇALHO ===
              _buildHeader(raceImg.img),
              const SizedBox(height: 16),

              // === ATRIBUTOS ===
              const Text("ATRIBUTOS",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(172, 25, 20, 1))),
              const SizedBox(height: 8),
              _buildAtributosGrid(),
              const SizedBox(height: 16),

              // === STATS DERIVADOS ===
              const Text("STATS",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(172, 25, 20, 1))),
              const SizedBox(height: 8),
              _buildStatsRow(),
              const SizedBox(height: 16),

              // === PV ===
              PvBar(
                pvAtual: sheet.pvAtual,
                pvMax: sheet.pvMax,
                onPvAtualChanged: (v) {
                  setState(() => sheet.pvAtual = v);
                  _saveSheet();
                },
                onPvMaxChanged: (v) {
                  setState(() {
                    sheet.pvMax = v;
                    if (sheet.pvAtual > v) sheet.pvAtual = v;
                  });
                  _saveSheet();
                },
              ),
              const SizedBox(height: 16),

              // === DINHEIRO ===
              const Text("DINHEIRO",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(172, 25, 20, 1))),
              const SizedBox(height: 8),
              _buildDinheiroRow(),
              const SizedBox(height: 16),

              // === XP ===
              _buildXpRow(),
              const SizedBox(height: 16),

              // === NOTAS ===
              const Text("NOTAS",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(172, 25, 20, 1))),
              const SizedBox(height: 8),
              _buildNotasField(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String imgPath) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: AssetImage(imgPath),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sheet.name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("${sheet.race} • ${sheet.classEspec}",
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey[700])),
                  Text("Nível ${sheet.level} • ${sheet.align.isNotEmpty ? sheet.align : 'Sem alinhamento'}",
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey[500])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAtributosGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        AttributeCard(
          label: "FOR",
          value: sheet.forca,
          onChanged: (v) {
            setState(() => sheet.forca = v);
            _saveSheet();
          },
        ),
        AttributeCard(
          label: "DES",
          value: sheet.destreza,
          onChanged: (v) {
            setState(() => sheet.destreza = v);
            _saveSheet();
          },
        ),
        AttributeCard(
          label: "CON",
          value: sheet.constituicao,
          onChanged: (v) {
            setState(() => sheet.constituicao = v);
            _saveSheet();
          },
        ),
        AttributeCard(
          label: "INT",
          value: sheet.inteligencia,
          onChanged: (v) {
            setState(() => sheet.inteligencia = v);
            _saveSheet();
          },
        ),
        AttributeCard(
          label: "SAB",
          value: sheet.sabedoria,
          onChanged: (v) {
            setState(() => sheet.sabedoria = v);
            _saveSheet();
          },
        ),
        AttributeCard(
          label: "CAR",
          value: sheet.carisma,
          onChanged: (v) {
            setState(() => sheet.carisma = v);
            _saveSheet();
          },
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        StatCard(
          label: "CA",
          value: sheet.ca,
          icon: Icons.shield,
          onChanged: (v) {
            setState(() => sheet.ca = v);
            _saveSheet();
          },
        ),
        StatCard(
          label: "JP",
          value: sheet.jp,
          icon: Icons.security,
          onChanged: (v) {
            setState(() => sheet.jp = v);
            _saveSheet();
          },
        ),
        StatCard(
          label: "BA",
          value: sheet.ba,
          icon: Icons.gps_fixed,
          onChanged: (v) {
            setState(() => sheet.ba = v);
            _saveSheet();
          },
        ),
        StatCard(
          label: "MOV",
          value: sheet.movimento,
          icon: Icons.directions_run,
          onChanged: (v) {
            setState(() => sheet.movimento = v);
            _saveSheet();
          },
        ),
      ],
    );
  }

  Widget _buildDinheiroRow() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildMoeda("PPL", sheet.platina, (v) {
              setState(() => sheet.platina = v);
              _saveSheet();
            }),
            _buildMoeda("PE", sheet.electrum, (v) {
              setState(() => sheet.electrum = v);
              _saveSheet();
            }),
            _buildMoeda("PO", sheet.ouro, (v) {
              setState(() => sheet.ouro = v);
              _saveSheet();
            }),
            _buildMoeda("PP", sheet.prata, (v) {
              setState(() => sheet.prata = v);
              _saveSheet();
            }),
            _buildMoeda("PC", sheet.cobre, (v) {
              setState(() => sheet.cobre = v);
              _saveSheet();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMoeda(String label, int value, ValueChanged<int> onChanged) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _editNumber(label, value, onChanged),
        child: Column(
          children: [
            Text("$value",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildXpRow() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _editNumber("XP", sheet.xpAtual, (v) {
          setState(() => sheet.xpAtual = v);
          _saveSheet();
        }),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star,
                  color: Color.fromRGBO(172, 25, 20, 1), size: 20),
              const SizedBox(width: 8),
              const Text("XP: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("${sheet.xpAtual}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotasField() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          maxLines: 4,
          controller: TextEditingController(text: sheet.notas),
          decoration: const InputDecoration(
            hintText: "Anotações de sessão...",
            border: InputBorder.none,
          ),
          onChanged: (v) {
            sheet.notas = v;
          },
          onEditingComplete: _saveSheet,
        ),
      ),
    );
  }

  // === ABA LOJA ===

  Widget _buildLojaTab() {
    final itens = _shopController.filtrarPorTipo(_filtroLoja);

    return Column(
      children: [
        // Saldo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.monetization_on,
                  color: Color.fromRGBO(172, 25, 20, 1)),
              const SizedBox(width: 8),
              Text("${sheet.ouro} PO",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text("${itens.length} itens",
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
        // Filtros
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _buildFilterChip("Todos", "todos"),
              const SizedBox(width: 8),
              _buildFilterChip("Armas", "armas"),
              const SizedBox(width: 8),
              _buildFilterChip("Armaduras", "armaduras"),
              const SizedBox(width: 8),
              _buildFilterChip("Geral", "geral"),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Lista
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: itens.length,
            itemBuilder: (context, index) {
              final item = itens[index];
              return ShopItemCard(
                item: item,
                canBuy: sheet.ouro >= item.precoPO,
                onBuy: () => _comprarItem(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String filtro) {
    final selected = _filtroLoja == filtro;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: const Color.fromRGBO(172, 25, 20, 0.2),
      onSelected: (_) => setState(() => _filtroLoja = filtro),
    );
  }

  void _comprarItem(Item shopItem) {
    if (sheet.ouro < shopItem.precoPO) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ouro insuficiente!")),
      );
      return;
    }

    setState(() {
      sheet.ouro -= shopItem.precoPO;
    });

    final copia = Item(
      nome: shopItem.nome,
      descricao: shopItem.descricao,
      tipo: shopItem.tipo,
      tamanho: shopItem.tamanho,
      quantidade: 1,
      equipado: false,
      dano: shopItem.dano,
      tipoDano: shopItem.tipoDano,
      critico: shopItem.critico,
      alcance: shopItem.alcance,
      especial: shopItem.especial,
      bonusDefesa: shopItem.bonusDefesa,
      bonusMaxDes: shopItem.bonusMaxDes,
      reducaoMov: shopItem.reducaoMov,
      precoPO: shopItem.precoPO,
      peso: shopItem.peso,
    );

    inventoryController.addItem(copia);
    _saveSheet();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${shopItem.nome} adquirido!")),
    );
  }

  // === ABA INVENTÁRIO ===

  Widget _buildInventarioTab() {
    return ListenableBuilder(
      listenable: inventoryController,
      builder: (context, _) {
        final items = inventoryController.items;
        return Column(
          children: [
            // Resumo de carga
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Peso total: ${inventoryController.pesoTotal.toStringAsFixed(1)} kg",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text("${items.length} itens",
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            // Lista de itens
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text("Nenhum item no inventário",
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ItemCard(
                          item: item,
                          onToggleEquip: () {
                            inventoryController.toggleEquipped(item);
                          },
                          onDelete: () {
                            inventoryController.removeItem(item);
                          },
                          onQuantityChanged: (q) {
                            inventoryController.updateQuantity(item, q);
                          },
                        );
                      },
                    ),
            ),
            // Botão adicionar
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => _showAddItemDialog(),
                icon: const Icon(Icons.add),
                label: const Text("Adicionar Item"),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddItemDialog() {
    String nome = "";
    String tipo = "geral";
    double peso = 0;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Adicionar Item"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Nome"),
                autofocus: true,
                validator: (v) =>
                    v == null || v.isEmpty ? "Informe o nome" : null,
                onSaved: (v) => nome = v ?? "",
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: tipo,
                decoration: const InputDecoration(labelText: "Tipo"),
                items: const [
                  DropdownMenuItem(value: "geral", child: Text("Geral")),
                  DropdownMenuItem(value: "arma", child: Text("Arma")),
                  DropdownMenuItem(value: "armadura", child: Text("Armadura")),
                  DropdownMenuItem(value: "escudo", child: Text("Escudo")),
                  DropdownMenuItem(value: "municao", child: Text("Munição")),
                ],
                onChanged: (v) => tipo = v ?? "geral",
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: "Peso (kg)"),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onSaved: (v) => peso = double.tryParse(v ?? "") ?? 0,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                inventoryController.addItem(Item(
                  nome: nome,
                  tipo: tipo,
                  peso: peso,
                ));
                Navigator.of(ctx).pop();
              }
            },
            child: const Text("Adicionar"),
          ),
        ],
      ),
    );
  }

  void _editNumber(String title, int current, ValueChanged<int> onSave) {
    final controller = TextEditingController(text: "$current");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              onSave(int.tryParse(controller.text) ?? current);
              Navigator.of(ctx).pop();
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }
}
