import 'package:flutter/material.dart';
import 'package:ods/constants/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Mantido em sincronia com a versão do pubspec.yaml.
  static const String _versao = "2.1.0";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Image.asset(
                  "assets/images/logo.png",
                  width: 120,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.shield, size: 96, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  "OldDragons Sheet",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  "Versão $_versao",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),
              _buildCard(
                icon: Icons.menu_book,
                titulo: "Sobre o app",
                texto:
                    "Ficha digital interativa para criar e jogar personagens "
                    "de Old Dragon RPG. Monte raça, classe e atributos e jogue "
                    "com inventário, loja, rolagem de dados e cálculo "
                    "automático dos stats — tudo sincronizado em tempo real "
                    "entre seus dispositivos.",
              ),
              const SizedBox(height: 12),
              _buildCard(
                icon: Icons.calculate,
                titulo: "Cálculo automático",
                texto:
                    "PV, CA, Base de Ataque, Jogada de Proteção e Movimento são "
                    "calculados a partir dos seus atributos, classe, raça e "
                    "equipamento, seguindo o Livro Básico do Old Dragon. Cada "
                    "stat permite um ajuste manual (\"Outros\") quando "
                    "necessário.",
              ),
              const SizedBox(height: 12),
              _buildCard(
                icon: Icons.copyright,
                titulo: "Créditos",
                texto:
                    "Old Dragon RPG é uma obra da Buró Editorial. Este é um "
                    "aplicativo não oficial, feito por fãs para apoiar as mesas "
                    "de jogo. Todos os direitos das regras pertencem aos seus "
                    "autores.",
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String titulo,
    required String texto,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              texto,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
