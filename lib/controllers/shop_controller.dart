import '../models/item_model.dart';

class ShopController {
  static final List<Item> catalogo = [
    // === ARMAS À DISTÂNCIA (T5-2) ===
    Item(nome: "Arco Curto", tipo: "arma", tamanho: "P", dano: "", tipoDano: "", critico: "", alcance: 30, especial: "Disparo 15/30, Duas Mãos", precoPO: 25, peso: 0.5),
    Item(nome: "Arco Longo", tipo: "arma", tamanho: "M", dano: "", tipoDano: "", critico: "", alcance: 50, especial: "Disparo 25/50, Duas Mãos", precoPO: 60, peso: 1.5),
    Item(nome: "Besta de Mão", tipo: "arma", tamanho: "P", dano: "", tipoDano: "", critico: "", alcance: 40, especial: "Disparo 20/40, Recarga", precoPO: 30, peso: 3.5),
    Item(nome: "Besta", tipo: "arma", tamanho: "M", dano: "", tipoDano: "", critico: "", alcance: 60, especial: "Disparo 35/60, Duas Mãos, Recarga", precoPO: 50, peso: 4),
    Item(nome: "Dardo x20", tipo: "municao", tamanho: "P", dano: "1d6", tipoDano: "Pe.", critico: "", precoPO: 10, peso: 1),
    Item(nome: "Flecha x20", tipo: "municao", tamanho: "P", dano: "1d8", tipoDano: "Pe.", critico: "", precoPO: 7, peso: 1.5),

    // === ARMAS CORPO A CORPO (T5-2) ===
    Item(nome: "Adaga", tipo: "arma", tamanho: "P", dano: "1d4", tipoDano: "Pe.", critico: "x2", alcance: 6, especial: "Arremesso 3/6", precoPO: 2, peso: 0.5),
    Item(nome: "Alabarda", tipo: "arma", tamanho: "G", dano: "1d10", tipoDano: "Co.", critico: "x3", especial: "Alcance 3, Duas Mãos", precoPO: 8, peso: 7),
    Item(nome: "Azagaia", tipo: "arma", tamanho: "M", dano: "1d10", tipoDano: "Pe.", critico: "x3", alcance: 9, especial: "Arremesso 6/9", precoPO: 10, peso: 7),
    Item(nome: "Bordão/Cajado", tipo: "arma", tamanho: "M", dano: "1d6", tipoDano: "Im.", critico: "x2", especial: "Duas Mãos", precoPO: 0, peso: 1.5),
    Item(nome: "Chicote", tipo: "arma", tamanho: "G", dano: "1d2", tipoDano: "Co.", critico: "x2", especial: "Alcance 6", precoPO: 1, peso: 0.5),
    Item(nome: "Cimitarra", tipo: "arma", tamanho: "M", dano: "1d6", tipoDano: "Co.", critico: "19-20 x2", precoPO: 15, peso: 1.5),
    Item(nome: "Espada Bastarda", tipo: "arma", tamanho: "G", dano: "1d10", tipoDano: "Co./Im.", critico: "19-20 x2", precoPO: 12, peso: 2.8),
    Item(nome: "Espada Curta", tipo: "arma", tamanho: "P", dano: "1d6", tipoDano: "Pe.", critico: "x2", precoPO: 6, peso: 1.5),
    Item(nome: "Espada Larga", tipo: "arma", tamanho: "G", dano: "2d6", tipoDano: "Co./Im.", critico: "19-20 x2", precoPO: 50, peso: 7),
    Item(nome: "Espada Longa", tipo: "arma", tamanho: "M", dano: "1d8", tipoDano: "Co.", critico: "19-20 x2", precoPO: 10, peso: 2),
    Item(nome: "Falcione", tipo: "arma", tamanho: "G", dano: "2d4", tipoDano: "Co.", critico: "19-20 x2", precoPO: 75, peso: 8),
    Item(nome: "Foice de Mão", tipo: "arma", tamanho: "P", dano: "1d6", tipoDano: "Co.", critico: "x2", precoPO: 6, peso: 1),
    Item(nome: "Lança Curta", tipo: "arma", tamanho: "P", dano: "1d6", tipoDano: "Pe.", critico: "x3", especial: "Alcance 3, Carga x2", precoPO: 1, peso: 1),
    Item(nome: "Lança Longa", tipo: "arma", tamanho: "G", dano: "1d8", tipoDano: "Pe.", critico: "x3", especial: "Alcance 3, Duas Mãos, Carga x2", precoPO: 10, peso: 9),
    Item(nome: "Maça", tipo: "arma", tamanho: "M", dano: "1d8", tipoDano: "Im.", critico: "x2", precoPO: 6, peso: 5),
    Item(nome: "Machado", tipo: "arma", tamanho: "M", dano: "1d6", tipoDano: "Co./Im.", critico: "x3", precoPO: 6, peso: 2.5),
    Item(nome: "Machado de Arremesso", tipo: "arma", tamanho: "P", dano: "1d6", tipoDano: "Co.", critico: "x3", alcance: 6, especial: "Arremesso 3/6", precoPO: 8, peso: 2),
    Item(nome: "Machado de Batalha", tipo: "arma", tamanho: "G", dano: "2d6", tipoDano: "Co./Im.", critico: "x3", especial: "Duas Mãos", precoPO: 12, peso: 8),
    Item(nome: "Mangual", tipo: "arma", tamanho: "M", dano: "1d8", tipoDano: "Im./Pe.", critico: "x2", especial: "+2 desarme", precoPO: 8, peso: 2),
    Item(nome: "Martelo", tipo: "arma", tamanho: "M", dano: "1d6", tipoDano: "Im.", critico: "x2", alcance: 6, especial: "Arremesso 3/6", precoPO: 5, peso: 3),
    Item(nome: "Martelo de Batalha", tipo: "arma", tamanho: "G", dano: "2d4", tipoDano: "Im.", critico: "x2", especial: "Duas Mãos", precoPO: 15, peso: 10),
    Item(nome: "Montante", tipo: "arma", tamanho: "G", dano: "2d6", tipoDano: "Co./Im.", critico: "19-20 x2", especial: "Alcance 3, Duas Mãos", precoPO: 20, peso: 10),
    Item(nome: "Picareta", tipo: "arma", tamanho: "M", dano: "1d6", tipoDano: "Pe.", critico: "x4", precoPO: 8, peso: 7),
    Item(nome: "Porrete", tipo: "arma", tamanho: "M", dano: "1d4", tipoDano: "Im.", critico: "x2", precoPO: 1, peso: 0.5),
    Item(nome: "Sabre", tipo: "arma", tamanho: "P", dano: "1d6", tipoDano: "Pe.", critico: "19-20 x2", precoPO: 0, peso: 1),
    Item(nome: "Tridente", tipo: "arma", tamanho: "M", dano: "1d8", tipoDano: "Pe.", critico: "x2", especial: "Alcance 3, Carga x2", precoPO: 10, peso: 2),

    // === ARMADURAS (T5-3) ===
    Item(nome: "Armadura Acolchoada", tipo: "armadura", dano: "", bonusDefesa: 1, bonusMaxDes: 99, reducaoMov: 0, precoPO: 5, peso: 5),
    Item(nome: "Armadura de Couro", tipo: "armadura", dano: "", bonusDefesa: 2, bonusMaxDes: 6, reducaoMov: 0, precoPO: 20, peso: 7),
    Item(nome: "Armadura de Couro Batido", tipo: "armadura", dano: "", bonusDefesa: 3, bonusMaxDes: 6, reducaoMov: 0, precoPO: 25, peso: 15),
    Item(nome: "Cota de Malha", tipo: "armadura", dano: "", bonusDefesa: 4, bonusMaxDes: 2, reducaoMov: 1, precoPO: 60, peso: 17),
    Item(nome: "Armadura de Placas", tipo: "armadura", dano: "", bonusDefesa: 6, bonusMaxDes: 3, reducaoMov: 2, precoPO: 300, peso: 13),
    Item(nome: "Armadura Completa", tipo: "armadura", dano: "", bonusDefesa: 8, bonusMaxDes: 1, reducaoMov: 3, precoPO: 2000, peso: 20),
    Item(nome: "Broquel", tipo: "escudo", dano: "", bonusDefesa: 1, precoPO: 15, peso: 7),
    Item(nome: "Escudo de Madeira", tipo: "escudo", dano: "", bonusDefesa: 1, precoPO: 8, peso: 3),
    Item(nome: "Escudo de Aço", tipo: "escudo", dano: "", bonusDefesa: 2, precoPO: 15, peso: 7),
    Item(nome: "Escudo Torre", tipo: "escudo", dano: "", bonusDefesa: 0, especial: "25% chance de bloquear", precoPO: 30, peso: 20),

    // === ITENS GERAIS — KIT BÁSICO (T5-4) ===
    Item(nome: "Arpéu", tipo: "geral", descricao: "Gancho triplo para escalada", precoPO: 0, peso: 3),
    Item(nome: "Corda 15m", tipo: "geral", descricao: "Suporta até 250 kg", precoPO: 1, peso: 15),
    Item(nome: "Giz", tipo: "geral", descricao: "Para marcações", precoPO: 0, peso: 0.1),
    Item(nome: "Mochila", tipo: "geral", descricao: "Armazena até 30 kg", precoPO: 0, peso: 2),
    Item(nome: "Odre", tipo: "geral", descricao: "Bolsa de couro, 1L", precoPO: 0, peso: 0.5),
    Item(nome: "Pederneira", tipo: "geral", descricao: "Afia lâminas e acende tochas", precoPO: 0, peso: 0.5),
    Item(nome: "Tocha", tipo: "geral", descricao: "Ilumina 10m por 1 hora", precoPO: 0, peso: 0.5),
    Item(nome: "Vara 3m", tipo: "geral", descricao: "Vara de madeira", precoPO: 0, peso: 0.5),

    // === KIT EXPLORADOR (T5-4) ===
    Item(nome: "Apito", tipo: "geral", descricao: "Pequeno, com cordão", precoPO: 0, peso: 0),
    Item(nome: "Escada de Corda", tipo: "geral", descricao: "Escalar no dobro da velocidade", precoPO: 5, peso: 15),
    Item(nome: "Frasco de Óleo", tipo: "geral", descricao: "500ml para fogueiras e lanternas", precoPO: 0, peso: 1),
    Item(nome: "Lanterna Furta-fogo", tipo: "geral", descricao: "Cone de 15m, 1 hora", precoPO: 1, peso: 3),
    Item(nome: "Pá/Picareta", tipo: "geral", descricao: "Para escavações", precoPO: 0, peso: 1.5),
    Item(nome: "Pé de Cabra", tipo: "geral", descricao: "Para arrombar portas", precoPO: 2, peso: 4),
    Item(nome: "Pena e Tinta", tipo: "geral", descricao: "Equipamentos para escriba", precoPO: 0, peso: 0.5),
    Item(nome: "Pergaminhos x10", tipo: "geral", descricao: "10 folhas soltas", precoPO: 0, peso: 0),
    Item(nome: "Ração de Viagem", tipo: "geral", descricao: "Alimentos secos, 1 semana", precoPO: 1, peso: 1.5),
    Item(nome: "Saco de Dormir", tipo: "geral", descricao: "Para 1 humanoide médio", precoPO: 1, peso: 10),
    Item(nome: "Tenda", tipo: "geral", descricao: "Para 4 pessoas, 2x2m", precoPO: 10, peso: 4),
  ];

  List<Item> filtrarPorTipo(String tipo) {
    if (tipo == 'todos') return catalogo;
    if (tipo == 'armas') {
      return catalogo.where((i) => i.tipo == 'arma' || i.tipo == 'municao').toList();
    }
    if (tipo == 'armaduras') {
      return catalogo.where((i) => i.tipo == 'armadura' || i.tipo == 'escudo').toList();
    }
    return catalogo.where((i) => i.tipo == tipo).toList();
  }
}
