import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bank_account.dart';
import '../models/split_plan.dart';
import '../models/contact.dart';
import '../models/user_profile.dart';

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._internal();
  AppState._internal() {
    _init();
  }

  UserProfile? _userProfile;
  List<BankAccount> _accounts = [];
  BankAccount? _selectedAccount;
  final List<SplitPlan> _history = [];
  List<Contact> _recentPayees = [];
  final String _correctMpin = '1234';
  bool _isReady = false;

  UserProfile? get userProfile => _userProfile;
  bool get isOnboarded => _userProfile != null;
  bool get isReady => _isReady;

  List<BankAccount> get accounts => _accounts;
  BankAccount get selectedAccount {
    if (_accounts.isEmpty) {
      return BankAccount(
        id: 'acc_primary',
        bankName: 'UPI Primary Account',
        accountNumberMasked: '•••• ----',
        ifsc: 'UPI0000001',
        balance: 0.0,
        vpa: _userProfile?.upiId ?? '',
        isPrimary: true,
      );
    }
    return _selectedAccount ?? _accounts.first;
  }
  List<SplitPlan> get history => _history;
  List<Contact> get contacts => _recentPayees;
  String get correctMpin => _correctMpin;

  void _init() async {
    await _loadFromPrefs();
    _isReady = true;
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String phone,
    required String name,
    String? businessName,
    bool isMerchant = false,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final upiId = '$cleanPhone@sliceupi';

    final profile = UserProfile(
      phone: cleanPhone,
      name: name.trim(),
      upiId: upiId,
      businessName: (businessName ?? '').trim(),
      isMerchant: isMerchant,
    );

    _userProfile = profile;

    // Discover real bank accounts registered with this phone number
    _accounts = BankAccount.discoverAccountsForPhone(cleanPhone, name.trim());
    _selectedAccount = _accounts.first;

    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Load User Profile
      final profileStr = prefs.getString('user_profile');
      if (profileStr != null && profileStr.isNotEmpty) {
        _userProfile = UserProfile.fromJson(profileStr);
      }

      // 2. Load Bank Accounts
      final accountsStr = prefs.getString('bank_accounts');
      if (accountsStr != null && accountsStr.isNotEmpty) {
        final List<dynamic> decoded = json.decode(accountsStr);
        _accounts = decoded.map((e) => BankAccount.fromMap(e)).toList();
      } else if (_userProfile != null) {
        _accounts = BankAccount.discoverAccountsForPhone(
          _userProfile!.phone,
          _userProfile!.name,
        );
      }

      if (_accounts.isNotEmpty) {
        _selectedAccount = _accounts.firstWhere(
          (a) => a.isPrimary,
          orElse: () => _accounts.first,
        );
      }

      // 3. Load Balances
      for (final acc in _accounts) {
        final savedBal = prefs.getDouble('balance_${acc.id}');
        if (savedBal != null) {
          acc.balance = savedBal;
        }
      }

      // 4. Load Recent Payees
      final recentsStr = prefs.getString('recent_payees');
      if (recentsStr != null && recentsStr.isNotEmpty) {
        final List<dynamic> decoded = json.decode(recentsStr);
        _recentPayees = decoded.map((e) => Contact.fromMap(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading AppState from prefs: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_userProfile != null) {
        await prefs.setString('user_profile', _userProfile!.toJson());
      }

      final accountsJson = json.encode(_accounts.map((a) => a.toMap()).toList());
      await prefs.setString('bank_accounts', accountsJson);

      for (final acc in _accounts) {
        await prefs.setDouble('balance_${acc.id}', acc.balance);
      }

      final recentsJson = json.encode(_recentPayees.map((c) => c.toMap()).toList());
      await prefs.setString('recent_payees', recentsJson);
    } catch (e) {
      debugPrint('Error saving AppState to prefs: $e');
    }
  }

  Future<BankAccount> linkAccountFromBank(SupportedBank bank) async {
    final phone = _userProfile?.phone ?? '';
    final newAcc = BankAccount.discoverAccountForBank(bank, phone);
    _accounts.add(newAcc);
    await _saveToPrefs();
    notifyListeners();
    return newAcc;
  }

  void addOrUpdateRecentPayee(Contact contact) {
    // Remove duplicate if exists
    _recentPayees.removeWhere((c) => c.vpa.toLowerCase() == contact.vpa.toLowerCase());
    // Insert at top of list
    _recentPayees.insert(0, contact);
    // Keep max 15 recent payees
    if (_recentPayees.length > 15) {
      _recentPayees = _recentPayees.sublist(0, 15);
    }
    _saveToPrefs();
    notifyListeners();
  }

  void selectAccount(BankAccount account) {
    _selectedAccount = account;
    notifyListeners();
  }

  bool verifyMpin(String mpin) {
    return mpin == _correctMpin;
  }

  void recordSuccessfulPayment(SplitPlan plan) {
    // 1. Deduct balance from debited account
    final targetAccount = _accounts.firstWhere(
      (a) => a.id == plan.account.id,
      orElse: () => selectedAccount,
    );

    targetAccount.balance -= plan.totalAmount;
    if (targetAccount.balance < 0) targetAccount.balance = 0;

    // 2. Add to passbook history at top
    _history.insert(0, plan);

    // 3. Dynamically add/promote payee to Recent Payees
    final parts = plan.payeeName.trim().split(RegExp(r'\s+'));
    String initials = '';
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    final colors = [
      0xFF0B57D0,
      0xFF006241,
      0xFF7C3AED,
      0xFFE11D48,
      0xFF0284C7,
      0xFFD97706,
    ];
    final color = colors[plan.payeeName.hashCode.abs() % colors.length];

    addOrUpdateRecentPayee(
      Contact(
        id: 'c_${DateTime.now().millisecondsSinceEpoch}',
        name: plan.payeeName,
        vpa: plan.payeeVpa,
        initials: initials.isEmpty ? 'UP' : initials,
        category: plan.merchantCategory,
        avatarColor: color,
      ),
    );

    // 4. Persist updated balances and recents
    _saveToPrefs();
    notifyListeners();
  }

  void addAccount(BankAccount account) {
    _accounts.add(account);
    _selectedAccount = account;
    _saveToPrefs();
    notifyListeners();
  }

  void resetDemoBalances() {
    _accounts = BankAccount.defaultAccounts();
    if (_userProfile != null) {
      _accounts[0] = _accounts[0].copyWith(vpa: _userProfile!.upiId);
    }
    _selectedAccount = _accounts.first;
    _saveToPrefs();
    notifyListeners();
  }
}
