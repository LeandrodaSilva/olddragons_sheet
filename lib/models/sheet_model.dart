class Sheet {
  String id;
  String name;
  String player;
  String race;
  String classEspec;
  String level;
  String align;
  String physicalCharacteristics;

  // Atributos primários
  int forca;
  int destreza;
  int constituicao;
  int inteligencia;
  int sabedoria;
  int carisma;

  // Stats derivados
  int pvMax;
  int pvAtual;
  int ca;
  int ba;
  int jp;
  int movimento;

  // Dinheiro
  int platina;
  int electrum;
  int ouro;
  int prata;
  int cobre;

  // XP
  int xpAtual;

  // Notas
  String notas;

  Sheet({
    this.id = "",
    this.name = "",
    this.player = "",
    this.race = "",
    this.classEspec = "",
    this.level = "1",
    this.align = "",
    this.physicalCharacteristics = "",
    this.forca = 10,
    this.destreza = 10,
    this.constituicao = 10,
    this.inteligencia = 10,
    this.sabedoria = 10,
    this.carisma = 10,
    this.pvMax = 0,
    this.pvAtual = 0,
    this.ca = 10,
    this.ba = 0,
    this.jp = 15,
    this.movimento = 9,
    this.platina = 0,
    this.electrum = 0,
    this.ouro = 0,
    this.prata = 0,
    this.cobre = 0,
    this.xpAtual = 0,
    this.notas = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'player': player,
      'race': race,
      'classEspec': classEspec,
      'level': level,
      'align': align,
      'physicalCharacteristics': physicalCharacteristics,
      'forca': forca,
      'destreza': destreza,
      'constituicao': constituicao,
      'inteligencia': inteligencia,
      'sabedoria': sabedoria,
      'carisma': carisma,
      'pvMax': pvMax,
      'pvAtual': pvAtual,
      'ca': ca,
      'ba': ba,
      'jp': jp,
      'movimento': movimento,
      'platina': platina,
      'electrum': electrum,
      'ouro': ouro,
      'prata': prata,
      'cobre': cobre,
      'xpAtual': xpAtual,
      'notas': notas,
    };
  }

  factory Sheet.fromMap(String id, Map<String, dynamic> data) {
    return Sheet(
      id: id,
      name: data['name'] ?? "",
      player: data['player'] ?? "",
      race: data['race'] ?? "",
      classEspec: data['classEspec'] ?? "",
      level: data['level'] ?? "1",
      align: data['align'] ?? "",
      physicalCharacteristics: data['physicalCharacteristics'] ?? "",
      forca: data['forca'] ?? 10,
      destreza: data['destreza'] ?? 10,
      constituicao: data['constituicao'] ?? 10,
      inteligencia: data['inteligencia'] ?? 10,
      sabedoria: data['sabedoria'] ?? 10,
      carisma: data['carisma'] ?? 10,
      pvMax: data['pvMax'] ?? 0,
      pvAtual: data['pvAtual'] ?? 0,
      ca: data['ca'] ?? 10,
      ba: data['ba'] ?? 0,
      jp: data['jp'] ?? 15,
      movimento: data['movimento'] ?? 9,
      platina: data['platina'] ?? 0,
      electrum: data['electrum'] ?? 0,
      ouro: data['ouro'] ?? 0,
      prata: data['prata'] ?? 0,
      cobre: data['cobre'] ?? 0,
      xpAtual: data['xpAtual'] ?? 0,
      notas: data['notas'] ?? "",
    );
  }

  /// Calcula o modificador de atributo conforme T1-1 do livro básico
  static int modificador(int valor) {
    if (valor <= 1) return -5;
    if (valor <= 3) return -4;
    if (valor <= 5) return -3;
    if (valor <= 7) return -2;
    if (valor <= 9) return -1;
    if (valor <= 11) return 0;
    if (valor <= 13) return 1;
    if (valor <= 15) return 2;
    if (valor <= 17) return 3;
    if (valor <= 19) return 4;
    if (valor <= 21) return 5;
    return 5 + ((valor - 21) ~/ 2);
  }
}
