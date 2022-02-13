import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ods/controllers/character_controller.dart';
import 'package:ods/controllers/sheet_controller.dart';
import 'package:ods/screens/race_selection_screen.dart';
import 'package:provider/provider.dart';

import '../models/sheet_model.dart';

class SheetsScreen extends StatefulWidget {
  const SheetsScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SheetsScreen> createState() => _SheetsScreenState();
}

class _SheetsScreenState extends State<SheetsScreen> {
  late UnmodifiableListView<Sheet> sheets;
  late SheetModel sm;
  bool loading = false;
  int selectedCard = -1;
  Sheet? selectedItem;
  AssetImage logo = const AssetImage("assets/images/logo.png");
  Image background = Image.asset("assets/images/background.png");
  final CharacterController characterController = CharacterController();

  _SheetsScreenState() {
    sm = SheetModel();
    sheets = sm.items;
  }

  Widget _raceImg(sheet) {
    return Stack(
      overflow: Overflow.visible,
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          top: -50,
          right: 50,
          child: Image(
            height: 150,
            image: AssetImage(
              characterController.findOneByRaceName(sheet.race).img,
            ),
          ),
        ),
      ],
    );
  }

  _buildCards(SheetModel sm) {
    List<Widget> cards = [];
    for (var sheet in sm.items) {
      var index = sm.items.indexOf(sheet);
      cards.add(
        GestureDetector(
          onTap: () {
            if (index == selectedCard) {
              setState(() {
                selectedCard = -1;
                selectedItem = null;
              });
            } else {
              setState(() {
                selectedCard = index;
                selectedItem = sheet;
              });
            }
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => AddSheetScreen(
            //       item: sheet,
            //     ),
            //   ),
            // );
          },
          onLongPress: () async {
            return showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Excluir'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text('Deseja excluir a ficha "${sheet.name}"?'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Não'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Sim'),
                      onPressed: () {
                        sm.delete(sheet);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 50, 0, 8),
              child: Card(
                elevation: index == selectedCard ? 10 : 1,
                shadowColor: index == selectedCard
                    ? const Color.fromRGBO(172, 25, 20, 1)
                    : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(38.0),
                  side: const BorderSide(
                    style: BorderStyle.none,
                    color: Color.fromRGBO(172, 25, 20, 1),
                    width: 2,
                  ),
                ),
                semanticContainer: true,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 100,
                    maxWidth: 600,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Stack(
                      overflow: Overflow.visible,
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 150,
                                        maxWidth: 150,
                                        minHeight: 100,
                                        maxHeight: 100,
                                      ),
                                      child: _raceImg(sheet),
                                    ),
                                    Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 150,
                                          maxWidth: 150,
                                          minHeight: 100,
                                          maxHeight: 100,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Nome: ${sheet.name}",
                                            ),
                                            Text(
                                              "Nível: ${sheet.level}",
                                            ),
                                            Text(
                                              "Classe: ${sheet.classEspec}",
                                            ),
                                            Text(
                                              "Raça: ${sheet.race}",
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    cards.add(Container(
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 600),
      margin: const EdgeInsets.fromLTRB(0, 20, 0, 50),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.all(32),
            ),
            overlayColor: MaterialStateProperty.all<Color>(
              const Color.fromRGBO(152, 90, 87, 0.2),
            ),
            foregroundColor: MaterialStateProperty.all<Color>(
              const Color.fromRGBO(172, 25, 20, 1),
            ),
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.white,
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(38.0),
                side: const BorderSide(
                  color: Color.fromRGBO(172, 25, 20, 1),
                  width: 2,
                ),
              ),
            ),
          ),
          child: const Icon(
            Icons.add_circle_outlined,
            size: 50,
          ),
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => AddSheetScreen(
            //       item: Item(),
            //     ),
            //   ),
            // );
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const RaceScreen()),
            // );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RaceSelectionScreen(),
              ),
            );
          },
        ),
      ),
    ));

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SheetModel>(
      builder: (context, sm, child) {
        return Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: false,
                expandedHeight: 150.0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  background: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: background.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                title: const Text(
                  "Personagens",
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: TextButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      child: const Icon(Icons.logout),
                    ),
                  )
                ],
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: loading
                              ? const Text("Carregando...")
                              : _buildCards(sm),
                        ),
                      ),
                    );
                  },
                  childCount: 1,
                ),
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: selectedCard != -1
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FloatingActionButton(
                        onPressed: () async {
                          return showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Excluir'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text(
                                          'Deseja excluir a ficha "${selectedItem?.name}"?'),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Não'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Sim'),
                                    onPressed: () {
                                      sm.delete(selectedItem!);
                                      setState(() {
                                        selectedItem = null;
                                        selectedCard = -1;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Icon(Icons.delete),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Jogar como ${selectedItem?.name}"),
                      )
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }
}
