import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

final algorithm = AesGcm.with256bits();
final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

/// Afleiden van een per-user key van de globale DEK
Future<SecretKey> deriveUserKey(SecretKey globalDEK, String uid) async {
  return await hkdf.deriveKey(
    secretKey: globalDEK,
    info: utf8.encode('user-specific-key'),
    nonce: utf8.encode(uid), // voor oudere/stabiele versies
  );
}

Future<SecretKey?> getUserDEKFromRemoteConfig(String uid) async {
  try {
    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await rc.fetchAndActivate();
    final globalB64 = rc.getString('GLOBAL_DEK');
    if (globalB64.isEmpty) return null;
    final globalBytes = base64Decode(globalB64);
    final globalDEK = SecretKey(globalBytes);
    return await deriveUserKey(globalDEK, uid);
  } catch (_) {
    return null;
  }
}

/// Encrypt een string
Future<String> encryptValue(String value, SecretKey userDEK) async {
  final nonce = algorithm.newNonce(); // 12 bytes random
  final secretBox = await algorithm.encrypt(
    utf8.encode(value),
    secretKey: userDEK,
    nonce: nonce,
  );
  return jsonEncode({
    'nonce': base64Encode(nonce),
    'cipher': base64Encode(secretBox.cipherText),
    'tag': base64Encode(secretBox.mac.bytes),
  });
}

/// Decrypt een string
Future<String> decryptValue(String encrypted, SecretKey userDEK) async {
  final map = jsonDecode(encrypted);
  final nonce = base64Decode(map['nonce']);
  final cipher = base64Decode(map['cipher']);
  final tag = base64Decode(map['tag']);
  final secretBox = SecretBox(cipher, nonce: nonce, mac: Mac(tag));
  final cleartext = await algorithm.decrypt(secretBox, secretKey: userDEK);
  return utf8.decode(cleartext);
}

/// Encrypt een double
Future<String> encryptDouble(double value, SecretKey userDEK) =>
    encryptValue(value.toString(), userDEK);

/// Encrypt een int
Future<String> encryptInt(int value, SecretKey userDEK) =>
    encryptValue(value.toString(), userDEK);
