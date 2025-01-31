import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:happy_tails/UserManage/repositories/local_database.dart';
import 'package:happy_tails/app/bottom_navbar.dart';
import 'package:happy_tails/app/routes.dart';
import 'package:happy_tails/stripe_backend/StartServer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();
 
  await Supabase.initialize(
    url: 'https://nopqmogzpjhqntzristy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5vcHFtb2d6cGpocW50enJpc3R5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI4MDY4MzAsImV4cCI6MjA0ODM4MjgzMH0.tgm20B3Xgq26fgGBdK0Xy-Yz5_qVy0yW83fHcuqucb8',
  );

  // Configura la chiave pubblica di Stripe
  Stripe.publishableKey = "pk_test_51QnI64HHgxdC6vSSMHcpNZYlfGNYojbojvLWrJVgUX8Uoy1IvuKOTNHUfeJcZw6OJqIt3xxwJyR5sEVuPRsMmyn7000Kl0wG14";
  final serverController = ServerController();
  //serverController.startServer();
  //await LocalDatabase.instance.deleteDatabaseFile();
  await LocalDatabase.instance.database;
  runApp(const ProviderScope(child: MyApp()));
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'HappyTails',
      theme: ThemeData(
        navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(
            color: Colors.orange, // Colore per l'elemento selezionato
            fontWeight: FontWeight.bold,
            fontSize: 14,
          );
        }
        return const TextStyle(
          color: Colors.black, // Colore per gli elementi non selezionati
          fontSize: 12,
        );
        })
        ),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
      ),
      menuStyle: MenuStyle(
        elevation: MaterialStateProperty.all(4),
        backgroundColor: MaterialStateProperty.all(
          Theme.of(context).colorScheme.surface,
        ),
      ),
      ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MainScaffold(), // Separate stateful navigation logic
      initialRoute: AppRoutes.homePage,
      onGenerateRoute: AppRoutes.generateRoute, // Usa il routing centralizzato
    );
  }
}







