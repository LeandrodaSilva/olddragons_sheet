import 'package:flutter/material.dart';
import 'package:ods/constants/app_colors.dart';

import '../controllers/dice_controller.dart';
import '../models/sheet_model.dart';

class DiceRollerWidget extends StatefulWidget {
  final DiceController diceController;
  final Sheet sheet;

  const DiceRollerWidget({
    Key? key,
    required this.diceController,
    required this.sheet,
  }) : super(key: key);

  @override
  State<DiceRollerWidget> createState() => _DiceRollerWidgetState();
}

class _DiceRollerWidgetState extends State<DiceRollerWidget> {
  DiceResult? _lastResult;
  final TextEditingController _customController = TextEditingController();

  void _rolarDado(int lados) {
    setState(() {
      _lastResult = widget.diceController.rolarDado(lados);
    });
  }

  void _rolarExpressao(String expressao) {
    if (expressao.trim().isEmpty) return;
    setState(() {
      _lastResult = widget.diceController.rolarExpressao(expressao.trim());
    });
  }

  void _rolarAtalho(String label, String expressao, int modificador) {
    final result = widget.diceController.rolarExpressao("1d20");
    final total = result.rolls.first + modificador;
    setState(() {
      _lastResult = DiceResult(
        expression: "$label: 1d20${modificador >= 0 ? '+' : ''}$modificador",
        rolls: result.rolls,
        modifier: modificador,
        total: total,
      );
      widget.diceController.historico.insert(0, _lastResult!);
      if (widget.diceController.historico.length > DiceController.maxHistorySize) {
        widget.diceController.historico.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildResultado(),
              const SizedBox(height: 20),
              _buildDiceGrid(),
              const SizedBox(height: 20),
              _buildAtalhosCombate(),
              const SizedBox(height: 20),
              _buildCustomRoll(),
              const SizedBox(height: 20),
              _buildHistorico(),
            ],
          ),
        ),
      ),
    );
  }

  // === RESULTADO ===
  Widget _buildResultado() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _lastResult != null ? "${_lastResult!.total}" : "—",
                key: ValueKey(_lastResult?.total ?? -1),
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            if (_lastResult != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _buildResultDetail(),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _buildResultDetail() {
    if (_lastResult == null) return "";
    final r = _lastResult!;
    final rollsStr = r.rolls.length > 1 ? "[${r.rolls.join(', ')}]" : "${r.rolls.first}";
    final modStr = r.modifier != 0
        ? " ${r.modifier >= 0 ? '+' : ''}${r.modifier}"
        : "";
    return "${r.expression} → $rollsStr$modStr";
  }

  // === GRID DE DADOS ===
  Widget _buildDiceGrid() {
    const dados = [4, 6, 8, 10, 12, 20];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: dados.map((d) => _buildDiceButton(d)).toList(),
    );
  }

  Widget _buildDiceButton(int lados) {
    return ElevatedButton(
      onPressed: () => _rolarDado(lados),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          AppColors.primary,
        ),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevation: WidgetStateProperty.all(3),
      ),
      child: Text(
        "d$lados",
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  // === ATALHOS DE COMBATE ===
  Widget _buildAtalhosCombate() {
    final sheet = widget.sheet;
    final modFor = Sheet.modificador(sheet.forca);
    final modDes = Sheet.modificador(sheet.destreza);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("COMBATE",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildAtalhoButton(
              Icons.speed,
              "Iniciativa",
              "1d20+${modDes >= 0 ? '+' : ''}$modDes",
              modDes,
            ),
            _buildAtalhoButton(
              Icons.gps_fixed,
              "Ataque C.a.C.",
              "1d20+BA(${sheet.ba})+FOR($modFor)",
              sheet.ba + modFor,
            ),
            _buildAtalhoButton(
              Icons.my_location,
              "Ataque Dist.",
              "1d20+BA(${sheet.ba})+DES($modDes)",
              sheet.ba + modDes,
            ),
            _buildAtalhoButton(
              Icons.security,
              "JP (≥${sheet.jp})",
              "1d20 ≥ ${sheet.jp}",
              0,
              isJp: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAtalhoButton(
      IconData icon, String label, String detail, int modificador,
      {bool isJp = false}) {
    return OutlinedButton.icon(
      onPressed: () {
        if (isJp) {
          final result = widget.diceController.rolarDado(20);
          final sucesso = result.total >= widget.sheet.jp;
          setState(() {
            _lastResult = DiceResult(
              expression: "JP: 1d20 ≥ ${widget.sheet.jp} → ${sucesso ? 'SUCESSO' : 'FALHA'}",
              rolls: result.rolls,
              total: result.total,
            );
          });
        } else {
          _rolarAtalho(label, "1d20", modificador);
        }
      },
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primaryHalf),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // === ROLAGEM CUSTOMIZADA ===
  Widget _buildCustomRoll() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("ROLAGEM CUSTOMIZADA",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customController,
                decoration: InputDecoration(
                  hintText: "Ex: 2d6+3",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onSubmitted: (v) {
                  _rolarExpressao(v);
                  _customController.clear();
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                _rolarExpressao(_customController.text);
                _customController.clear();
              },
              child: const Text("Rolar"),
            ),
          ],
        ),
      ],
    );
  }

  // === HISTÓRICO ===
  Widget _buildHistorico() {
    final historico = widget.diceController.historico;
    if (historico.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("HISTÓRICO",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary)),
        const SizedBox(height: 8),
        ...historico.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                "${r.expression} → ${r.total}",
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            )),
      ],
    );
  }
}
