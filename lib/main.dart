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
  // ignore: unused_local_variable
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










/*
findProviders(Directory("lib"));

}

void findProviders(Directory dir) {
  dir.listSync().forEach((entity) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      final classMatches = RegExp(r'class\s+(\w+)\b').allMatches(content);
      final providerMatches = RegExp(r'class\s+(\w+Provider)\b').allMatches(content);
      print('File: ${entity.path}');
      print('Classes: ${classMatches.map((m) => m.group(1)).toList()}');
      print('Providers: ${providerMatches.map((m) => m.group(1)).toList()}');
    } else if (entity is Directory) {
      findProviders(entity); // Recurse into subdirectories
    }
  });
}



Restarted application in 888ms.
flutter: supabase.supabase_flutter: INFO: ***** Supabase init completed *****
flutter: File: lib/stripe_backend/StartServer.dart
flutter: Classes: [ServerController]
flutter: Providers: []
flutter: File: lib/home.dart
flutter: Classes: [HomePage, _HomePageState]
flutter: Providers: []
flutter: File: lib/app/routes.dart
flutter: Classes: [AppRoutes]
flutter: Providers: []
flutter: File: lib/app/tema.dart
flutter: Classes: []
flutter: Providers: []
flutter: File: lib/app/navbarProvider.dart
flutter: Classes: [PageManager]
flutter: Providers: []
flutter: File: lib/app/bottom_navbar.dart
flutter: Classes: [MainScaffold, _MainScaffoldState]
flutter: Providers: []
flutter: File: lib/chat/chat_provider.dart
flutter: Classes: [ChatNotifier]
flutter: Providers: []
flutter: File: lib/chat/clientList.dart
flutter: Classes: [ClientListPage]
flutter: Providers: []
flutter: File: lib/chat/chatRepository.dart
flutter: Classes: [ChatRepository]
flutter: Providers: []
flutter: File: lib/chat/petSitterList.dart
flutter: Classes: [UserListPage]
flutter: Providers: []
flutter: File: lib/chat/chat.dart
flutter: Classes: [ChatPage, _MessageBar, _MessageBarState, _MessageList, _ChatBubble, _HeaderMenuButton, _BookingHeader, _AnimatedStatusChip, _AnimatedStatusChipState, _InteractiveTimeline, _AnimatedProgressIndicator, _AnimatedProgressIndicatorState, _TimelineStep, _PriceBadge, _PulsingDot, _PulsingDotState, _HoverIconButton, _HoverIconButtonState, _DetailTile]
flutter: Providers: []
flutter: File: lib/chat/message_model.dart
flutter: Classes: [Message]
flutter: Providers: []
flutter: File: lib/chat/chatWithClient.dart
flutter: Classes: [ChatWithClientPage, _MessageBar, _MessageBarState, _MessageList, _ChatBubble, _HeaderMenuButton, PetsitterBookingCard, _PetsitterBookingCardState, name, _InfoTile]
flutter: Providers: []
flutter: File: lib/Auth/auth_repository.dart
flutter: Classes: [LoginPage]
flutter: Providers: []
flutter: File: lib/Auth/registration.dart
flutter: Classes: [SignUpPage, _SignUpPageState]
flutter: Providers: []
flutter: File: lib/Auth/EncryptService.dart
flutter: Classes: [EncryptionService]
flutter: Providers: []
flutter: File: lib/profilo.dart
flutter: Classes: [ProfiloPage]
flutter: Providers: []
flutter: File: lib/homeProvider/providers.dart
flutter: Classes: []
flutter: Providers: []
flutter: File: lib/screens/ricerca/risultati_provider.dart
flutter: Classes: []
flutter: Providers: []
flutter: File: lib/screens/ricerca/risultato_card.dart
flutter: Classes: [VerticalCard, _PetTypeChip]
flutter: Providers: []
flutter: File: lib/screens/ricerca/risultati_repository.dart
flutter: Classes: [SearchRepository]
flutter: Providers: []
flutter: File: lib/screens/ricerca/risultatiricerca_pagina.dart
flutter: Classes: [RisultatiCercaPage, _PremiumDropdown, _RisultatiCercaPageState]
flutter: Providers: []
flutter: File: lib/screens/ricerca/distanza_2citta_formula.dart
flutter: Classes: [HaversineCalculator]
flutter: Providers: []
flutter: File: lib/screens/ricerca/locations.dart
flutter: Classes: []
flutter: Providers: []
flutter: File: lib/screens/ricerca/petsitter_page.dart
flutter: Classes: [ProfiloPetsitter, _ProfiloPetsitterState]
flutter: Providers: []
flutter: File: lib/screens/ricerca/petsitter_model.dart
flutter: Classes: [PetSitter]
flutter: Providers: []
flutter: File: lib/main.dart
flutter: Classes: [MyApp]
flutter: Providers: []
flutter: File: lib/payment_service.dart
flutter: Classes: [PaymentService]
flutter: Providers: []
flutter: File: lib/widgetHomePage/PieChart.dart
flutter: Classes: [PieChartWidget]
flutter: Providers: []
flutter: File: lib/widgetHomePage/LineChart.dart
flutter: Classes: [LineChartWidget]
flutter: Providers: []
flutter: File: lib/widgetHomePage/LegendChart.dart
flutter: Classes: [LegendWidget]
flutter: Providers: []
flutter: File: lib/UserManage/providers/profile_providers.dart
flutter: Classes: [UserNotifier, PetNotifier, AddPetStateNotifier, AddPetState, BookNotifier, BookingService]
flutter: Providers: []
flutter: File: lib/UserManage/providers/managePetSitter.dart
flutter: Classes: [ManagePetsState, ManagePetsNotifier]
flutter: Providers: []
flutter: File: lib/UserManage/repositories/local_database.dart
flutter: Classes: [LocalDatabase]
flutter: Providers: []
flutter: File: lib/UserManage/screens/paymentMethods.dart
flutter: Classes: [PaymentMethodsPage, _PaymentMethodsPageState]
flutter: Providers: []
flutter: File: lib/UserManage/screens/vetbook_page.dart
flutter: Classes: [VetBookPage, _VetBookPageState]
flutter: Providers: []
flutter: File: lib/UserManage/screens/settings_page.dart
flutter: Classes: [SettingsPage, _SettingsPageState, AddPetDialog]
flutter: Providers: []
flutter: File: lib/UserManage/screens/profile_page.dart
flutter: Classes: [UserProfilePage, AddPetDialog]
flutter: Providers: []
flutter: File: lib/UserManage/model/user.dart
flutter: Classes: [User]
flutter: Providers: []
flutter: File: lib/UserManage/model/pet.dart
flutter: Classes: [Pet]
flutter: Providers: []
flutter: File: lib/UserManage/model/booking.dart
flutter: Classes: [Booking]
flutter: Providers: []
flutter: File: lib/UserManage/widgets/expandable_button.dart
flutter: Classes: [ExpandableButton]
flutter: Providers: []
flutter: File: lib/UserManage/widgets/AddCardFormModal.dart
flutter: Classes: [AddCardFormModal, _AddCardFormModalState]
flutter: Providers: []
flutter: File: lib/UserManage/widgets/PetCard.dart
flutter: Classes: [PetCard]
flutter: Providers: []
flutter: File: lib/UserManage/widgets/bookingCard.dart
flutter: Classes: [bookingCard, _BookingCardState]
flutter: Providers: []
flutter: File: lib/header.dart
flutter: Classes: [Header, SliverAppBarDelegate]
flutter: Providers: []
flutter: File: lib/homePagePetSitter.dart
flutter: Classes: [HomePagePetSitter]
flutter: Providers: []
flutter: File: lib/prenotazioni.dart
flutter: Classes: [PrenotazioniPage]
flutter: Providers: []
Reloaded 1 of 1851 libraries in 601ms (compile: 59 ms, reload: 362 ms, reassemble: 111 ms).
Reloaded 1 of 1851 libraries in 582ms (compile: 85 ms, reload: 391 ms, reassemble: 36 ms).



*/