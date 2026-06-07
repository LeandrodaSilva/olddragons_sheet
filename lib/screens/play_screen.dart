import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ods/constants/app_colors.dart';
import 'package:ods/controllers/character_controller.dart';
import 'package:ods/controllers/class_controller.dart';
import 'package:ods/controllers/dice_controller.dart';
import 'package:ods/controllers/shop_controller.dart';
import 'package:ods/controllers/inventory_controller.dart';
import 'package:ods/controllers/sheet_controller.dart';
import 'package:ods/controllers/spell_controller.dart';
import 'package:ods/models/class_model.dart';
import 'package:ods/models/spell_model.dart';
import 'package:ods/utils/leveling_util.dart';
import 'package:ods/utils/magic_calculator_util.dart';
import 'package:ods/utils/stats_calculator_util.dart';
import 'package:ods/widgets/attribute_card_widget.dart';
import 'package:ods/widgets/edit_value_dialog.dart';
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

  const PlayScreen({super.key, required this.sheet});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  int _currentTab = 0;
  String _filtroLoja = 'todos';
  late Sheet sheet;
  StreamSubscription? _sheetSubscription;
  bool _isSaving = false;
  final CharacterController _characterController = CharacterController();
  final ClassController _classController = ClassController();
  final ShopController _shopController = ShopController();
  final DiceController _diceController = DiceController();
  late final InventoryController _inventoryController;
  late final SpellController _spellController;

  @override
  void initState() {
    super.initState();
    sheet = widget.sheet;
    _inventoryController = InventoryController(sheetId: sheet.id);
    _inventoryController.addListener(_onInventoryChanged);
    _spellController = SpellController(sheetId: sheet.id);
    _spellController.addListener(_onSpellsChanged);
    final sc = Provider.of<SheetController>(context, listen: false);
    _sheetSubscription = sc.listenToSheet(
      sheet.id,
      onData: (updatedSheet) {
        if (_isSaving) return;
        setState(() {
          sheet = updatedSheet;
        });
        _recalc();
      },
    );
    // Recalcula os stats derivados após o inventário inicial carregar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_recalc()) _saveSheet();
    });
  }

  Future<void> _saveSheet() async {
    _isSaving = true;
    try {
      final sc = Provider.of<SheetController>(context, listen: false);
      await sc.add(sheet);
    } catch (_) {
      _notifyError("Erro ao salvar a ficha. Verifique sua conexão.");
    } finally {
      if (mounted) {
        _isSaving = false;
      }
    }
  }

  /// Exibe uma mensagem de erro ao usuário (no-op se a tela já foi desmontada).
  void _notifyError(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red[700],
      ),
    );
  }

  /// Executa uma ação assíncrona de inventário exibindo erro ao usuário em
  /// caso de falha.
  Future<void> _runComFeedback(
      Future<void> Function() acao, String mensagemErro) async {
    try {
      await acao();
    } catch (_) {
      _notifyError(mensagemErro);
    }
  }

  void _onInventoryChanged() {
    if (_recalc()) _saveSheet();
  }

  void _onSpellsChanged() {
    if (mounted) setState(() {});
  }

  List<Item> get _equipados =>
      _inventoryController.items.where((i) => i.equipado).toList();

  /// Recalcula PV/CA/BA/JP/MOV a partir de atributos, classe, raça e itens
  /// equipados. Retorna true se algum valor mudou (para persistir só quando
  /// necessário).
  bool _recalc() {
    if (!mounted) return false;
    final classe = _classController.findOneByClassName(sheet.classEspec);
    final raca = _characterController.findOneByRaceName(sheet.race);
    final equipados = _equipados;
    final nivel = int.tryParse(sheet.level) ?? 1;

    final novoCa = StatsCalculator.ca(
        destreza: sheet.destreza, equipados: equipados, outros: sheet.caOutros);
    final novoBa = StatsCalculator.baseAtaque(
        classe: classe, nivel: nivel, outros: sheet.baOutros);
    final novoJp = StatsCalculator.jpBase(
        classe: classe, nivel: nivel, outros: sheet.jpOutros);
    final novoMov = StatsCalculator.movimento(
        baseRaca: raca.movementSpeed,
        equipados: equipados,
        outros: sheet.movOutros);
    final novoPvMax = StatsCalculator.pvMax(
        dadoDeVida: classe.dadoDeVida,
        constituicao: sheet.constituicao,
        nivel: nivel,
        outros: sheet.pvOutros);
    // Personagem recém-criado (PV ainda não inicializado) começa com PV cheio;
    // do contrário, apenas limita o PV atual ao novo máximo.
    final bool primeiraInicializacao = sheet.pvMax == 0 && novoPvMax > 0;
    final novoPvAtual = primeiraInicializacao
        ? novoPvMax
        : (sheet.pvAtual > novoPvMax ? novoPvMax : sheet.pvAtual);

    final mudou = novoCa != sheet.ca ||
        novoBa != sheet.ba ||
        novoJp != sheet.jp ||
        novoMov != sheet.movimento ||
        novoPvMax != sheet.pvMax ||
        novoPvAtual != sheet.pvAtual;
    if (!mudou) return false;

    setState(() {
      sheet.ca = novoCa;
      sheet.ba = novoBa;
      sheet.jp = novoJp;
      sheet.movimento = novoMov;
      sheet.pvMax = novoPvMax;
      sheet.pvAtual = novoPvAtual;
    });
    return true;
  }

  @override
  void dispose() {
    _sheetSubscription?.cancel();
    _inventoryController.removeListener(_onInventoryChanged);
    _inventoryController.dispose();
    _spellController.removeListener(_onSpellsChanged);
    _spellController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classe = _classController.findOneByClassName(sheet.classEspec);
    final isConjurador = classe.conjurador;

    final tabs = <Widget>[
      _buildFichaTab(),
      _buildInventarioTab(),
      _buildLojaTab(),
    ];
    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Ficha"),
      const BottomNavigationBarItem(
          icon: Icon(Icons.backpack), label: "Inventário"),
      const BottomNavigationBarItem(icon: Icon(Icons.store), label: "Loja"),
    ];
    if (isConjurador) {
      tabs.add(_buildMagiasTab(classe));
      navItems.add(const BottomNavigationBarItem(
          icon: Icon(Icons.auto_stories), label: "Magias"));
    }
    tabs.add(DiceRollerWidget(diceController: _diceController, sheet: sheet));
    navItems.add(
        const BottomNavigationBarItem(icon: Icon(Icons.casino), label: "Dados"));

    final indiceAtual = _currentTab.clamp(0, tabs.length - 1);

    return ChangeNotifierProvider<InventoryController>.value(
      value: _inventoryController,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${sheet.name} — Nv.${sheet.level}"),
        ),
        body: tabs[indiceAtual],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: indiceAtual,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          onTap: (index) => setState(() => _currentTab = index),
          items: navItems,
        ),
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

              // === PV (VIDA) ===
              PvBar(
                pvAtual: sheet.pvAtual,
                pvMax: sheet.pvMax,
                onPvAtualChanged: (v) {
                  setState(() => sheet.pvAtual = v);
                  _saveSheet();
                },
                onPvMaxChanged: (v) {
                  // O valor digitado vira o ajuste manual ("outros") sobre o
                  // PV calculado pelo dado de vida + CON.
                  sheet.pvOutros += v - sheet.pvMax;
                  _recalc();
                  _saveSheet();
                },
              ),
              const SizedBox(height: 12),

              // === XP ===
              _buildXpRow(),
              const SizedBox(height: 16),

              // === ATRIBUTOS ===
              const Text("ATRIBUTOS",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const SizedBox(height: 8),
              _buildAtributosGrid(),
              const SizedBox(height: 16),

              // === STATS DERIVADOS ===
              const Text("STATS",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const SizedBox(height: 8),
              _buildStatsRow(),
              const SizedBox(height: 16),

              // === DINHEIRO ===
              const Text("DINHEIRO",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const SizedBox(height: 8),
              _buildDinheiroRow(),
              const SizedBox(height: 16),

              // === NOTAS ===
              const Text("NOTAS",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
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
      childAspectRatio: 0.72,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        AttributeCard(
          label: "FOR",
          value: sheet.forca,
          onChanged: (v) {
            setState(() => sheet.forca = v);
            _recalc();
            _saveSheet();
          },
        ),
        AttributeCard(
          label: "DES",
          value: sheet.destreza,
          onChanged: (v) {
            setState(() => sheet.destreza = v);
            _recalc();
            _saveSheet();
          },
        ),
        AttributeCard(
          label: "CON",
          value: sheet.constituicao,
          onChanged: (v) {
            setState(() => sheet.constituicao = v);
            _recalc();
            _saveSheet();
          },
        ),
        AttributeCard(
          label: "INT",
          value: sheet.inteligencia,
          onChanged: (v) {
            setState(() => sheet.inteligencia = v);
            _recalc();
            _saveSheet();
          },
        ),
        AttributeCard(
          label: "SAB",
          value: sheet.sabedoria,
          onChanged: (v) {
            setState(() => sheet.sabedoria = v);
            _recalc();
            _saveSheet();
          },
        ),
        AttributeCard(
          label: "CAR",
          value: sheet.carisma,
          onChanged: (v) {
            setState(() => sheet.carisma = v);
            _recalc();
            _saveSheet();
          },
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    // Os stats são calculados automaticamente. O valor digitado ao tocar num
    // card é interpretado como o total desejado: a diferença em relação ao
    // valor calculado fica registrada como ajuste manual ("outros").
    return Row(
      children: [
        StatCard(
          label: "CA",
          value: sheet.ca,
          icon: Icons.shield,
          onChanged: (v) {
            sheet.caOutros += v - sheet.ca;
            _recalc();
            _saveSheet();
          },
        ),
        StatCard(
          label: "JP",
          value: sheet.jp,
          icon: Icons.security,
          onChanged: (v) {
            sheet.jpOutros += v - sheet.jp;
            _recalc();
            _saveSheet();
          },
        ),
        StatCard(
          label: "BA",
          value: sheet.ba,
          icon: Icons.gps_fixed,
          onChanged: (v) {
            sheet.baOutros += v - sheet.ba;
            _recalc();
            _saveSheet();
          },
        ),
        StatCard(
          label: "MOV",
          value: sheet.movimento,
          icon: Icons.directions_run,
          onChanged: (v) {
            sheet.movOutros += v - sheet.movimento;
            _recalc();
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
        onTap: () async {
          final newVal = await showEditValueDialog(context, title: label, currentValue: value);
          if (newVal != null) onChanged(newVal);
        },
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
    final classe = _classController.findOneByClassName(sheet.classEspec);
    final nivel = int.tryParse(sheet.level) ?? 1;
    final xpProximo =
        Leveling.xpProximoNivel(classe: classe, nivelAtual: nivel);
    final podeSubir = Leveling.podeSubir(
        classe: classe, nivelAtual: nivel, xpAtual: sheet.xpAtual);
    final progresso = xpProximo != null
        ? "${sheet.xpAtual} / $xpProximo p/ Nv ${nivel + 1}"
        : "Nível máximo";

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3A5C), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldAccent.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final newVal = await showEditValueDialog(context,
                  title: "XP", currentValue: sheet.xpAtual);
              if (newVal != null) {
                setState(() => sheet.xpAtual = newVal);
                _saveSheet();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star,
                          color: AppColors.goldAccent,
                          size: 22,
                          shadows: [
                            Shadow(
                                color: AppColors.goldAccent.withValues(alpha: 0.5),
                                blurRadius: 6)
                          ]),
                      const SizedBox(width: 8),
                      Text("XP",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.7),
                          )),
                      const SizedBox(width: 10),
                      Text("${sheet.xpAtual}",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldAccent,
                            shadows: [
                              Shadow(
                                  color: AppColors.goldAccent.withValues(alpha: 0.3),
                                  blurRadius: 4)
                            ],
                          )),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(progresso,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.5),
                      )),
                ],
              ),
            ),
          ),
          if (podeSubir)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _subirNivel,
                  icon: const Icon(Icons.arrow_upward, size: 18),
                  label: Text("Subir para o nível ${nivel + 1}"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldAccent,
                    foregroundColor: const Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Sobe um nível: incrementa o nível, recalcula os stats derivados e soma o
  /// PV ganho também ao PV atual.
  void _subirNivel() {
    final classe = _classController.findOneByClassName(sheet.classEspec);
    final nivelAtual = int.tryParse(sheet.level) ?? 1;
    if (!Leveling.podeSubir(
        classe: classe, nivelAtual: nivelAtual, xpAtual: sheet.xpAtual)) {
      return;
    }
    final pvMaxAntes = sheet.pvMax;
    setState(() => sheet.level = "${nivelAtual + 1}");
    _recalc();
    final ganhoPv = sheet.pvMax - pvMaxAntes;
    if (ganhoPv > 0) {
      setState(() {
        sheet.pvAtual = (sheet.pvAtual + ganhoPv).clamp(0, sheet.pvMax);
      });
    }
    _saveSheet();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Subiu para o nível ${sheet.level}!")),
      );
    }
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
                  color: AppColors.primary),
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
      selectedColor: AppColors.primarySubtle,
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

    _runComFeedback(
      () => _inventoryController.addItem(copia),
      "Erro ao adicionar o item comprado.",
    );
    _saveSheet();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${shopItem.nome} adquirido!")),
    );
  }

  // === ABA INVENTÁRIO ===

  Widget _buildInventarioTab() {
    return Consumer<InventoryController>(
      builder: (context, inventoryController, _) {
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
                          onToggleEquip: () => _runComFeedback(
                            () => inventoryController.toggleEquipped(item),
                            "Erro ao equipar o item.",
                          ),
                          onDelete: () => _runComFeedback(
                            () => inventoryController.removeItem(item),
                            "Erro ao remover o item.",
                          ),
                          onQuantityChanged: (q) => _runComFeedback(
                            () => inventoryController.updateQuantity(item, q),
                            "Erro ao atualizar a quantidade.",
                          ),
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
                initialValue: tipo,
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
                _runComFeedback(
                  () => _inventoryController.addItem(Item(
                    nome: nome,
                    tipo: tipo,
                    peso: peso,
                  )),
                  "Erro ao adicionar o item.",
                );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text("Adicionar"),
          ),
        ],
      ),
    );
  }

  // === ABA MAGIAS ===

  Widget _buildMagiasTab(Class classe) {
    final nivel = int.tryParse(sheet.level) ?? 1;
    final atributo =
        classe.tipoMagia == 'arcana' ? sheet.inteligencia : sheet.sabedoria;
    final magias = MagicCalculator.magiasPorDia(
        classe: classe, nivel: nivel, atributoConjurador: atributo);
    final maiorCirc = MagicCalculator.maiorCirculo(classe: classe, nivel: nivel);
    final atributoLabel = classe.tipoMagia == 'arcana' ? 'INT' : 'SAB';
    final tipoLabel = classe.tipoMagia == 'arcana' ? 'arcanas' : 'divinas';

    if (maiorCirc == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text("Sem magias disponíveis neste nível.",
              style: TextStyle(color: Colors.grey[600])),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text("Magias $tipoLabel • inclui bônus por $atributoLabel",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ),
                  TextButton.icon(
                    onPressed: _descansar,
                    icon: const Icon(Icons.bedtime, size: 18),
                    label: const Text("Descansar"),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              for (int c = 1; c <= maiorCirc; c++) ...[
                _buildCirculoSection(c, magias[c - 1]),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 4),
              ElevatedButton.icon(
                onPressed: () => _showAddSpellDialog(maiorCirc),
                icon: const Icon(Icons.add),
                label: const Text("Adicionar Magia"),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCirculoSection(int circulo, int total) {
    final usadas = sheet.magiasUsadas[circulo - 1];
    final disponiveis = total - usadas;
    final magiasCirc = _spellController.doCirculo(circulo);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Círculo $circulo",
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 22),
                  onPressed: () => _alterarMagiaUsada(circulo - 1, 1, total),
                  tooltip: "Gastar magia",
                ),
                Text("$disponiveis / $total",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 22),
                  onPressed: () => _alterarMagiaUsada(circulo - 1, -1, total),
                  tooltip: "Recuperar magia",
                ),
              ],
            ),
            if (magiasCirc.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text("Nenhuma magia anotada.",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ),
            for (final magia in magiasCirc) _buildSpellTile(magia),
          ],
        ),
      ),
    );
  }

  Widget _buildSpellTile(Spell magia) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: IconButton(
        icon: Icon(
          magia.preparada ? Icons.check_circle : Icons.circle_outlined,
          color: magia.preparada ? AppColors.primary : Colors.grey,
          size: 20,
        ),
        onPressed: () => _runComFeedback(
          () => _spellController.togglePreparada(magia),
          "Erro ao atualizar a magia.",
        ),
        tooltip: magia.preparada ? "Preparada" : "Não preparada",
      ),
      title: Text(magia.nome,
          style: TextStyle(
              fontWeight:
                  magia.preparada ? FontWeight.bold : FontWeight.normal)),
      subtitle: magia.descricao.isNotEmpty
          ? Text(magia.descricao, style: const TextStyle(fontSize: 12))
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: () => _runComFeedback(
          () => _spellController.removeSpell(magia),
          "Erro ao remover a magia.",
        ),
      ),
    );
  }

  void _alterarMagiaUsada(int idx, int delta, int total) {
    final novo = (sheet.magiasUsadas[idx] + delta).clamp(0, total);
    if (novo == sheet.magiasUsadas[idx]) return;
    setState(() => sheet.magiasUsadas[idx] = novo);
    _saveSheet();
  }

  void _descansar() {
    setState(() => sheet.magiasUsadas = [0, 0, 0, 0, 0]);
    _saveSheet();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Você descansou: magias restauradas.")),
      );
    }
  }

  void _showAddSpellDialog(int maxCirculo) {
    String nome = "";
    String descricao = "";
    int circulo = 1;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Adicionar Magia"),
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
              DropdownButtonFormField<int>(
                initialValue: circulo,
                decoration: const InputDecoration(labelText: "Círculo"),
                items: [
                  for (int c = 1; c <= maxCirculo; c++)
                    DropdownMenuItem(value: c, child: Text("$cº círculo")),
                ],
                onChanged: (v) => circulo = v ?? 1,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: "Descrição (opcional)"),
                onSaved: (v) => descricao = v ?? "",
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
                _runComFeedback(
                  () => _spellController.addSpell(Spell(
                    nome: nome,
                    circulo: circulo,
                    descricao: descricao,
                    preparada: true,
                  )),
                  "Erro ao adicionar a magia.",
                );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text("Adicionar"),
          ),
        ],
      ),
    );
  }
}
