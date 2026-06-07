import '../models/class_model.dart';

/// Cálculo de magias por dia do Old Dragon (Tabela 8.1), incluindo as magias
/// bônus concedidas por valores altos de Inteligência (Mago) ou Sabedoria
/// (Clérigo). Funções puras.
class MagicCalculator {
  MagicCalculator._();

  /// Magias por dia por círculo (1º ao 5º) no nível informado.
  ///
  /// [atributoConjurador] é a Inteligência (arcana) ou a Sabedoria (divina).
  /// As magias bônus só se aplicam aos círculos que o conjurador já acessa.
  /// Retorna lista vazia para classes não conjuradoras.
  static List<int> magiasPorDia({
    required Class classe,
    required int nivel,
    required int atributoConjurador,
  }) {
    final base = classe.magiasNoNivel(nivel);
    if (base.isEmpty) return const [];

    final resultado = List<int>.from(base);
    // 13-14 => bônus no 1º círculo; 15-16 => 1º e 2º; 17-18 => até o 3º; etc.
    final circulosComBonus = ((atributoConjurador - 11) ~/ 2);
    for (var c = 0; c < resultado.length; c++) {
      final acessaCirculo = resultado[c] > 0;
      if (c < circulosComBonus && acessaCirculo) {
        resultado[c] += 1;
      }
    }
    return resultado;
  }

  /// Maior círculo acessível no nível (1 a 5), ou 0 se não conjura nesse nível.
  static int maiorCirculo({required Class classe, required int nivel}) {
    final base = classe.magiasNoNivel(nivel);
    var maior = 0;
    for (var c = 0; c < base.length; c++) {
      if (base[c] > 0) maior = c + 1;
    }
    return maior;
  }
}
