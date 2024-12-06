import 'package:flutter/material.dart';
import 'package:happy_tails/Auth/registration.dart';
import 'package:happy_tails/home.dart';
import 'package:happy_tails/screens/ricerca/petsitter_page.dart';
import '../UserManage/screens/profile_page.dart';
import '../UserManage/screens/settings_page.dart'; // La tua pagina delle impostazioni

// Definisci le tue route qui
class AppRoutes {
  static const String userProfile = '/profile';
  static const String settings = '/settings';
  static const String homePage = "/";
  static const String sitterpage = '/sitter_page';
  static const String registrationPage = "/registration";

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
      case '/sitter_page':
        return MaterialPageRoute(
          builder: (_) => const ProfiloPetsitter(),
        );
      case  '/registration':
      return MaterialPageRoute(builder: (_) =>  SignUpPage());

      default:
        return MaterialPageRoute(
          builder: (_) => const UserProfilePage(),
        );
    }
  }
}
