import 'package:flutter/material.dart';
import 'package:ods/screens/profile_screen.dart';
import 'package:ods/screens/sheets_screen.dart';

class Layout extends StatefulWidget {
  const Layout({Key? key}) : super(key: key);

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int _selectedIndex = 0;

  Widget _renderSelected() {
    switch (_selectedIndex) {
      case 1:
        return const ProfileScreen();
      case 0:
      default:
        return const SheetsScreen(title: 'OldDragons Sheet');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _renderSelected();
  }
}
