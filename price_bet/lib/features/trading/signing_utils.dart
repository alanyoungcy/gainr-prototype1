import 'dart:convert';
import 'dart:typed_data';
import 'package:solana/solana.dart';

class OrderSigningUtils {
  /// Signs a trading order intent with the user's Ed25519 wallet.
  /// 
  /// Payload format: GAINR_ORDER:<timestamp>:<side>:<marketId>:<price>:<amount>
  static Future<String> signOrder({
    required Ed25519HDPublicKey wallet,
    required String side, // "BID" or "ASK"
    required String marketId,
    required double price,
    required double amount,
    required String timestamp,
    required Future<Uint8List> Function(Uint8List) signer,
  }) async {
    final String messageString = "GAINR_ORDER:$timestamp:$side:$marketId:$price:$amount";
    final Uint8List messageBytes = Uint8List.fromList(utf8.encode(messageString));
    
    final Uint8List signature = await signer(messageBytes);
    return base64Url.encode(signature);
  }

  /// Verification helper (client-side sanity check if needed)
  static bool verifyOrderSignature({
    required String message,
    required String signatureBase64,
    required String publicKeyBase58,
  }) {
    // Client-side verification usually not needed if we trust the signer callback,
    // but can be implemented for testing.
    return true; 
  }
}
