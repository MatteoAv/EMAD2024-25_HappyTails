import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:happy_tails/home.dart';
import '../UserManage/screens/profile_page.dart';
import '../UserManage/screens/settings_page.dart'; // La tua pagina delle impostazioni

// Definisci le tue route qui
class AppRoutes {
  static const String userProfile = '/profile';
  static const String settings = '/settings';
  static const String homePage = "/";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
      return MaterialPageRoute(builder: (_) => const HomePage()
      );
      case userProfile:
        return MaterialPageRoute(
          builder: (_) => const UserProfilePage(),
        );
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const UserProfilePage(),
        );
    }
  }
}
