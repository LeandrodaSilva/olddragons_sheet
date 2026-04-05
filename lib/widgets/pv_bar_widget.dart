import 'package:flutter/material.dart';
import 'package:ods/widgets/edit_value_dialog.dart';
import 'package:ods/constants/app_colors.dart';

class PvBar extends StatelessWidget {
  final int pvAtual;
  final int pvMax;
  final ValueChanged<int> onPvAtualChanged;
  final ValueChanged<int> onPvMaxChanged;

  const PvBar({
    Key? key,
    required this.pvAtual,
    required this.pvMax,
    required this.onPvAtualChanged,
    required this.onPvMaxChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final porcentagem = pvMax > 0 ? (pvAtual / pvMax).clamp(0.0, 1.0) : 0.0;
    final cor = porcentagem > 0.5
        ? Colors.green
        : porcentagem > 0.25
            ? Colors.orange
            : Colors.red;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite,
                    color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text("PV",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _editValue(context, "PV Atual", pvAtual,
                      (v) => onPvAtualChanged(v)),
                  child: Text(
                    "$pvAtual",
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold, color: cor),
                  ),
                ),
                Text(
                  " / ",
                  style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                ),
                GestureDetector(
                  onTap: () => _editValue(
                      context, "PV Máx", pvMax, (v) => onPvMaxChanged(v)),
                  child: Text(
                    "$pvMax",
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: porcentagem,
                minHeight: 12,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(cor),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton("-5", () => onPvAtualChanged((pvAtual - 5).clamp(0, pvMax))),
                const SizedBox(width: 8),
                _buildButton("-1", () => onPvAtualChanged((pvAtual - 1).clamp(0, pvMax))),
                const SizedBox(width: 16),
                _buildButton("+1", () => onPvAtualChanged((pvAtual + 1).clamp(0, pvMax))),
                const SizedBox(width: 8),
                _buildButton("+5", () => onPvAtualChanged((pvAtual + 5).clamp(0, pvMax))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    final isNegative = label.startsWith("-");
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          isNegative ? Colors.red[100] : Colors.green[100],
        ),
        foregroundColor: WidgetStateProperty.all(
          isNegative ? Colors.red[800] : Colors.green[800],
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        minimumSize: WidgetStateProperty.all(const Size(48, 36)),
        elevation: WidgetStateProperty.all(0),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  void _editValue(BuildContext context, String title, int current,
      ValueChanged<int> onSave) async {
    final newVal = await showEditValueDialog(
      context,
      title: title,
      currentValue: current,
    );
    if (newVal != null) onSave(newVal);
  }
}
