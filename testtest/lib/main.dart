import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testtest/login/login_page.dart';
import 'package:testtest/menu/menu.dart'; // Replace with your app's entry point

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the orientation to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    // Ensure proper encoding for the entire application
    utf8.decode(utf8.encode('')); // Initialize UTF-8 encoding
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplicação Flutter', // Tradução do título
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(), // Substitua pela tela inicial do aplicativo
      routes: {
        '/login': (context) => const LoginPage(), // Defina a rota de login
        '/menu': (context) => const MenuScreen(), // Defina a rota do menu
      },
      builder: (context, child) {
        // Ensure text rendering supports special characters
        return Directionality(
          textDirection: TextDirection.ltr,
          child: DefaultTextStyle(
            style: TextStyle(fontFamily: 'Roboto'), // Ensure font supports accents
            child: child!,
          ),
        );
      },
    );
  }
}
