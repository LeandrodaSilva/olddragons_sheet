import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ods/screens/custom_signin_screen.dart';
import 'package:ods/widgets/loading_widget.dart';

class AuthMiddleware extends StatelessWidget {
  const AuthMiddleware({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // User is not signed in
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWidget();
        } else if (!snapshot.hasData) {
          return CustomEmailSignInForm();
        }
        // Render your application if authenticated
        return child;
      },
    );
  }
}
