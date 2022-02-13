import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/sheet_model.dart';
import '../widgets/race_card_widget.dart';

class RaceDetailsScreen extends StatefulWidget {
  final Sheet item;

  const RaceDetailsScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RaceDetailsScreenState();
}

class _RaceDetailsScreenState extends State<RaceDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.race),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 100,
            maxWidth: 600,
          ),
          child: RaceDetailsCard(sheet: widget.item),
        ),
      ),
    );
  }
}
