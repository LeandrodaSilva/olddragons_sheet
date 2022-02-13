import 'package:ods/models/class_model.dart';

class ClassController {
  List<Class> classes = [
    Class(
      'Clérigo',
      'assets/images/cleric.png',
      "Os orcs são uma raça humanoide violenta e bélica, de corpo forte "
      "crânio alongado e que levam uma vida nômade e predatória. "
      "Possuem caninos inferiores protuberantes e nariz achatado, "
      "assemelhando-se a um javali. De corpo levemente curvado para frente, "
      "os orcs têm hábitos bestiais e deploráveis, drenando todos os recursos "
      "dos locais que ocupam. Sua pele varia em tom entre o verde-claro e o "
      "marrom, apresentando verrugas e descamações. Alguns são desprovidos de "
      "cabelos, enquanto outros apresentam longas e mal cuidadas cabeleiras. "
      "A altura média de um orc macho adulto é de1,80 m e seu peso "
      "varia entre 90 kg e 120kg. Orcs não ligam para sua aparência, "
      "mas quando fazem parte de um mesmo clã, costumam padronizar pinturas "
      "corporais, vestimentas, escarificações ou até tinturas nos cabelos. "
      "As vestes são simples e geralmente maltrapilhas e comumente voltadas "
      "ao combate.Desta forma, eles preferem usar armaduras de"
      "couro ou pele do que roupas adequadas ao clima. "
      "Isso faz com que se tornem hospedeiros de pulgas e piolhos, "
      "o que geralmente é mal recebido entre outras raças.",
    ),
    Class(
      'Homem de Armas',
      'assets/images/warrior.png',
      "Os elfos são humanoides esguios e silvestres, um pouco mais baixos que"
      " os hu- manos, com traços faciais delicados, finos e graciosos. "
      "Suas orelhas são longas e pontudas, e os olhos amendoados, "
      "levemente alongados. Por serem naturalmente reclusos, os elfos que "
      "saem de suas terras em busca de aventuras o fazem pelo desejo de "
      "adquirir conhecimento, aperfeiçoar suas técnicas ou ainda como "
      "em-baixadores de seu povo. Pelo ponto de vista élfico, "
      "a rivalidade histórica entre elfos e anões é fomentada mais pelas "
      "divergências artísticas, sendo que os elfos consideram as técnicas "
      "empregadas pelos anões como rudes e grosseiras, prefe-rindo a "
      "delicadeza intrincada que empregam em detrimento da precisão"
      " metódica do povo anão. Interpretar um personagem elfo é "
      "interpretar uma criatura que se entrega com- pletamente às coisas "
      "que faz. Essa entrega muitas vezes pode ser representada "
      "de forma extrema, chegando a um ciúme, até mesmo a uma obsessão."
      "Os elfos são absolutamente monógamos; ao escolher um parceiro, "
      "o elfo se mantém ao lado dele até a morte. Com o passar do tempo, "
      "esse vínculo emocional cresce a ponto de compartilharem emoções e "
      "sentimentos mesmo separados por oceanos. Os elfos são normalmente "
      "neutros; embora sejam muitos os elfos que optam pela ordem, em"
      " especial aqueles que se dedicam às artes arcanas. "
      "Existem elfos caóticos, mas em menor número. Os elfos nunca dormem. "
      "Para descansar, se mantêm despertos e conscientes, "
      "e entram em uma meditação que dura em média 4 horas. "
      "Nesse meio tempo, as suas mentes viajam para terras longínquas "
      "e mundos desconhecidos. Atingem a maturidade aos 150 anos e "
      "podem chegar a viver até 700 anos. Um elfo mede entre 1,50 e "
      "1,70 metros, e pesa entre 40 e 50 quilos. A terra dos elfos "
      "é um lugar místico e misterioso, com suas casas erguidas nas "
      "profundezas das florestas, e é fortemente protegida, seja por "
      "batedores élficos, em sua vigília camuflada, seja pela magia "
      "que permeia o local. O fato é que, segundo viajantes e "
      "aventureiros, uma cidade élfica só é localizada se os "
      "elfos assim desejarem. As construções são erguidas em perfeita "
      "comunhão com as árvores, aproveitando as copas mais altas e "
      "frondosas para a construção das casas. Árvores mortas ce-dem sua "
      "madeira e fibras para a construção de escadarias, paliçadas, "
      "passarelas e pontes móveis que ligam as construções umas às outras."
      "Idiomas: elfos sabem inicialmente falar o idioma élfico e o comum. "
      "Entretanto, um valor alto de Inteligência os torna aptos a falar o "
      "silvestre, e, mais esporadicamente, línguas de po-vos amigos como "
      "o comum e, raramente, ou em tempos de conflito, línguas rudes, "
      "de inimigos como o orc ou o goblin."
      "Atributos: elfos são ágeis e pre-cisos, recebendo bônus de +2 "
      "na Destreza. Mas são mais frágeis que as demais raças, rece-bendo "
      "penalidade de -2 na Constituição. Visão na penumbra: treinados "
      "e adaptados à parca luz natural das noites silvestres, os elfos "
      "adquiriram a capacidade de enxergar normalmente mesmo em condições "
      "de baixa luminosidade, com alcance de até 50 metros.",
    ),
    Class(
      'Ladrão',
      'assets/images/thief.png',
      'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ab aliquid '
      'autem exercitationem facere, facilis libero voluptatem. '
      'Autem cupiditate dolore dolores doloribus, expedita laudantium '
      'molestias mollitia optio perspiciatis, suscipit totam voluptates?'
      'Aliquid assumenda commodi consectetur deserunt eius eos esse '
      'exercitationem expedita facere harum illo incidunt laborum '
      'laudantium nam neque nesciunt nobis non placeat provident quia '
      'repellat, sed ut velit vitae voluptates. Ad blanditiis commodi '
      'corporis deserunt, distinctio dolorum eligendi error fuga incidunt '
      'itaque iusto labore minus, nam nesciunt numquam porro quis '
      'quo sint sunt veritatis. Beatae culpa dignissimos '
      'et officiis quisquam. Aliquid aspernatur at autem corporis '
      'earum ex explicabo fuga ipsum laboriosam pariatur placeat quidem'
      'reprehenderit sapiente sit, suscipit veritatis vero?',
    ),
    Class(
      'Mago',
      'assets/images/mage.png',
      'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ab aliquid '
      'autem exercitationem facere, facilis libero voluptatem. '
      'Autem cupiditate dolore dolores doloribus, expedita laudantium '
      'molestias mollitia optio perspiciatis, suscipit totam voluptates?'
      'Aliquid assumenda commodi consectetur deserunt eius eos esse '
      'exercitationem expedita facere harum illo incidunt laborum '
      'laudantium nam neque nesciunt nobis non placeat provident quia '
      'repellat, sed ut velit vitae voluptates. Ad blanditiis commodi '
      'corporis deserunt, distinctio dolorum eligendi error fuga incidunt '
      'itaque iusto labore minus, nam nesciunt numquam porro quis '
      'quo sint sunt veritatis. Beatae culpa dignissimos '
      'et officiis quisquam. Aliquid aspernatur at autem corporis '
      'earum ex explicabo fuga ipsum laboriosam pariatur placeat quidem'
      'reprehenderit sapiente sit, suscipit veritatis vero?',
    )
  ];

  Class findOneByClassName(String name) {
    return classes[classes.indexWhere(
      (Class element) => element.name == name,
    )];
  }
}
