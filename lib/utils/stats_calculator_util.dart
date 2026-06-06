import '../models/class_model.dart';
import '../models/item_model.dart';
import '../models/sheet_model.dart';

/// Cálculo dos stats derivados do Old Dragon a partir de atributos, classe,
/// raça e equipamento. Funções puras — fáceis de testar e reaproveitar (ex.:
/// no level-up automático).
class StatsCalculator {
  StatsCalculator._();

  /// CA = 10 + mod DES (limitado pelo bônus máximo da armadura) + bônus de
  /// defesa dos itens equipados (armadura + escudo) + ajuste manual (outros).
  static int ca({
    required int destreza,
    required List<Item> equipados,
    int outros = 0,
  }) {
    final modDes = Sheet.modificador(destreza);
    var maxDes = 99;
    var bonusDefesa = 0;
    for (final item in equipados) {
      bonusDefesa += item.bonusDefesa;
      if (item.bonusMaxDes < maxDes) maxDes = item.bonusMaxDes;
    }
    final desAplicado = modDes > maxDes ? maxDes : modDes;
    return 10 + desAplicado + bonusDefesa + outros;
  }

  /// PV máximo no modo determinístico: dado de vida cheio + mod CON por nível,
  /// até o 10º nível (conforme regra do Livro Básico), com mínimo de 1 PV por
  /// nível. O ajuste manual (outros) permite reconciliar com PV rolados em mesa.
  static int pvMax({
    required int dadoDeVida,
    required int constituicao,
    required int nivel,
    int outros = 0,
  }) {
    final modCon = Sheet.modificador(constituicao);
    final niveisComGanho = nivel.clamp(1, 10);
    final ganhoPorNivel = dadoDeVida + modCon;
    final base = ganhoPorNivel < 1 ? niveisComGanho : ganhoPorNivel * niveisComGanho;
    return base + outros;
  }

  /// Base de Ataque da classe no nível + ajuste manual. O modificador de
  /// atributo (FOR para corpo a corpo, DES para distância) é somado na rolagem.
  static int baseAtaque({
    required Class classe,
    required int nivel,
    int outros = 0,
  }) {
    return classe.baseAtaque(nivel) + outros;
  }

  /// JP base da classe no nível + ajuste manual. O modificador de atributo
  /// (DES/CON/SAB conforme o tipo de proteção) é aplicado situacionalmente.
  static int jpBase({
    required Class classe,
    required int nivel,
    int outros = 0,
  }) {
    return classe.jpBase(nivel) + outros;
  }

  /// Movimento = base da raça − redução das armaduras equipadas + ajuste manual
  /// (nunca abaixo de 0).
  static int movimento({
    required int baseRaca,
    required List<Item> equipados,
    int outros = 0,
  }) {
    final reducao = equipados.fold<int>(0, (total, item) => total + item.reducaoMov);
    final mov = baseRaca - reducao + outros;
    return mov < 0 ? 0 : mov;
  }
}
