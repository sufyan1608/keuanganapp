import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pencatatan Keuangan',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: LoginScreen(), // Awal aplikasi ke login
    );
  }
}
