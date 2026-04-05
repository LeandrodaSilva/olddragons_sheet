import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ods/constants/app_colors.dart';
import 'package:ods/services/auth_service.dart';
import 'package:provider/provider.dart';

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
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithCredential(credential);
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo acima da moldura
              Image(
                image: logo,
                width: 160,
              ),
              // Moldura com fundo e botão dentro
              Container(
                constraints: const BoxConstraints(maxWidth: 520),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Moldura
                    Image(
                      image: frame,
                      fit: BoxFit.contain,
                      width: 520,
                    ),
                    // Fundo marrom + botão dentro da moldura
                    Positioned.fill(
                      left: 55,
                      right: 55,
                      top: 45,
                      bottom: 55,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.brownDark,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: signInWithGoogle,
                                icon: const Text(
                                  'G',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.goldAccent,
                                  ),
                                ),
                                label: const Text(
                                  'Entrar com Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.goldLight,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.brownButton,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: const BorderSide(
                                      color: AppColors.goldAccent,
                                      width: 1.5,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
