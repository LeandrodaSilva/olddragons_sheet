import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ods/constants/app_colors.dart';
import 'package:ods/controllers/sheet_controller.dart';
import 'package:ods/widgets/edit_value_dialog.dart';
import 'package:provider/provider.dart';
import '../models/sheet_model.dart';

class AddSheetScreen extends StatefulWidget {
  final Sheet item;

  const AddSheetScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddSheetScreenState();
}

class _AddSheetScreenState extends State<AddSheetScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _random = Random();

  int _rolar3d6() {
    return _random.nextInt(6) + 1 + _random.nextInt(6) + 1 + _random.nextInt(6) + 1;
  }

  void _rolarTodosAtributos() {
    setState(() {
      widget.item.forca = _rolar3d6();
      widget.item.destreza = _rolar3d6();
      widget.item.constituicao = _rolar3d6();
      widget.item.inteligencia = _rolar3d6();
      widget.item.sabedoria = _rolar3d6();
      widget.item.carisma = _rolar3d6();
    });
  }

  void _rolarOuroInicial() {
    final resultado = _random.nextInt(6) + 1 + _random.nextInt(6) + 1 + _random.nextInt(6) + 1;
    setState(() {
      widget.item.ouro = resultado * 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    Sheet item = widget.item;
    return Consumer<SheetController>(
      builder: (context, sm, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(item.id.isNotEmpty ? "Editar Ficha" : "Nova Ficha"),
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(minWidth: 100, maxWidth: 600),
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // === DADOS BÁSICOS ===
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("DADOS BÁSICOS",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary)),
                              const SizedBox(height: 8),
                              TextFormField(
                                decoration: const InputDecoration(
                                    hintText: 'Nome do personagem'),
                                initialValue: item.name,
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Insira o nome do personagem';
                                  }
                                  return null;
                                },
                                onChanged: (val) =>
                                    setState(() => item.name = val),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                readOnly: true,
                                decoration:
                                    const InputDecoration(hintText: 'Raça'),
                                initialValue: item.race,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                readOnly: true,
                                decoration:
                                    const InputDecoration(hintText: 'Classe'),
                                initialValue: item.classEspec,
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                decoration:
                                    const InputDecoration(hintText: 'Nível'),
                                initialValue: item.level,
                                onChanged: (val) =>
                                    setState(() => item.level = val),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: item.align.isNotEmpty
                                    ? item.align
                                    : null,
                                decoration: const InputDecoration(
                                    hintText: 'Alinhamento'),
                                items: const [
                                  DropdownMenuItem(
                                      value: "Ordeiro",
                                      child: Text("Ordeiro")),
                                  DropdownMenuItem(
                                      value: "Neutro",
                                      child: Text("Neutro")),
                                  DropdownMenuItem(
                                      value: "Caótico",
                                      child: Text("Caótico")),
                                ],
                                onChanged: (val) =>
                                    setState(() => item.align = val ?? ""),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // === ATRIBUTOS ===
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("ATRIBUTOS (3d6)",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(
                                              172, 25, 20, 1))),
                                  ElevatedButton.icon(
                                    onPressed: _rolarTodosAtributos,
                                    icon: const Icon(Icons.casino, size: 18),
                                    label: const Text("Rolar todos"),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildAtributosGrid(item),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // === OURO INICIAL ===
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("RENDA INICIAL",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${item.ouro} PO",
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _rolarOuroInicial,
                                    icon: const Icon(Icons.casino, size: 18),
                                    label: const Text("3d6 × 10"),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                              Text("Rolar 3d6 × 10 PO (conforme livro)",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // === SALVAR ===
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            sm.add(item);
                            Navigator.popUntil(
                              context,
                              ModalRoute.withName("/"),
                            );
                          }
                        },
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.save), Text(' Salvar')],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAtributosGrid(Sheet item) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _buildAtributoField("FOR", item.forca, (v) => setState(() => item.forca = v)),
        _buildAtributoField("DES", item.destreza, (v) => setState(() => item.destreza = v)),
        _buildAtributoField("CON", item.constituicao, (v) => setState(() => item.constituicao = v)),
        _buildAtributoField("INT", item.inteligencia, (v) => setState(() => item.inteligencia = v)),
        _buildAtributoField("SAB", item.sabedoria, (v) => setState(() => item.sabedoria = v)),
        _buildAtributoField("CAR", item.carisma, (v) => setState(() => item.carisma = v)),
      ],
    );
  }

  Widget _buildAtributoField(
      String label, int value, ValueChanged<int> onChanged) {
    final mod = Sheet.modificador(value);
    final modStr = mod >= 0 ? "+$mod" : "$mod";

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final newVal = await showEditValueDialog(
            context,
            title: label,
            currentValue: value,
          );
          if (newVal != null) onChanged(newVal);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            Text("$value",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(modStr,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
