import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  Image background = Image.asset("assets/images/background.png");
  AssetImage logo = const AssetImage("assets/images/logo.png");
  AssetImage frame = const AssetImage("assets/images/frame.png");

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e, stackTrace) {
      debugPrint('Google Sign-In Error: $e');
      debugPrint('Stack: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.runtimeType} - $e'),
          duration: const Duration(seconds: 10),
        ),
      );
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo acima da moldura
                Image(
                  image: logo,
                  width: 140,
                ),
                const SizedBox(height: 8),
                const Text(
                  'OldDragons Sheet',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 10,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Moldura com botão dentro
                Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Moldura
                      Image(
                        image: frame,
                        fit: BoxFit.contain,
                      ),
                      // Conteúdo dentro da moldura
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 50),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Sua ficha de RPG digital',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade300,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: signInWithGoogle,
                                icon: const Text(
                                  'G',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4285F4),
                                  ),
                                ),
                                label: const Text(
                                  'Entrar com Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF333333),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
