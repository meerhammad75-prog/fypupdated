import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:news_app/theme/energy_theme.dart';
import 'package:news_app/views/Home.dart';
import 'package:news_app/views/alerts_notifications_screen.dart';
import 'package:news_app/views/login.dart';
import 'package:news_app/views/onboarding_screen.dart';
import 'package:news_app/views/profile_screen.dart';
import 'package:news_app/views/register.dart';
import 'package:news_app/views/sensor_data.dart';
import 'package:news_app/views/settings_screen.dart';
import 'package:news_app/views/splash_screen.dart';
import 'package:news_app/views/terms_and_conditions.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: EnergyTheme.darkTheme,
      home: SplashScreen(),
      routes: {
        AlertsNotificationsScreen.routeName: (_) => const AlertsNotificationsScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
      },
    );
  }
}