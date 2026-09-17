import 'dart:math';
import '../models/bank_account.dart';
import '../models/tranche.dart';
import '../models/split_plan.dart';

class SlicingEngine {
  static const double npciThreshold = 2000.0;
  static const double maxTrancheAmount = 1990.0;
  static const double surchargeRate = 0.011; // 1.1% PPI surcharge

  static double calculateSavings(double amount) {
    if (amount <= npciThreshold) return 0.0;
    return amount * surchargeRate;
  }

  static List<double> calculateTranches(double totalAmount, {bool enableJitter = true}) {
    if (totalAmount <= 0) return [];

    if (totalAmount <= npciThreshold) {
      return [totalAmount];
    }

    final int trancheCount = (totalAmount / maxTrancheAmount).ceil();
    final double baseAmount = (totalAmount / trancheCount).floorToDouble();
    final Random random = Random();

    List<double> tranches = [];
    double remainingAmount = totalAmount;

    for (int i = 0; i < trancheCount; i++) {
      if (i == trancheCount - 1) {
        tranches.add(remainingAmount);
      } else {
        // Anti-velocity jitter offset: between -30 and +30 to break AML structuring detection
        double jitter = 0;
        if (enableJitter) {
          jitter = ((random.nextInt(61) - 30) / 10).round() * 10.0;
        }

        double tranche = baseAmount + jitter;
        // Keep within safe boundaries
        if (tranche > maxTrancheAmount) tranche = maxTrancheAmount;
        if (tranche < 500) tranche = 500;
        if (tranche >= remainingAmount) tranche = remainingAmount - 100;

        tranches.add(tranche);
        remainingAmount -= tranche;
      }
    }

    return tranches;
  }

  static SplitPlan createPlan({
    required double totalAmount,
    required String payeeVpa,
    required String payeeName,
    required BankAccount account,
    String note = '',
    String merchantCategory = 'Retail',
  }) {
    final trancheAmounts = calculateTranches(totalAmount, enableJitter: true);
    final tranches = trancheAmounts.asMap().entries.map((entry) {
      return Tranche(
        id: 'trn_${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
        amount: entry.value,
        order: entry.key + 1,
        sourceAccountId: account.id,
      );
    }).toList();

    return SplitPlan(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      totalAmount: totalAmount,
      payeeVpa: payeeVpa,
      payeeName: payeeName,
      merchantCategory: merchantCategory,
      note: note,
      account: account,
      createdAt: DateTime.now(),
      tranches: tranches,
      totalSavings: calculateSavings(totalAmount),
      antiVelocityJitter: true,
    );
  }
}
