import 'package:ods/models/class_model.dart';

class ClassController {
  List<Class> classes = [
    Class(
      'Clérigo',
      'assets/images/cleric.png',
      "O clérigo é um devoto a serviço de uma divindade, combinando fé e "
      "combate. Canaliza o poder divino para curar aliados, afastar mortos-vivos "
      "e lançar milagres. Treinado para a batalha, pode usar qualquer armadura, "
      "mas evita armas cortantes ou perfurantes, preferindo maças e bastões. É o "
      "pilar de qualquer grupo de aventureiros, mantendo os companheiros vivos "
      "diante do perigo.",
      dadoDeVida: 8,
      baPorNivel: [1, 1, 1, 3, 3, 3, 5, 5, 5, 7],
      jpPorNivel: [5, 5, 5, 7, 7, 7, 9, 9, 9, 11],
    ),
    Class(
      'Homem de Armas',
      'assets/images/warrior.png',
      "O homem de armas é o mestre do combate. Dedica a vida ao domínio das "
      "armas e armaduras, sendo o mais resistente e letal em batalha. Pode usar "
      "qualquer tipo de equipamento de guerra e é o que ganha mais Pontos de "
      "Vida e a melhor Base de Ataque a cada nível. Quando o aço fala, é ele "
      "quem lidera a linha de frente.",
      dadoDeVida: 10,
      baPorNivel: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      jpPorNivel: [5, 5, 6, 6, 8, 8, 10, 10, 11, 11],
    ),
    Class(
      'Ladrão',
      'assets/images/thief.png',
      "O ladrão é o especialista em furtividade, talentos e oportunismo. Move-se "
      "nas sombras, abre fechaduras, desarma armadilhas, esvazia bolsos e ataca "
      "pontos vitais para causar dano furtivo. Limitado a armaduras leves para "
      "não comprometer suas habilidades, compensa a fragilidade com agilidade e "
      "engenhosidade. Indispensável quando a missão exige discrição.",
      dadoDeVida: 6,
      baPorNivel: [1, 1, 2, 2, 3, 3, 4, 4, 5, 5],
      jpPorNivel: [5, 5, 5, 5, 8, 8, 8, 8, 11, 11],
    ),
    Class(
      'Mago',
      'assets/images/mage.png',
      "O mago é o estudioso das artes arcanas, capaz de dobrar a realidade por "
      "meio de magias memorizadas em seu grimório. Frágil em combate corpo a "
      "corpo — não usa armaduras e maneja poucas armas —, é, no entanto, a "
      "classe de maior poder de fogo a longo prazo. De bolas de fogo a feitiços "
      "de controle, o mago transforma conhecimento em poder devastador.",
      dadoDeVida: 4,
      baPorNivel: [0, 1, 1, 1, 2, 2, 2, 3, 3, 3],
      jpPorNivel: [5, 5, 5, 5, 7, 7, 7, 7, 7, 10],
    )
  ];

  Class findOneByClassName(String name) {
    final index = classes.indexWhere(
      (Class element) => element.name == name,
    );
    if (index == -1) return classes.first;
    return classes[index];
  }
}
