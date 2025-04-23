import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// 📦 Services & Controllers
import 'package:Sante/services/notification_service.dart';
import 'package:Sante/controllers/auth_controller.dart';
import 'package:Sante/controllers/measure_controller.dart';
import 'package:Sante/controllers/user_controller.dart';
import 'package:Sante/controllers/medication_controller.dart';
import 'package:Sante/controllers/appointment_controller.dart';
import 'package:Sante/controllers/health_tip_controller.dart';

// 🖥️ Screens
import 'package:Sante/screens/splash_screen.dart';
import 'package:Sante/screens/login_screen.dart';
import 'package:Sante/screens/register_screen.dart';
import 'package:Sante/screens/home_screen.dart';
import 'package:Sante/screens/appointment_screen.dart';

// 📌 Routes centralisées
import 'package:Sante/constants/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🌍 Initialisation des formats de date pour le français
  await initializeDateFormatting('fr_FR');

  // 🔔 Initialisation du système de notification locale
  // await NotificationService().init(); // Si tu veux réactiver

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => MeasureController()),
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => MedicationController()),
        ChangeNotifierProvider(create: (_) => AppointmentController()),
        ChangeNotifierProvider(create: (_) => HealthTipController()),
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
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.appointments: (_) => const AppointmentScreen(),
      },
    );
  }
}
