import 'bank_account.dart';
import 'tranche.dart';

class SplitPlan {
  final String id;
  final double totalAmount;
  final String payeeVpa;
  final String payeeName;
  final String merchantCategory;
  final String note;
  final BankAccount account;
  final DateTime createdAt;
  final List<Tranche> tranches;
  final double totalSavings;
  final bool antiVelocityJitter;

  const SplitPlan({
    required this.id,
    required this.totalAmount,
    required this.payeeVpa,
    required this.payeeName,
    this.merchantCategory = 'Retail',
    this.note = '',
    required this.account,
    required this.createdAt,
    required this.tranches,
    required this.totalSavings,
    this.antiVelocityJitter = true,
  });
}
