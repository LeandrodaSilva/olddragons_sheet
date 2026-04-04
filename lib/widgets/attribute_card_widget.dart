import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sheet_model.dart';

class AttributeCard extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const AttributeCard({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mod = Sheet.modificador(value);
    final modStr = mod >= 0 ? "+$mod" : "$mod";

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color.fromRGBO(172, 25, 20, 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showEditDialog(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(172, 25, 20, 1),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$value",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(172, 25, 20, 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  modStr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: "$value");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          decoration: const InputDecoration(hintText: "Valor"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              final newVal = int.tryParse(controller.text) ?? value;
              onChanged(newVal);
              Navigator.of(ctx).pop();
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }
}
