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

  /// XP acumulado necessário para atingir cada nível — índice 0 = nível 1
  /// (sempre 0), até o nível 10.
  final List<int> xpPorNivel;

  const Class(
    this.name,
    this.img,
    this.historyDescription, {
    this.dadoDeVida = 6,
    this.baPorNivel = const [0],
    this.jpPorNivel = const [5],
    this.xpPorNivel = const [0],
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

  /// Nível máximo suportado pela tabela de XP.
  int get nivelMaximo => xpPorNivel.isEmpty ? 1 : xpPorNivel.length;

  /// XP acumulado necessário para atingir o nível informado, ou null se o
  /// nível estiver acima da tabela (nível máximo já alcançado).
  int? xpParaNivel(int nivel) {
    if (nivel <= 1) return 0;
    if (xpPorNivel.isEmpty || nivel > xpPorNivel.length) return null;
    return xpPorNivel[nivel - 1];
  }
}
