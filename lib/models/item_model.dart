class Item {
  String id;
  String nome;
  String descricao;
  String tipo; // 'arma', 'armadura', 'escudo', 'municao', 'geral'
  String tamanho; // 'P', 'M', 'G'
  int quantidade;
  bool equipado;

  // Campos de arma
  String dano; // ex: "1d8", "2d6"
  String tipoDano; // "Co.", "Im.", "Pe."
  String critico; // ex: "x2", "19-20 x2"
  int alcance; // metros
  String especial; // "Arremesso 3/6", etc.

  // Campos de armadura
  int bonusDefesa; // +CA
  int bonusMaxDes; // Bônus máximo de DES
  int reducaoMov; // Redução de movimentação em metros

  // Economia e peso
  int precoPO; // Preço em PO
  double peso; // kg

  Item({
    this.id = "",
    this.nome = "",
    this.descricao = "",
    this.tipo = "geral",
    this.tamanho = "M",
    this.quantidade = 1,
    this.equipado = false,
    this.dano = "",
    this.tipoDano = "",
    this.critico = "",
    this.alcance = 0,
    this.especial = "",
    this.bonusDefesa = 0,
    this.bonusMaxDes = 99,
    this.reducaoMov = 0,
    this.precoPO = 0,
    this.peso = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'tipo': tipo,
      'tamanho': tamanho,
      'quantidade': quantidade,
      'equipado': equipado,
      'dano': dano,
      'tipoDano': tipoDano,
      'critico': critico,
      'alcance': alcance,
      'especial': especial,
      'bonusDefesa': bonusDefesa,
      'bonusMaxDes': bonusMaxDes,
      'reducaoMov': reducaoMov,
      'precoPO': precoPO,
      'peso': peso,
    };
  }

  factory Item.fromMap(String id, Map<String, dynamic> data) {
    return Item(
      id: id,
      nome: data['nome'] ?? "",
      descricao: data['descricao'] ?? "",
      tipo: data['tipo'] ?? "geral",
      tamanho: data['tamanho'] ?? "M",
      quantidade: data['quantidade'] ?? 1,
      equipado: data['equipado'] ?? false,
      dano: data['dano'] ?? "",
      tipoDano: data['tipoDano'] ?? "",
      critico: data['critico'] ?? "",
      alcance: data['alcance'] ?? 0,
      especial: data['especial'] ?? "",
      bonusDefesa: data['bonusDefesa'] ?? 0,
      bonusMaxDes: data['bonusMaxDes'] ?? 99,
      reducaoMov: data['reducaoMov'] ?? 0,
      precoPO: data['precoPO'] ?? 0,
      peso: (data['peso'] ?? 0).toDouble(),
    );
  }
}
