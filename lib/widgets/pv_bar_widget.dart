import 'package:flutter/material.dart';
import 'package:ods/widgets/edit_value_dialog.dart';
import 'package:ods/constants/app_colors.dart';

class PvBar extends StatefulWidget {
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
  State<PvBar> createState() => _PvBarState();
}

class _PvBarState extends State<PvBar> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _updatePulse();
  }

  @override
  void didUpdateWidget(PvBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pvAtual != widget.pvAtual ||
        oldWidget.pvMax != widget.pvMax) {
      _updatePulse();
    }
  }

  void _updatePulse() {
    final porcentagem =
        widget.pvMax > 0 ? (widget.pvAtual / widget.pvMax).clamp(0.0, 1.0) : 0.0;
    if (porcentagem <= 0.25 && widget.pvAtual > 0) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _barColor(double porcentagem) {
    if (porcentagem > 0.5) return const Color(0xFF4CAF50);
    if (porcentagem > 0.25) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  Color _glowColor(double porcentagem) {
    if (porcentagem > 0.5) return const Color(0xFF4CAF50).withOpacity(0.6);
    if (porcentagem > 0.25) return const Color(0xFFFF9800).withOpacity(0.6);
    return const Color(0xFFF44336).withOpacity(0.6);
  }

  List<Color> _barGradient(double porcentagem) {
    if (porcentagem > 0.5) {
      return [const Color(0xFF66BB6A), const Color(0xFF388E3C)];
    }
    if (porcentagem > 0.25) {
      return [const Color(0xFFFFB74D), const Color(0xFFF57C00)];
    }
    return [const Color(0xFFEF5350), const Color(0xFFC62828)];
  }

  @override
  Widget build(BuildContext context) {
    final porcentagem =
        widget.pvMax > 0 ? (widget.pvAtual / widget.pvMax).clamp(0.0, 1.0) : 0.0;
    final cor = _barColor(porcentagem);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3A5C), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _glowColor(porcentagem),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header: icone + PV + numeros
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Coracao pulsante
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.2)
                      .animate(_pulseController),
                  child: Icon(
                    Icons.favorite,
                    color: cor,
                    size: 28,
                    shadows: [
                      Shadow(color: cor.withOpacity(0.5), blurRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "PV",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                    shadows: [
                      Shadow(
                        color: cor.withOpacity(0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _editValue(
                      context, "PV Atual", widget.pvAtual, widget.onPvAtualChanged),
                  child: Text(
                    "${widget.pvAtual}",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: cor,
                      shadows: [
                        Shadow(color: cor.withOpacity(0.4), blurRadius: 8),
                      ],
                    ),
                  ),
                ),
                Text(
                  " / ",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                GestureDetector(
                  onTap: () => _editValue(
                      context, "PV Máx", widget.pvMax, widget.onPvMaxChanged),
                  child: Text(
                    "${widget.pvMax}",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Barra de vida animada
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A40),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF4A4A6A),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        // Barra animada com gradiente
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: porcentagem, end: porcentagem),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          builder: (context, value, _) {
                            return Container(
                              width: constraints.maxWidth * value,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _barGradient(porcentagem),
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _glowColor(porcentagem),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // Brilho superior (highlight)
                        Positioned(
                          top: 2,
                          left: 4,
                          right: 4,
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Botoes de acao
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  Icons.remove,
                  5,
                  true,
                  () => widget.onPvAtualChanged(
                      (widget.pvAtual - 5).clamp(0, widget.pvMax)),
                ),
                const SizedBox(width: 6),
                _buildActionButton(
                  Icons.remove,
                  1,
                  true,
                  () => widget.onPvAtualChanged(
                      (widget.pvAtual - 1).clamp(0, widget.pvMax)),
                ),
                const SizedBox(width: 20),
                _buildActionButton(
                  Icons.add,
                  1,
                  false,
                  () => widget.onPvAtualChanged(
                      (widget.pvAtual + 1).clamp(0, widget.pvMax)),
                ),
                const SizedBox(width: 6),
                _buildActionButton(
                  Icons.add,
                  5,
                  false,
                  () => widget.onPvAtualChanged(
                      (widget.pvAtual + 5).clamp(0, widget.pvMax)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, int amount, bool isDamage, VoidCallback onPressed) {
    final color = isDamage ? const Color(0xFFF44336) : const Color(0xFF4CAF50);
    final bgColor = isDamage
        ? const Color(0xFFF44336).withOpacity(0.15)
        : const Color(0xFF4CAF50).withOpacity(0.15);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 2),
              Text(
                "$amount",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
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
