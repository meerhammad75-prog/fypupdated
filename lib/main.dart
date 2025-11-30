import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:news_app/services/auth_wrapper.dart';
import 'package:news_app/theme/energy_theme.dart';
import 'package:news_app/theme/theme_manager.dart';
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
  // Load saved theme preference
  await themeManager.loadTheme();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use ListenableBuilder to rebuild when theme changes
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeManager.themeMode,

          // 2. Define Light Theme
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            primarySwatch: Colors.indigo,
            useMaterial3: true,
          ),

          // 3. Define Dark Theme
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            primaryColor: const Color(0xff23ABC3),
            useMaterial3: true,
            // Customize dark cards to be dark grey, not black
            cardTheme: CardTheme(color: Colors.grey[900]),
            appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
          ),
          home: const SplashScreen(),
          routes: {
            AlertsNotificationsScreen.routeName: (_) => const AlertsNotificationsScreen(),
            SettingsScreen.routeName: (_) => const SettingsScreen(),
            ProfileScreen.routeName: (_) => const ProfileScreen(),
          },
        );
      },
    );
  }
}