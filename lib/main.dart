import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ods/controllers/sheet_controller.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) => {
        runApp(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => SheetModel()),
            ],
            child: const App(),
          ),
        ),
      });
}
