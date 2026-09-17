import 'dart:async';
import 'dart:math';
import '../models/bank_account.dart';
import '../models/tranche.dart';

class NativeSwitchService {
  static String generateNPCIUTR() {
    final random = Random();
    final buffer = StringBuffer('6260');
    for (int i = 0; i < 8; i++) {
      buffer.write(random.nextInt(10));
    }
    return buffer.toString();
  }

  static String generateRRN() {
    final random = Random();
    final buffer = StringBuffer('9260');
    for (int i = 0; i < 8; i++) {
      buffer.write(random.nextInt(10));
    }
    return buffer.toString();
  }

  static Future<Tranche> executeTranche({
    required Tranche tranche,
    required BankAccount account,
    required String mpin,
  }) async {
    // 1. Balance check
    if (account.balance < tranche.amount) {
      throw Exception('Insufficient funds in ${account.bankName}. Available: ₹${account.balance.toStringAsFixed(2)}');
    }

    // 2. Realistic core-banking latency jitter (900ms - 1300ms)
    final random = Random();
    final latency = 900 + random.nextInt(400);
    await Future.delayed(Duration(milliseconds: latency));

    return tranche.copyWith(
      status: TrancheStatus.success,
      utr: generateNPCIUTR(),
      rrn: generateRRN(),
      timestamp: DateTime.now(),
      latencyMs: latency,
      sourceAccountId: account.id,
    );
  }
}
