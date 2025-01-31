import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  static const String _baseUrl = 'http://localhost:3000'; // Cambia con l'IP del tuo server

  // Funzione per creare un PaymentIntent
  static Future<String?> createPaymentIntent(int amount) async {
    try {
      final url = Uri.parse('$_baseUrl/create-payment-intent');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount}), // Importo in centesimi
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['clientSecret']; // Restituisce il client_secret
      } else {
        print('Errore dal server: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Errore nella richiesta al server: $e');
      return null;
    }
  }

  // Recupera i metodi di pagamento di un cliente
  static Future<List<Map<String, dynamic>>> getPaymentMethods(String customerId) async {
    try {
      final url = Uri.parse('$_baseUrl/get-payment-methods');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'customerId': customerId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Errore dal server: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Errore nella richiesta al server: $e');
      return [];
    }
  }

  // Metodo per creare un nuovo cliente su Stripe
  static Future<String?> createCustomer(String email, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/create-customer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'name': name}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['customerId']; // Restituisci l'ID del cliente creato
      } else {
        print('Errore nella creazione del cliente: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Errore nella richiesta: $e');
      return null;
    }
  }

  // Metodo per associare un metodo di pagamento al cliente
  static Future<bool> attachPaymentMethod(String paymentMethodId, String customerId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/attach-payment-method'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'paymentMethodId': paymentMethodId,
          'customerId': customerId,
        }),
      );

      if (response.statusCode == 200) {
        return true; // Metodo di pagamento associato correttamente
      } else {
        print('Errore nell\'associazione del metodo di pagamento: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Errore nella richiesta: $e');
      return false;
    }
  }
}