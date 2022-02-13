import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gravatar/flutter_gravatar.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> {
  bool showUserDetails = false;
  User? user = FirebaseAuth.instance.currentUser;
  Image background = Image.asset("assets/images/background.png");

  Widget _buildDrawerList() {
    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: [
        ListTile(
          leading: const Icon(Icons.home),
          trailing: const Icon(Icons.arrow_forward),
          title: const Text('Fichas'),
          onTap: () {
            // Navigator.pop(context);
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
      ],
    );
  }

  Widget _buildUserDetail() {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('Sobre'),
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/sobre');
            // Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Sair'),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: Column(children: [
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: background.image,
              fit: BoxFit.cover,
            ),
          ),
          accountName: Text(
            user?.displayName ?? "",
            // style: const TextStyle(color: Colors.black),
          ),
          accountEmail: Text(
            user?.email ?? "",
            // style: const TextStyle(color: Colors.black),
          ),
          // arrowColor: Colors.black,
          currentAccountPicture: CircleAvatar(
            radius: 30.0,
            backgroundImage:
                NetworkImage(Gravatar(user?.email ?? "").imageUrl()),
            backgroundColor: Colors.transparent,
          ),
          onDetailsPressed: () {
            setState(() {
              showUserDetails = !showUserDetails;
            });
          },
        ),
        Expanded(
          child: showUserDetails ? _buildUserDetail() : _buildDrawerList(),
        )
      ]),
    );
  }
}
