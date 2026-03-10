import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solana/solana.dart';

class WalletConnectProvider extends Notifier<AsyncValue<Ed25519HDPublicKey?>> {
  @override
  AsyncValue<Ed25519HDPublicKey?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> connectPhantom() async {
    state = const AsyncValue.loading();
    try {
      debugPrint('Connecting to Phantom...');
      await Future.delayed(const Duration(seconds: 1));
      
      final pubkey = Ed25519HDPublicKey.fromBase58('GvDMxPzN1sCj7L26YDK2HnMRXEQmQ2aemov8YBtPS7vR');
      state = AsyncValue.data(pubkey);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void disconnect() {
    state = const AsyncValue.data(null);
  }
}

final walletConnectProvider = NotifierProvider<WalletConnectProvider, AsyncValue<Ed25519HDPublicKey?>>(
  WalletConnectProvider.new,
);
