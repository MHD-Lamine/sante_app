
import 'package:Sante/screens/edit_profile_screen.dart';
import 'package:Sante/screens/login_screen.dart';
import 'package:Sante/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:Sante/screens/change_password_screen.dart';
 // à créer

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suivi Santé',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(), // 
        '/edit-profile': (context) => const EditProfileScreen(),  // 
        '/change-password': (context) => const ChangePasswordScreen(),
      },
    );
  }
}
