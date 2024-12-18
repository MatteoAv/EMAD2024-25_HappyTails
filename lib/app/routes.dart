import 'package:flutter/material.dart';
import 'package:happy_tails/Auth/auth_repository.dart';
import 'package:happy_tails/Auth/registration.dart';
import 'package:happy_tails/home.dart';
import 'package:happy_tails/screens/ricerca/petsitter_model.dart';
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
  static const String loginPage = "/login";

  static Route<dynamic> generateRoute(RouteSettings route) {
    switch (route.name) {
      case homePage:
      return MaterialPageRoute(builder: (_) => const HomePage()
      );
      case userProfile:
        return MaterialPageRoute(
          builder: (_) => const UserProfilePage(),
        );
      case settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
        );
      case sitterpage:
        final PetSitter petsitter = route.arguments as PetSitter; // Extract arguments
        return MaterialPageRoute(
          builder: (_) => ProfiloPetsitter(petsitter: petsitter),
      );
      case  registrationPage:
        return MaterialPageRoute(
          builder: (_) =>  SignUpPage()
        );
      case loginPage:
        return MaterialPageRoute(
          builder: (_)=> LoginPage()
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
    }
  }
}
