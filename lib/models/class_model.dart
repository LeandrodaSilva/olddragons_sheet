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

  /// Tipo de magia da classe: 'nenhuma', 'arcana' (Mago) ou 'divina' (Clérigo).
  final String tipoMagia;

  /// Magias por dia por nível: cada item é a lista de magias por círculo
  /// (1º ao 5º) naquele nível — índice 0 = nível 1. Vazio para não conjuradores.
  final List<List<int>> magiasPorDia;

  const Class(
    this.name,
    this.img,
    this.historyDescription, {
    this.dadoDeVida = 6,
    this.baPorNivel = const [0],
    this.jpPorNivel = const [5],
    this.xpPorNivel = const [0],
    this.tipoMagia = 'nenhuma',
    this.magiasPorDia = const [],
  });

  /// Se a classe é conjuradora (lança magias).
  bool get conjurador => tipoMagia != 'nenhuma' && magiasPorDia.isNotEmpty;

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

  /// Magias por dia (por círculo, 1º ao 5º) no nível informado, sem bônus de
  /// atributo. Lista vazia para não conjuradores.
  List<int> magiasNoNivel(int nivel) {
    if (magiasPorDia.isEmpty) return const [];
    final indice = nivel.clamp(1, magiasPorDia.length) - 1;
    return magiasPorDia[indice];
  }
}
