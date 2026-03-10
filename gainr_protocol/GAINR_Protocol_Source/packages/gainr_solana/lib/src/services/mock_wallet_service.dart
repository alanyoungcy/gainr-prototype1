import 'dart:math';

class MockWalletService {
  Future<Map<String, dynamic>> connect() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Return dummy data
    return {
      'address': 'GNR...${_generateRandomString(4)}',
      'balance_usdc': 1000000.00,
      'balance_bet': 500.00,
      'balance_gainr': 2500.00,
    };
  }

  Future<void> disconnect() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  String _generateRandomString(int length) {
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}
