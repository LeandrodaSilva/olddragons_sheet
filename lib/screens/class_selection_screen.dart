import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ods/controllers/class_controller.dart';
import 'package:ods/models/character_model.dart';
import 'package:ods/screens/add_sheet_screen.dart';
import 'package:ods/screens/race_details_screen.dart';
import 'package:ods/utils/custom_scroll_behavior_util.dart';
import '../models/class_model.dart';
import '../models/sheet_model.dart';

class ClassSelectionScreen extends StatefulWidget {
  final Sheet sheet;
  final Character character;

  const ClassSelectionScreen(
      {Key? key, required this.sheet, required this.character})
      : super(key: key);

  @override
  _ClassSelectionScreenState createState() => _ClassSelectionScreenState();
}

class _ClassSelectionScreenState extends State<ClassSelectionScreen> {
  int _currentIndex = 0;
  final ClassController _classController = ClassController();

  @override
  Widget build(BuildContext context) {
    String raceName = _classController.classes[_currentIndex].name;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Classes"),
      ),
      body: ScrollConfiguration(
        behavior: CustomScrollBehaviorUtil(),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(widget.character.img),
              fit: BoxFit.contain,
            ),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  widget.character.img,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                ClipRRect(
                  // Clip it cleanly.
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      color: Colors.white.withOpacity(0.1),
                      alignment: Alignment.center,
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
                            items: _classController.classes
                                .map(
                                  (Class characterClass) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        var newSheet = widget.sheet;
                                        newSheet.classEspec =
                                            characterClass.name;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddSheetScreen(
                                              item: newSheet,
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
                                            image:
                                                AssetImage(characterClass.img),
                                            fit: BoxFit.contain,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
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
                            children: _classController.classes
                                .map((Class characterClass) {
                              int index = _classController.classes
                                  .indexOf(characterClass);
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
                              widget.character.name + ": " + raceName,
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
