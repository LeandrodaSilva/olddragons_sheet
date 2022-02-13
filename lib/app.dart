import 'package:flutter/material.dart';
import 'package:ods/middlewares/auth_middleware.dart';
import 'package:ods/widgets/layout_widget.dart';
import 'package:ods/utils/color_tools_util.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OldDragons Sheet',
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: ColorTools.createMaterialColor(
          const Color.fromRGBO(172, 25, 20, 1),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color.fromRGBO(172, 25, 20, 1),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.all(24),
            ),
            backgroundColor: MaterialStateProperty.all<Color>(
              const Color.fromRGBO(172, 25, 20, 1),
            ),
            overlayColor: MaterialStateProperty.all<Color>(
              Colors.redAccent,
            ),
            foregroundColor: MaterialStateProperty.all<Color>(
              Colors.white,
            ),
          ),
        ),
        cardTheme: const CardTheme(elevation: 3),
      ),
      home: const AuthMiddleware(
        child: Layout(),
      ),
    );
  }
}
