import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final SupabaseClient supabase = Supabase.instance.client;
final Logger logger = Logger();

final petSitterProvider = FutureProvider((ref) async{
  final response = await supabase.rpc("get_petsitter_by_email", params: {'email_input': supabase.auth.currentUser!.email});
  if(response == null){
    return 0;
  }
  return response.first;
});


final totalEarningsProvider = FutureProvider((ref) async {
  final response = await supabase
      .rpc('get_earnings_total', params: {'petsitter_input': ref.watch(petSitterProvider).value!['id']});
  if(response == null){
    return 0.0;
  }    
  return response is int ? response.toDouble() : response;
});


final averageRatingProvider = FutureProvider((ref) async{
  final int petSitterId = ref.watch(petSitterProvider).value['id'];
  final response = await supabase.rpc("get_ratings", params: {'petsitter_input': petSitterId});
  if(response == null){
    return 0.0;
  }
  return response is int ? (response/2).toDouble() : (response/2).toDouble();
});

final oldEarningsProvider = FutureProvider<List<double>>((ref) async {
  final petSitterId = ref.watch(petSitterProvider).value?['id'] ?? 0;
  if (petSitterId == 0) return [];

  // Controlla se c'è già qualcosa in cache
  final cachedData = ref.read(earningsCacheProvider);
  if (cachedData.isNotEmpty) {
    logger.d("cache: $cachedData");
    return cachedData;
  }

  // Altrimenti, controlla in SharedPreferences
  updateEarningsIfNeeded(petSitterId);
  final prefs = await SharedPreferences.getInstance();
  final savedData = prefs.getStringList('earnings')?.map(double.parse).toList();
  if (savedData != null && savedData.isNotEmpty) {
    // Aggiorna la cache con i dati da SharedPreferences
    ref.read(earningsCacheProvider.notifier).state = savedData;
    logger.d("sharedPreference: $savedData");
    return savedData;
  }

  final response = await fetchOldEarnings(petSitterId);

  // Salva i dati in SharedPreferences e aggiorna la cache
  prefs.setStringList('earnings', response.map((e) => e.toString()).toList());
  ref.read(earningsCacheProvider.notifier).state = response;
  logger.d(response);
  return response;
});

Future<List<double>> fetchOldEarnings(int petSitterId) async {
  final List<double> oldEarnings = [];
  final int currentMonth = DateTime.now().month;
  final int currentYear = DateTime.now().year;

  for (int i = 0; i <= 2; i++) {
    final int month = (currentMonth - i - 1) % 12 + 1; // Calcola il mese corretto
    final int year = currentMonth - i <= 0 ? currentYear - 1 : currentYear;

    final beginOld = DateTime(year, month, 1);
    final endOld = DateTime(year, month + 1, 1).subtract(const Duration(days: 1));
    try {
      final response = await supabase.rpc(
        'get_earnings_month',
        params: {
          'petsitter_input': petSitterId,
          'datebegin': beginOld.toIso8601String(),
          'dateend': endOld.toIso8601String(),
        },
      );
      
      if (response == null) {
        oldEarnings.insert(0, 0.0);
      } else {
        oldEarnings.insert(0, response is int ? response.toDouble() : response as double);
      }
    } catch (e) {
      return []; // Aggiungi 0.0 in caso di errore
    }
  }
  return oldEarnings;
}

Future<void> updateEarningsIfNeeded(int petSitterId) async {
  final prefs = await SharedPreferences.getInstance();
  
  // Recupera il mese salvato
  final savedMonth = prefs.getInt('lastUpdatedMonth');
  final currentMonth = DateTime.now().month;

  // Controlla se i dati sono obsoleti
  if (savedMonth != currentMonth) {
    logger.d("I dati sono obsoleti, li sto aggiornando...");
    // Recupera i nuovi guadagni (ad esempio chiamando un'API o un DB)
    final newEarnings = await fetchOldEarnings(petSitterId); // Metodo che chiama l'API o il database
    
    // Aggiorna le SharedPreferences
    await prefs.setStringList('earnings', newEarnings.map((e) => e.toString()).toList());
    await prefs.setInt('lastUpdatedMonth', currentMonth);

    logger.d("Dati aggiornati per il mese corrente.");
  } else {
    logger.d("I dati sono già aggiornati.");
  }
}

final earningsCacheProvider = StateProvider<List<double>>((ref) => []);