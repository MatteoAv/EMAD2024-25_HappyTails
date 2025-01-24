import 'package:flutter/material.dart';
import 'package:happy_tails/Auth/auth_repository.dart';
import 'package:happy_tails/Auth/registration.dart';
import 'package:happy_tails/UserManage/model/pet.dart';
import 'package:happy_tails/UserManage/screens/vetbook_page.dart';
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
  static const String vetPage = "/vetBook";

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
        final objects = route.arguments as List;
        final PetSitter petsitter = objects[0] as PetSitter; // Extract arguments
        final indisp = objects[1];
        final dateRange = objects[2];
        return MaterialPageRoute(
          builder: (_) => ProfiloPetsitter(petsitter: petsitter, indisp : indisp, dateRange: dateRange),
      );
      case  registrationPage:
        return MaterialPageRoute(
          builder: (_) =>  SignUpPage()
        );
      case loginPage:
        return MaterialPageRoute(
          builder: (_)=> LoginPage()
        );
      case vetPage:
      Pet pet = route.arguments as Pet;
      return MaterialPageRoute(builder: (_) => VetBookPage(pet: pet.toMap()));
      default:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );
    }
  }
}
