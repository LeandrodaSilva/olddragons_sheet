import 'package:flutter/material.dart';
import 'package:flutter_gravatar/flutter_gravatar.dart';
import 'package:ods/services/auth_service.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30.0,
                backgroundImage:
                    NetworkImage(Gravatar(user?.email ?? "").imageUrl()),
                backgroundColor: Colors.transparent,
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Text(user?.email ?? ""),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () async {
                    await authService.signOut();
                  },
                  child: const Text("Sair"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
