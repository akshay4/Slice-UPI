import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bank_account.dart';
import '../models/split_plan.dart';
import '../models/tranche.dart';
import '../models/contact.dart';

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._internal();
  AppState._internal() {
    _init();
  }

  List<BankAccount> _accounts = BankAccount.defaultAccounts();
  late BankAccount _selectedAccount;
  final List<SplitPlan> _history = [];
  final List<Contact> _contacts = Contact.recents;
  final String _correctMpin = '1234';

  List<BankAccount> get accounts => _accounts;
  BankAccount get selectedAccount => _selectedAccount;
  List<SplitPlan> get history => _history;
  List<Contact> get contacts => _contacts;
  String get correctMpin => _correctMpin;

  void _init() {
    _selectedAccount = _accounts.first;
    _seedInitialHistory();
    _loadFromPrefs();
  }

  void _seedInitialHistory() {
    if (_history.isNotEmpty) return;

    final initialPlan = SplitPlan(
      id: 'txn_init_01',
      totalAmount: 3500.0,
      payeeVpa: 'merchantstore@oksbi',
      payeeName: 'Suresh Electronics',
      merchantCategory: 'Electronics & Retail',
      note: 'Headphones & Cables',
      account: _accounts.first,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      tranches: [
        Tranche(
          id: 'trn_init_1',
          amount: 1980.0,
          order: 1,
          status: TrancheStatus.success,
          utr: '626099481723',
          rrn: '926018374921',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          latencyMs: 980,
          sourceAccountId: _accounts.first.id,
        ),
        Tranche(
          id: 'trn_init_2',
          amount: 1520.0,
          order: 2,
          status: TrancheStatus.success,
          utr: '626084920194',
          rrn: '926083749102',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          latencyMs: 1040,
          sourceAccountId: _accounts.first.id,
        ),
      ],
      totalSavings: 38.5,
    );

    _history.add(initialPlan);
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final acc in _accounts) {
        final savedBal = prefs.getDouble('balance_${acc.id}');
        if (savedBal != null) {
          acc.balance = savedBal;
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final acc in _accounts) {
        await prefs.setDouble('balance_${acc.id}', acc.balance);
      }
    } catch (_) {}
  }

  void selectAccount(BankAccount account) {
    _selectedAccount = account;
    notifyListeners();
  }

  bool verifyMpin(String mpin) {
    return mpin == _correctMpin;
  }

  void recordSuccessfulPayment(SplitPlan plan) {
    // 1. Deduct real balance from debited account
    final targetAccount = _accounts.firstWhere(
      (a) => a.id == plan.account.id,
      orElse: () => _selectedAccount,
    );

    targetAccount.balance -= plan.totalAmount;
    if (targetAccount.balance < 0) targetAccount.balance = 0;

    // 2. Add to passbook history at top
    _history.insert(0, plan);

    // 3. Persist updated balances
    _saveToPrefs();

    notifyListeners();
  }

  void resetDemoBalances() {
    _accounts = BankAccount.defaultAccounts();
    _selectedAccount = _accounts.first;
    _saveToPrefs();
    notifyListeners();
  }
}
