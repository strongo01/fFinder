import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

final algorithm = AesGcm.with256bits(); // AES-GCM met 256-bit sleutel
final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32); // HKDF met SHA-256

/// Afleiden van een per-user key van de globale DEK
Future<SecretKey> deriveUserKey(SecretKey globalDEK, String uid) async {
  return await hkdf.deriveKey( // afleiden met HKDF
    secretKey: globalDEK, // globale DEK als input sleutel
    info: utf8.encode('user-specific-key'), // contextuele info
    nonce: utf8.encode(uid), // voor oudere/stabiele versies
  );
}

Future<SecretKey?> getUserDEKFromRemoteConfig(String uid) async {
  try {
    final rc = FirebaseRemoteConfig.instance; // instantie van Remote Config
    await rc.setConfigSettings(RemoteConfigSettings( // configuratie-instellingen
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await rc.fetchAndActivate(); // haal de laatste config op en activeer deze
    final globalB64 = rc.getString('GLOBAL_DEK'); // haal de globale DEK op
    if (globalB64.isEmpty) return null; // als leeg, return null
    final globalBytes = base64Decode(globalB64); // decodeer van base64
    final globalDEK = SecretKey(globalBytes); // maak SecretKey aan
    return await deriveUserKey(globalDEK, uid); // leid per-user sleutel af
  } catch (_) {
    return null;
  }
}

/// Encrypt een string
Future<String> encryptValue(String value, SecretKey userDEK) async { // encrypt met per-user DEK
  final nonce = algorithm.newNonce(); // 12 bytes random
  final secretBox = await algorithm.encrypt( // encryptie
    utf8.encode(value),
    secretKey: userDEK,
    nonce: nonce, // nonce gebruiken
  ); 
  return jsonEncode({ // encodeer als JSON
    'nonce': base64Encode(nonce), // nonce in base64
    'cipher': base64Encode(secretBox.cipherText),
    'tag': base64Encode(secretBox.mac.bytes),
  });
}

/// Decrypt een string
Future<String> decryptValue(String encrypted, SecretKey userDEK) async { // decrypt met per-user DEK
  final map = jsonDecode(encrypted); // decodeer JSON
  final nonce = base64Decode(map['nonce']); // decodeer nonce
  final cipher = base64Decode(map['cipher']); // decodeer cipher text
  final tag = base64Decode(map['tag']); // decodeer MAC tag
  final secretBox = SecretBox(cipher, nonce: nonce, mac: Mac(tag)); // maak SecretBox aan
  final cleartext = await algorithm.decrypt(secretBox, secretKey: userDEK); // decryptie
  return utf8.decode(cleartext); // decodeer naar string
}

/// Encrypt een double
Future<String> encryptDouble(double value, SecretKey userDEK) =>
    encryptValue(value.toString(), userDEK);  // converteer naar string en encrypt

/// Encrypt een int
Future<String> encryptInt(int value, SecretKey userDEK) =>
    encryptValue(value.toString(), userDEK); // converteer naar string en encrypt

/// Decrypt een double
Future<double> decryptDouble(dynamic encrypted, SecretKey userDEK) async { // dynamic voor null, num of String
  if (encrypted == null) return 0.0;
  if (encrypted is num) return encrypted.toDouble();
  if (encrypted is String) {
    final decryptedStr = await decryptValue(encrypted, userDEK);
    return double.tryParse(decryptedStr) ?? 0.0;
  }
  return 0.0;
}