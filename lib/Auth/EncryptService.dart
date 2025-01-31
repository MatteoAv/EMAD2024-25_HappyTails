import 'package:crypto/crypto.dart'; // Aggiungi questa importazione
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  // Usa una chiave segreta qualsiasi
  final _secretKey = '16characterkey!!'; // La tua chiave segreta

  // Usa SHA-256 per ottenere una chiave di 32 byte
  final _key = encrypt.Key.fromUtf8(sha256.convert(utf8.encode('16characterkey!!')).toString());

  final _iv = encrypt.IV.fromLength(16);

  // Cripta il customer_id
  String encryptCustomerId(String customerId) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(customerId, iv: _iv);
    return encrypted.base64;
  }

  // Decripta il customer_id
  String decryptCustomerId(String encryptedCustomerId) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final decrypted = encrypter.decrypt64(encryptedCustomerId, iv: _iv);
    return decrypted;
  }
}