import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ods/controllers/sheet_controller.dart';
import 'package:ods/models/sheet_model.dart';

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  final FakeUser _user;
  FakeFirebaseAuth({String uid = 'test-uid'}) : _user = FakeUser(uid: uid);

  @override
  User? get currentUser => _user;
}

class FakeUser extends Fake implements User {
  @override
  final String uid;
  FakeUser({required this.uid});
}

void main() {
  group('Integração Firebase — Mudança de valores na ficha', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FakeFirebaseAuth fakeAuth;
    late SheetModel sheetModel;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      fakeAuth = FakeFirebaseAuth(uid: 'player-1');
      sheetModel = SheetModel(firestore: fakeFirestore, auth: fakeAuth);
      await Future.delayed(Duration.zero);
    });

    tearDown(() {
      sheetModel.dispose();
    });

    /// Helper: cria uma ficha e retorna ela com o id preenchido pelo Firestore
    Future<Sheet> criarFicha({
      String name = 'Aragorn',
      String race = 'Humano',
      String classEspec = 'Homem de Armas',
      int forca = 14,
      int destreza = 12,
      int constituicao = 15,
      int pvMax = 30,
      int pvAtual = 30,
      int ca = 14,
      int ba = 2,
      int jp = 13,
      int movimento = 9,
      int ouro = 100,
      int prata = 50,
      int cobre = 200,
      int xpAtual = 3000,
    }) async {
      final sheet = Sheet(
        name: name,
        race: race,
        classEspec: classEspec,
        level: '3',
        forca: forca,
        destreza: destreza,
        constituicao: constituicao,
        pvMax: pvMax,
        pvAtual: pvAtual,
        ca: ca,
        ba: ba,
        jp: jp,
        movimento: movimento,
        ouro: ouro,
        prata: prata,
        cobre: cobre,
        xpAtual: xpAtual,
      );
      await sheetModel.add(sheet);
      await Future.delayed(Duration.zero);
      return sheet;
    }

    /// Helper: lê os dados brutos do Firestore para uma ficha
    Future<Map<String, dynamic>> lerDadosFichaFirestore(String id) async {
      final doc = await fakeFirestore.collection('sheets').doc(id).get();
      return doc.data()!;
    }

    group('Criação e persistência da ficha', () {
      test('cria ficha no Firestore com id gerado', () async {
        final sheet = await criarFicha();

        expect(sheet.id, isNotEmpty);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['name'], 'Aragorn');
        expect(data['race'], 'Humano');
        expect(data['classEspec'], 'Homem de Armas');
        expect(data['uid'], 'player-1');
      });

      test('ficha aparece na lista do SheetModel após criação', () async {
        await criarFicha(name: 'Legolas');
        await Future.delayed(Duration.zero);

        expect(sheetModel.items.length, 1);
        expect(sheetModel.items.first.name, 'Legolas');
      });

      test('múltiplas fichas são listadas corretamente', () async {
        await criarFicha(name: 'Aragorn');
        await criarFicha(name: 'Legolas');
        await criarFicha(name: 'Gimli');
        await Future.delayed(Duration.zero);

        expect(sheetModel.items.length, 3);
        final nomes = sheetModel.items.map((s) => s.name).toSet();
        expect(nomes, containsAll(['Aragorn', 'Legolas', 'Gimli']));
      });
    });

    group('Alteração de atributos primários', () {
      test('alterar Força persiste no Firestore', () async {
        final sheet = await criarFicha(forca: 14);

        sheet.forca = 18;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['forca'], 18);
      });

      test('alterar Destreza persiste no Firestore', () async {
        final sheet = await criarFicha(destreza: 12);

        sheet.destreza = 16;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['destreza'], 16);
      });

      test('alterar Constituição persiste no Firestore', () async {
        final sheet = await criarFicha(constituicao: 10);

        sheet.constituicao = 14;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['constituicao'], 14);
      });

      test('alterar todos os 6 atributos de uma vez', () async {
        final sheet = await criarFicha();

        sheet.forca = 18;
        sheet.destreza = 16;
        sheet.constituicao = 14;
        sheet.inteligencia = 12;
        sheet.sabedoria = 15;
        sheet.carisma = 8;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['forca'], 18);
        expect(data['destreza'], 16);
        expect(data['constituicao'], 14);
        expect(data['inteligencia'], 12);
        expect(data['sabedoria'], 15);
        expect(data['carisma'], 8);
      });

      test('modificador é recalculado após alterar atributo', () async {
        final sheet = await criarFicha(forca: 10);
        expect(Sheet.modificador(sheet.forca), 0);

        sheet.forca = 18;
        expect(Sheet.modificador(sheet.forca), 4);

        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['forca'], 18);
        expect(Sheet.modificador(data['forca'] as int), 4);
      });
    });

    group('Alteração de PV (Pontos de Vida)', () {
      test('reduzir PV atual persiste no Firestore', () async {
        final sheet = await criarFicha(pvMax: 30, pvAtual: 30);

        sheet.pvAtual = 25;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['pvAtual'], 25);
        expect(data['pvMax'], 30);
      });

      test('aumentar PV atual persiste no Firestore', () async {
        final sheet = await criarFicha(pvMax: 30, pvAtual: 15);

        sheet.pvAtual = 20;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['pvAtual'], 20);
      });

      test('alterar PV máximo persiste no Firestore', () async {
        final sheet = await criarFicha(pvMax: 30, pvAtual: 30);

        sheet.pvMax = 40;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['pvMax'], 40);
      });

      test('PV atual pode ser reduzido a zero', () async {
        final sheet = await criarFicha(pvMax: 30, pvAtual: 5);

        sheet.pvAtual = 0;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['pvAtual'], 0);
      });

      test('simula botão -5 com clamp (como PvBar faz)', () async {
        final sheet = await criarFicha(pvMax: 30, pvAtual: 3);

        // Simula o comportamento do PvBar: (pvAtual - 5).clamp(0, pvMax)
        sheet.pvAtual = (sheet.pvAtual - 5).clamp(0, sheet.pvMax);
        expect(sheet.pvAtual, 0);

        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['pvAtual'], 0);
      });

      test('simula botão +5 com clamp (como PvBar faz)', () async {
        final sheet = await criarFicha(pvMax: 30, pvAtual: 28);

        // Simula o comportamento do PvBar: (pvAtual + 5).clamp(0, pvMax)
        sheet.pvAtual = (sheet.pvAtual + 5).clamp(0, sheet.pvMax);
        expect(sheet.pvAtual, 30);

        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['pvAtual'], 30);
      });

      test('reduzir PV máximo ajusta PV atual se necessário', () async {
        final sheet = await criarFicha(pvMax: 30, pvAtual: 30);

        // Simula o comportamento do PlayScreen quando pvMax muda
        sheet.pvMax = 20;
        if (sheet.pvAtual > sheet.pvMax) {
          sheet.pvAtual = sheet.pvMax;
        }
        expect(sheet.pvAtual, 20);

        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['pvMax'], 20);
        expect(data['pvAtual'], 20);
      });
    });

    group('Alteração de stats derivados (CA, JP, BA, MOV)', () {
      test('alterar CA persiste no Firestore', () async {
        final sheet = await criarFicha(ca: 14);

        sheet.ca = 18;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['ca'], 18);
      });

      test('alterar JP persiste no Firestore', () async {
        final sheet = await criarFicha(jp: 13);

        sheet.jp = 10;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['jp'], 10);
      });

      test('alterar BA persiste no Firestore', () async {
        final sheet = await criarFicha(ba: 2);

        sheet.ba = 5;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['ba'], 5);
      });

      test('alterar Movimento persiste no Firestore', () async {
        final sheet = await criarFicha(movimento: 9);

        sheet.movimento = 6;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['movimento'], 6);
      });

      test('alterar todos os stats derivados de uma vez', () async {
        final sheet = await criarFicha();

        sheet.ca = 20;
        sheet.jp = 8;
        sheet.ba = 7;
        sheet.movimento = 12;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['ca'], 20);
        expect(data['jp'], 8);
        expect(data['ba'], 7);
        expect(data['movimento'], 12);
      });
    });

    group('Alteração de dinheiro', () {
      test('alterar ouro persiste no Firestore', () async {
        final sheet = await criarFicha(ouro: 100);

        sheet.ouro = 75;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['ouro'], 75);
      });

      test('alterar prata persiste no Firestore', () async {
        final sheet = await criarFicha(prata: 50);

        sheet.prata = 30;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['prata'], 30);
      });

      test('alterar cobre persiste no Firestore', () async {
        final sheet = await criarFicha(cobre: 200);

        sheet.cobre = 150;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['cobre'], 150);
      });

      test('alterar todas as moedas de uma vez', () async {
        final sheet = await criarFicha();

        sheet.platina = 5;
        sheet.electrum = 10;
        sheet.ouro = 200;
        sheet.prata = 80;
        sheet.cobre = 500;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['platina'], 5);
        expect(data['electrum'], 10);
        expect(data['ouro'], 200);
        expect(data['prata'], 80);
        expect(data['cobre'], 500);
      });

      test('ouro pode ser reduzido a zero', () async {
        final sheet = await criarFicha(ouro: 10);

        sheet.ouro = 0;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['ouro'], 0);
      });
    });

    group('Alteração de XP', () {
      test('alterar XP persiste no Firestore', () async {
        final sheet = await criarFicha(xpAtual: 3000);

        sheet.xpAtual = 5500;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['xpAtual'], 5500);
      });

      test('XP pode começar em zero', () async {
        final sheet = await criarFicha(xpAtual: 0);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['xpAtual'], 0);
      });

      test('XP pode ter valores altos', () async {
        final sheet = await criarFicha(xpAtual: 0);

        sheet.xpAtual = 999999;
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['xpAtual'], 999999);
      });
    });

    group('Alteração de notas', () {
      test('alterar notas persiste no Firestore', () async {
        final sheet = await criarFicha();

        sheet.notas = 'Encontrou o anel mágico na caverna';
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['notas'], 'Encontrou o anel mágico na caverna');
      });

      test('notas podem conter texto longo com quebras de linha', () async {
        final sheet = await criarFicha();

        sheet.notas = 'Sessão 1:\n- Derrotou o goblin\n- Ganhou 50 PO\n\nSessão 2:\n- Explorou a masmorra';
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['notas'], contains('Sessão 1:'));
        expect(data['notas'], contains('Sessão 2:'));
      });

      test('notas podem ser limpas', () async {
        final sheet = await criarFicha();
        sheet.notas = 'Texto inicial';
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        sheet.notas = '';
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['notas'], '');
      });
    });

    group('Múltiplas alterações sequenciais (simulação de sessão)', () {
      test('simula uma rodada de combate: dano + gasto de ouro', () async {
        final sheet = await criarFicha(pvMax: 30, pvAtual: 30, ouro: 100);

        // Turno 1: personagem leva 8 de dano
        sheet.pvAtual = (sheet.pvAtual - 8).clamp(0, sheet.pvMax);
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        var data = await lerDadosFichaFirestore(sheet.id);
        expect(data['pvAtual'], 22);

        // Turno 2: usa poção (gasta 25 PO, cura 10 PV)
        sheet.ouro -= 25;
        sheet.pvAtual = (sheet.pvAtual + 10).clamp(0, sheet.pvMax);
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        data = await lerDadosFichaFirestore(sheet.id);
        expect(data['pvAtual'], 30); // clamp ao máximo
        expect(data['ouro'], 75);

        // Turno 3: leva dano crítico de 15
        sheet.pvAtual = (sheet.pvAtual - 15).clamp(0, sheet.pvMax);
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        data = await lerDadosFichaFirestore(sheet.id);
        expect(data['pvAtual'], 15);
      });

      test('simula level up: aumenta atributo, PV e XP', () async {
        final sheet = await criarFicha(
          forca: 14,
          pvMax: 30,
          pvAtual: 30,
          xpAtual: 3000,
        );

        // Level up!
        sheet.level = '4';
        sheet.forca = 15; // +1 FOR de bônus
        sheet.pvMax = 38; // +8 PV (d8 + CON mod)
        sheet.pvAtual = 38; // cura ao subir de nível
        sheet.xpAtual = 0; // XP consumido
        sheet.ba = 3; // BA melhora no nível 4
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['level'], '4');
        expect(data['forca'], 15);
        expect(data['pvMax'], 38);
        expect(data['pvAtual'], 38);
        expect(data['xpAtual'], 0);
        expect(data['ba'], 3);
      });

      test('simula compra de armadura: ouro diminui, CA aumenta', () async {
        final sheet = await criarFicha(ouro: 200, ca: 10);

        // Compra Cota de Malha (150 PO, +5 CA)
        sheet.ouro -= 150;
        sheet.ca = 10 + 5 + Sheet.modificador(sheet.destreza);
        await sheetModel.add(sheet);
        await Future.delayed(Duration.zero);

        final data = await lerDadosFichaFirestore(sheet.id);
        expect(data['ouro'], 50);
        expect(data['ca'], greaterThan(10));
      });
    });

    group('Sincronização em tempo real', () {
      test('mudança externa no Firestore atualiza a lista do SheetModel',
          () async {
        final sheet = await criarFicha(name: 'Hero');
        await Future.delayed(Duration.zero);

        // Simula mudança externa (como outro dispositivo alterando)
        await fakeFirestore.collection('sheets').doc(sheet.id).update({
          'forca': 20,
          'pvAtual': 5,
        });
        await Future.delayed(Duration.zero);

        // O SheetModel deve refletir a mudança via snapshot listener
        final updatedSheet =
            sheetModel.items.firstWhere((s) => s.id == sheet.id);
        expect(updatedSheet.forca, 20);
        expect(updatedSheet.pvAtual, 5);
      });

      test('exclusão da ficha remove da lista do SheetModel', () async {
        final sheet = await criarFicha(name: 'To Delete');
        await Future.delayed(Duration.zero);
        expect(sheetModel.items.length, 1);

        sheetModel.delete(sheet);
        await Future.delayed(Duration.zero);

        expect(sheetModel.items, isEmpty);
      });

      test('fichas de outro jogador não aparecem na lista', () async {
        // Cria ficha pelo SheetModel (uid = player-1)
        await criarFicha(name: 'My Hero');

        // Insere diretamente ficha de outro jogador
        await fakeFirestore.collection('sheets').add({
          'uid': 'player-2',
          'name': 'Enemy Hero',
          'forca': 10,
        });
        await Future.delayed(Duration.zero);

        final nomes = sheetModel.items.map((s) => s.name).toList();
        expect(nomes, contains('My Hero'));
        expect(nomes, isNot(contains('Enemy Hero')));
      });
    });

    group('Round-trip: Sheet model → Firestore → Sheet model', () {
      test('todos os campos sobrevivem ao round-trip completo', () async {
        final original = Sheet(
          name: 'Full Test',
          player: 'Jogador X',
          race: 'Elfo',
          classEspec: 'Mago',
          level: '7',
          align: 'Neutro',
          physicalCharacteristics: 'Alto, cabelos prateados',
          forca: 8,
          destreza: 16,
          constituicao: 10,
          inteligencia: 18,
          sabedoria: 14,
          carisma: 12,
          pvMax: 28,
          pvAtual: 22,
          ca: 12,
          ba: 3,
          jp: 11,
          movimento: 12,
          platina: 3,
          electrum: 7,
          ouro: 150,
          prata: 40,
          cobre: 300,
          xpAtual: 25000,
          notas: 'Mago especialista em fogo',
        );

        await sheetModel.add(original);
        await Future.delayed(Duration.zero);

        // Lê do Firestore bruto
        final data = await lerDadosFichaFirestore(original.id);

        // Reconstrói via fromMap (como o listener faz)
        final restored = Sheet.fromMap(original.id, data);

        expect(restored.name, original.name);
        expect(restored.player, original.player);
        expect(restored.race, original.race);
        expect(restored.classEspec, original.classEspec);
        expect(restored.level, original.level);
        expect(restored.align, original.align);
        expect(restored.physicalCharacteristics, original.physicalCharacteristics);
        expect(restored.forca, original.forca);
        expect(restored.destreza, original.destreza);
        expect(restored.constituicao, original.constituicao);
        expect(restored.inteligencia, original.inteligencia);
        expect(restored.sabedoria, original.sabedoria);
        expect(restored.carisma, original.carisma);
        expect(restored.pvMax, original.pvMax);
        expect(restored.pvAtual, original.pvAtual);
        expect(restored.ca, original.ca);
        expect(restored.ba, original.ba);
        expect(restored.jp, original.jp);
        expect(restored.movimento, original.movimento);
        expect(restored.platina, original.platina);
        expect(restored.electrum, original.electrum);
        expect(restored.ouro, original.ouro);
        expect(restored.prata, original.prata);
        expect(restored.cobre, original.cobre);
        expect(restored.xpAtual, original.xpAtual);
        expect(restored.notas, original.notas);
      });
    });
  });
}
