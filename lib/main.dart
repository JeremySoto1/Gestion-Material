import 'package:flutter/material.dart';
import 'package:gestion_material/views/login.dart';
import 'package:gestion_material/views/principal.dart';
import 'package:gestion_material/views/registro.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Flutter',
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePageLogin(),
        '/principal': (context) => const PrincipalPage(),
        '/registro': (context) => const RegistroPage(),
      },
    );
  }
}
