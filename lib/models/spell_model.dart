class Spell {
  String id;
  String nome;
  int circulo; // 1 a 5
  String descricao;
  bool preparada;

  Spell({
    this.id = "",
    this.nome = "",
    this.circulo = 1,
    this.descricao = "",
    this.preparada = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'circulo': circulo,
      'descricao': descricao,
      'preparada': preparada,
    };
  }

  factory Spell.fromMap(String id, Map<String, dynamic> data) {
    return Spell(
      id: id,
      nome: data['nome'] ?? "",
      circulo: data['circulo'] ?? 1,
      descricao: data['descricao'] ?? "",
      preparada: data['preparada'] ?? false,
    );
  }
}
