import 'package:flutter/material.dart';
import 'package:ods/widgets/edit_value_dialog.dart';
import 'package:ods/constants/app_colors.dart';

class StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final ValueChanged<int> onChanged;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showEditDialog(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(height: 2),
                Text(
                  "$value",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
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
