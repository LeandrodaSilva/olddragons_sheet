import 'package:flutter/material.dart';
import 'package:ods/constants/app_colors.dart';

import '../models/item_model.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onToggleEquip;
  final VoidCallback onDelete;
  final ValueChanged<int> onQuantityChanged;

  const ItemCard({
    Key? key,
    required this.item,
    required this.onToggleEquip,
    required this.onDelete,
    required this.onQuantityChanged,
  }) : super(key: key);

  IconData _iconForTipo(String tipo) {
    switch (tipo) {
      case 'arma':
        return Icons.gps_fixed;
      case 'armadura':
        return Icons.shield;
      case 'escudo':
        return Icons.shield_outlined;
      case 'municao':
        return Icons.arrow_upward;
      default:
        return Icons.inventory_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEquipavel = item.tipo == 'arma' || item.tipo == 'armadura' || item.tipo == 'escudo';

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        elevation: item.equipado ? 6 : 2,
        shadowColor: item.equipado
            ? AppColors.primaryHalf
            : Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: item.equipado
              ? const BorderSide(color: AppColors.primary, width: 2)
              : BorderSide.none,
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: item.equipado
                ? AppColors.primary
                : Colors.grey[300],
            child: Icon(
              _iconForTipo(item.tipo),
              color: item.equipado ? Colors.white : Colors.grey[700],
              size: 20,
            ),
          ),
          title: Text(
            item.nome,
            style: TextStyle(
              fontWeight: item.equipado ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            _buildSubtitle(),
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.quantidade > 1 || item.tipo == 'municao' || item.tipo == 'geral')
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () => onQuantityChanged(item.quantidade - 1),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text("${item.quantidade}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: () => onQuantityChanged(item.quantidade + 1),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              if (isEquipavel)
                IconButton(
                  icon: Icon(
                    item.equipado ? Icons.check_circle : Icons.circle_outlined,
                    color: item.equipado
                        ? AppColors.primary
                        : Colors.grey,
                  ),
                  onPressed: onToggleEquip,
                  tooltip: item.equipado ? "Desequipar" : "Equipar",
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (item.dano.isNotEmpty) parts.add("Dano: ${item.dano}");
    if (item.bonusDefesa > 0) parts.add("+${item.bonusDefesa} CA");
    if (item.peso > 0) parts.add("${item.peso} kg");
    if (item.descricao.isNotEmpty && parts.isEmpty) parts.add(item.descricao);
    return parts.join(" • ");
  }
}
