import '../models/class_model.dart';

/// Lógica de progressão de nível do Old Dragon. Funções puras baseadas nas
/// tabelas de XP acumulado de cada classe.
class Leveling {
  Leveling._();

  /// XP acumulado necessário para atingir o próximo nível, ou null se o
  /// personagem já está no nível máximo da classe.
  static int? xpProximoNivel({required Class classe, required int nivelAtual}) {
    return classe.xpParaNivel(nivelAtual + 1);
  }

  /// True se a ficha tem XP suficiente para subir de nível e ainda não está
  /// no nível máximo.
  static bool podeSubir({
    required Class classe,
    required int nivelAtual,
    required int xpAtual,
  }) {
    final proximo = xpProximoNivel(classe: classe, nivelAtual: nivelAtual);
    return proximo != null && xpAtual >= proximo;
  }
}
