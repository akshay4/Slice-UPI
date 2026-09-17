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
  List<BankAccount> _accounts = BankAccount.defaultAccounts();
  late BankAccount _selectedAccount;
  final List<SplitPlan> _history = [];
  List<Contact> _recentPayees = [];
  final String _correctMpin = '1234';
  bool _isReady = false;

  UserProfile? get userProfile => _userProfile;
  bool get isOnboarded => _userProfile != null;
  bool get isReady => _isReady;

  List<BankAccount> get accounts => _accounts;
  BankAccount get selectedAccount => _selectedAccount;
  List<SplitPlan> get history => _history;
  List<Contact> get contacts => _recentPayees;
  String get correctMpin => _correctMpin;

  void _init() async {
    _selectedAccount = _accounts.first;
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

    // Update primary account with personalized user VPA
    _accounts[0] = _accounts[0].copyWith(
      vpa: upiId,
    );
    _selectedAccount = _accounts[0];

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
        _accounts[0] = _accounts[0].copyWith(
          vpa: _userProfile!.upiId,
        );
      }

      // 2. Load Balances
      for (final acc in _accounts) {
        final savedBal = prefs.getDouble('balance_${acc.id}');
        if (savedBal != null) {
          acc.balance = savedBal;
        }
      }

      // 3. Load Recent Payees
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

      for (final acc in _accounts) {
        await prefs.setDouble('balance_${acc.id}', acc.balance);
      }

      final recentsJson = json.encode(_recentPayees.map((c) => c.toMap()).toList());
      await prefs.setString('recent_payees', recentsJson);
    } catch (e) {
      debugPrint('Error saving AppState to prefs: $e');
    }
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
      orElse: () => _selectedAccount,
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
