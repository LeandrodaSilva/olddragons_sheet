import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CustomSignInScreen extends StatelessWidget {
  const CustomSignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomEmailSignInForm(),
    );
  }
}

class CustomEmailSignInForm extends StatefulWidget {
  const CustomEmailSignInForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomEmailSignInFormState();
}

class _CustomEmailSignInFormState extends State<CustomEmailSignInForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Image background = Image.asset("assets/images/background.png");
  AssetImage logo = const AssetImage("assets/images/logo.png");
  String email = '';
  String password = '';
  bool isLoading = false;

  void doLogin() async {
    setState(() {
      isLoading = true;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      setState(() {
        isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      } else {
        print(e.message);
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  }

  void _validateForm() {
    if (_formKey.currentState!.validate()) {
      doLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: background.image,
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 10,
              shadowColor: Color.fromRGBO(172, 25, 20, 1),
              child: Form(
                key: _formKey,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 100, maxWidth: 400),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        child: Image(
                          image: logo,
                          width: 100,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'E-mail',
                          ),
                          initialValue: email,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira o seu e-mail';
                            }
                            return null;
                          },
                          onChanged: (String? val) {
                            setState(() {
                              email = val ?? "";
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Senha',
                          ),
                          initialValue: password,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira a sua senha';
                            }
                            return null;
                          },
                          onChanged: (String? val) {
                            setState(() {
                              password = val ?? "";
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _validateForm,
                          child: const Text('Logar'),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 16.0,
                        ),
                        child:  Text("OU"),
                      ),
                      SignInButton(
                        Buttons.Google,
                        text: "Logar com Google",
                        onPressed: () => signInWithGoogle(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
