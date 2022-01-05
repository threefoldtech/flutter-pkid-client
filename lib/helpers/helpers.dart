import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_sodium/flutter_sodium.dart';

String encryptPKid(String json, Uint8List bobPublicKey) {
  List<int> message = utf8.encode(json);
  Uint8List encodedMessage = Uint8List.fromList(message);

  Uint8List publicKey = Sodium.cryptoSignEd25519PkToCurve25519(bobPublicKey);
  Uint8List encryptedData = Sodium.cryptoBoxSeal(encodedMessage, publicKey);
  return base64.encode(encryptedData);
}

String decryptPKid(String cipherText, Uint8List bobPublicKey, Uint8List bobSecretKey) {
  Uint8List cipherEncodedText = base64.decode(cipherText);

  Uint8List publicKey =  Sodium.cryptoSignEd25519PkToCurve25519(bobPublicKey);
  Uint8List secretKey =  Sodium.cryptoSignEd25519SkToCurve25519(bobSecretKey);

  Uint8List decrypted =  Sodium.cryptoBoxSealOpen(cipherEncodedText, publicKey, secretKey);

  String base64DecryptedMessage = new String.fromCharCodes(decrypted);
  return base64DecryptedMessage;
}

Future<Uint8List> sign(String message, Uint8List privateKey) async {
  return Sodium.cryptoSign(Uint8List.fromList(message.codeUnits), privateKey);
}

Future<String> signEncode(String payload, Uint8List secretKey) async {
  return base64Encode(await sign(payload, secretKey));
}

Future<Uint8List> verifyData(String message, Uint8List encodedPublicKey) async {
  Uint8List signedMessage = base64Decode(message);
  return Sodium.cryptoSignOpen(signedMessage, encodedPublicKey);
}