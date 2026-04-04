import 'dart:math';

class DiceResult {
  final String expression;
  final List<int> rolls;
  final int modifier;
  final int total;

  DiceResult({
    required this.expression,
    required this.rolls,
    this.modifier = 0,
    required this.total,
  });
}

class DiceController {
  final Random _random = Random();
  final List<DiceResult> historico = [];

  int rolar(int lados) {
    return _random.nextInt(lados) + 1;
  }

  DiceResult rolarDado(int lados) {
    final resultado = rolar(lados);
    final result = DiceResult(
      expression: "1d$lados",
      rolls: [resultado],
      total: resultado,
    );
    _adicionarHistorico(result);
    return result;
  }

  /// Rola XdY+Z a partir de uma expressão como "2d6+3"
  DiceResult rolarExpressao(String expressao) {
    final regex = RegExp(r'^(\d+)d(\d+)([+-]\d+)?$');
    final match = regex.firstMatch(expressao.replaceAll(' ', ''));

    if (match == null) {
      return DiceResult(expression: expressao, rolls: [0], total: 0);
    }

    final quantidade = int.parse(match.group(1)!);
    final lados = int.parse(match.group(2)!);
    final modificador = match.group(3) != null ? int.parse(match.group(3)!) : 0;

    final rolls = <int>[];
    for (var i = 0; i < quantidade; i++) {
      rolls.add(rolar(lados));
    }

    final total = rolls.fold(0, (sum, r) => sum + r) + modificador;
    final result = DiceResult(
      expression: expressao,
      rolls: rolls,
      modifier: modificador,
      total: total,
    );
    _adicionarHistorico(result);
    return result;
  }

  void _adicionarHistorico(DiceResult result) {
    historico.insert(0, result);
    if (historico.length > 5) {
      historico.removeLast();
    }
  }
}
