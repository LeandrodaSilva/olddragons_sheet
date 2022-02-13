import 'package:flutter/material.dart';
import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:ods/screens/profile_screen.dart';
import 'package:ods/screens/sheets_screen.dart';

class Layout extends StatefulWidget {
  const Layout({Key? key}) : super(key: key);

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final int _destinationCount = 2;
  final bool _fabInRail = false;
  final bool _includeBaseDestinationsInMenu = true;
  int _selectedIndex = 0;
  Image logo = Image.asset("assets/images/logo_64.png");

  final _allDestinations = [
    const AdaptiveScaffoldDestination(title: 'Início', icon: Icons.home),
    const AdaptiveScaffoldDestination(title: 'Perfil', icon: Icons.person),
  ];

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
    // User? user = FirebaseAuth.instance.currentUser;
    // Image background = Image.asset("images/background.png");
    return _renderSelected();
    return AdaptiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      destinations: _allDestinations.sublist(0, _destinationCount),
      // appBar: AdaptiveAppBar(
      //   // title: const Text('Fichas'),
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: MouseRegion(
      //         cursor: SystemMouseCursors.click,
      //         child: GestureDetector(
      //           child: CircleAvatar(
      //             radius: 30.0,
      //             backgroundImage:
      //                 NetworkImage(Gravatar(user?.email ?? "").imageUrl()),
      //             backgroundColor: Colors.transparent,
      //           ),
      //           onTap: () {
      //             setState(() {
      //               _showProfile = true;
      //             });
      //           },
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      // drawerHeader: AdaptiveAppBar(
      //   title: Image(
      //     image: logo.image,
      //     width: 50,
      //   ),
      // ),
      // drawerHeader: UserAccountsDrawerHeader(
      //   decoration: BoxDecoration(
      //     image: DecorationImage(
      //       image: background.image,
      //       fit: BoxFit.cover,
      //     ),
      //   ),
      //   accountName: Text(
      //     user?.displayName ?? "",
      //     // style: const TextStyle(color: Colors.black),
      //   ),
      //   accountEmail: Text(
      //     user?.email ?? "",
      //     // style: const TextStyle(color: Colors.black),
      //   ),
      //   // arrowColor: Colors.black,
      //   currentAccountPicture: CircleAvatar(
      //     radius: 30.0,
      //     backgroundImage:
      //     NetworkImage(Gravatar(user?.email ?? "").imageUrl()),
      //     backgroundColor: Colors.transparent,
      //   ),
      // ),
      body: _renderSelected(),
      fabInRail: _fabInRail,
      includeBaseDestinationsInMenu: _includeBaseDestinationsInMenu,
    );
  }
}
