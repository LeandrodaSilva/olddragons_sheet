import 'package:flutter/material.dart';
import 'package:ods/controllers/character_controller.dart';
import 'package:ods/models/character_model.dart';
import 'package:ods/screens/class_selection_screen.dart';
import 'dart:math' as math;
import '../models/sheet_model.dart';

class RaceDetailsCard extends StatefulWidget {
  final Sheet sheet;
  late final Character character;

  RaceDetailsCard({Key? key, required this.sheet}) : super(key: key) {
    character = CharacterController().findOneByRaceName(sheet.race);
  }

  @override
  State<StatefulWidget> createState() => _RaceDetailsCardState();
}

class _RaceDetailsCardState extends State<RaceDetailsCard> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height - 130,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.fromLTRB(10, 50, 10, 20),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(196, 196, 196, 0.5),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.rotationY(math.pi),
          child: Image(
            height: 400,
            image: AssetImage(widget.character.img),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height - 130,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
          margin: const EdgeInsets.fromLTRB(30, 180, 30, 50),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(196, 196, 196, 0.9),
            borderRadius: BorderRadius.circular(30),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                  widget.character.historyDescription,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          bottom: 25,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassSelectionScreen(
                      sheet: widget.sheet,
                      character: widget.character,
                    ),
                  ),
                );
              },
              style: ButtonStyle(
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
              child: const Text("ESCOLHER"),
            ),
          ),
        ),
      ],
    );
  }
}
