import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ods/controllers/character_controller.dart';
import 'package:ods/models/character_model.dart';
import 'package:ods/screens/race_details_screen.dart';
import 'package:ods/utils/custom_scroll_behavior_util.dart';
import '../models/sheet_model.dart';

class RaceSelectionScreen extends StatefulWidget {
  const RaceSelectionScreen({Key? key}) : super(key: key);

  @override
  _RaceSelectionScreenState createState() => _RaceSelectionScreenState();
}

class _RaceSelectionScreenState extends State<RaceSelectionScreen> {
  int _currentIndex = 0;
  final CharacterController _characterController = CharacterController();

  @override
  Widget build(BuildContext context) {
    String raceName = _characterController.characters[_currentIndex].name;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Raças"),
      ),
      body: ScrollConfiguration(
        behavior: CustomScrollBehaviorUtil(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height - 200,
                enableInfiniteScroll: false,
                viewportFraction: 1,
                autoPlay: false,
                onPageChanged: (index, reason) {
                  setState(
                    () {
                      _currentIndex = index;
                    },
                  );
                },
              ),
              items: _characterController.characters
                  .map(
                    (Character character) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RaceDetailsScreen(
                                item: Sheet(race: character.name),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30.0),
                          ),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Image(
                              image: AssetImage(character.img),
                              fit: BoxFit.contain,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _characterController.characters.map((Character character) {
                int index = _characterController.characters.indexOf(character);
                return GestureDetector(
                  child: Container(
                    width: 10.0,
                    height: 10.0,
                    margin: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 2.0,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? const Color.fromRGBO(
                              255,
                              0,
                              0,
                              0.8,
                            )
                          : const Color.fromRGBO(
                              187,
                              36,
                              36,
                              0.30196078431372547,
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
              child: Text(
                raceName,
                style: const TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(172, 25, 20, 1),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
