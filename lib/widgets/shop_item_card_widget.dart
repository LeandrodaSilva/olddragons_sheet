import 'package:flutter/material.dart';

import '../models/item_model.dart';

class ShopItemCard extends StatelessWidget {
  final Item item;
  final bool canBuy;
  final VoidCallback onBuy;

  const ShopItemCard({
    Key? key,
    required this.item,
    required this.canBuy,
    required this.onBuy,
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
    final preco = item.precoPO > 0 ? "${item.precoPO} PO" : "< 1 PO";

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              child: Icon(_iconForTipo(item.tipo),
                  color: Colors.grey[700], size: 20),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.nome,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_buildLine1(),
                      style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  if (_buildLine2().isNotEmpty)
                    Text(_buildLine2(),
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            // Preço e botão
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(preco,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(172, 25, 20, 1))),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: canBuy ? onBuy : null,
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    minimumSize:
                        WidgetStateProperty.all(const Size(0, 32)),
                  ),
                  child: const Text("Comprar", style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildLine1() {
    final parts = <String>[];
    if (item.dano.isNotEmpty) parts.add(item.dano);
    if (item.tipoDano.isNotEmpty) parts.add(item.tipoDano);
    if (item.bonusDefesa > 0) parts.add("+${item.bonusDefesa} CA");
    if (item.peso > 0) parts.add("${item.peso} kg");
    if (item.tamanho.isNotEmpty && item.tipo == 'arma') parts.add(item.tamanho);
    if (parts.isEmpty && item.descricao.isNotEmpty) parts.add(item.descricao);
    return parts.join(" • ");
  }

  String _buildLine2() {
    final parts = <String>[];
    if (item.critico.isNotEmpty) parts.add("Crit: ${item.critico}");
    if (item.especial.isNotEmpty) parts.add(item.especial);
    if (item.reducaoMov > 0) parts.add("-${item.reducaoMov}m mov");
    if (item.bonusMaxDes < 99) parts.add("Max DES +${item.bonusMaxDes}");
    return parts.join(" • ");
  }
}
