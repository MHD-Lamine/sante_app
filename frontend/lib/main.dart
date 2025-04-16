import 'package:Sante/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:Sante/controllers/home_controller.dart';
import 'package:Sante/screens/home_screen.dart';
import 'package:Sante/screens/login_screen.dart';
import 'package:Sante/screens/profile_screen.dart';
import 'package:Sante/screens/edit_profile_screen.dart';
import 'package:Sante/screens/change_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🌍 Chargement des données de langue française
  await initializeDateFormatting('fr_FR');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SantéTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4F46E5),
        fontFamily: 'Poppins',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        // '/profile': (context) => const ProfileScreen(),
        // '/edit-profile': (context) => const EditProfileScreen(),
        // '/change-password': (context) => const ChangePasswordScreen(),
      },
    );
  }
}
