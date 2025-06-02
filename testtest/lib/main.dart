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
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(), // Replace with your app's home screen
      routes: {
        '/login': (context) => const LoginPage(), // Define the login route
        '/menu': (context) => const MenuScreen(), // Define the menu route
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
