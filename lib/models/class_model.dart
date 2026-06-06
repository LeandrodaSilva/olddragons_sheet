class Class {
  final String name;
  final String img;
  final String historyDescription;

  /// Dado de vida da classe (ex.: 10 = d10), conforme Livro Básico do Old Dragon.
  final int dadoDeVida;

  /// Base de Ataque (BA) por nível — índice 0 = nível 1, até o nível 10.
  final List<int> baPorNivel;

  /// Jogada de Proteção (JP) base por nível — índice 0 = nível 1, até o nível 10.
  final List<int> jpPorNivel;

  const Class(
    this.name,
    this.img,
    this.historyDescription, {
    this.dadoDeVida = 6,
    this.baPorNivel = const [0],
    this.jpPorNivel = const [5],
  });

  /// Base de Ataque no nível informado (limitada à tabela disponível).
  int baseAtaque(int nivel) {
    if (baPorNivel.isEmpty) return 0;
    final indice = nivel.clamp(1, baPorNivel.length) - 1;
    return baPorNivel[indice];
  }

  /// Jogada de Proteção base no nível informado (limitada à tabela disponível).
  int jpBase(int nivel) {
    if (jpPorNivel.isEmpty) return 5;
    final indice = nivel.clamp(1, jpPorNivel.length) - 1;
    return jpPorNivel[indice];
  }
}
