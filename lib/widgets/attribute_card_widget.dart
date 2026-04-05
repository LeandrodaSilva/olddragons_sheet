import 'package:flutter/material.dart';
import 'package:ods/widgets/edit_value_dialog.dart';
import 'package:ods/constants/app_colors.dart';
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
          color: AppColors.primaryLight,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            // Botao diminuir
            SizedBox(
              height: 28,
              width: 28,
              child: IconButton(
                onPressed: () => onChanged(value - 1),
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 18,
                color: AppColors.primaryHalf,
                padding: EdgeInsets.zero,
                tooltip: "Diminuir $label",
              ),
            ),
            // Valor (tappable para editar)
            GestureDetector(
              onTap: () => _showEditDialog(context),
              child: Text(
                "$value",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Botao aumentar
            SizedBox(
              height: 28,
              width: 28,
              child: IconButton(
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 18,
                color: AppColors.primaryHalf,
                padding: EdgeInsets.zero,
                tooltip: "Aumentar $label",
              ),
            ),
            // Badge modificador
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                modStr,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) async {
    final newVal = await showEditValueDialog(
      context,
      title: label,
      currentValue: value,
    );
    if (newVal != null) onChanged(newVal);
  }
}
