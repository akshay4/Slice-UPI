import 'dart:convert';

class SupportedBank {
  final String code;
  final String name;
  final String shortName;
  final String ifscPrefix;
  final int brandColor;
  final String upiHandle;

  const SupportedBank({
    required this.code,
    required this.name,
    required this.shortName,
    required this.ifscPrefix,
    required this.brandColor,
    required this.upiHandle,
  });

  static const List<SupportedBank> allBanks = [
    SupportedBank(
      code: 'SBI',
      name: 'State Bank of India',
      shortName: 'SBI',
      ifscPrefix: 'SBIN0004567',
      brandColor: 0xFF1C3F94,
      upiHandle: 'oksbi',
    ),
    SupportedBank(
      code: 'HDFC',
      name: 'HDFC Bank',
      shortName: 'HDFC',
      ifscPrefix: 'HDFC0001234',
      brandColor: 0xFF004C8F,
      upiHandle: 'okhdfcbank',
    ),
    SupportedBank(
      code: 'ICICI',
      name: 'ICICI Bank',
      shortName: 'ICICI',
      ifscPrefix: 'ICIC0007890',
      brandColor: 0xFFB02A30,
      upiHandle: 'okicici',
    ),
    SupportedBank(
      code: 'AXIS',
      name: 'Axis Bank',
      shortName: 'AXIS',
      ifscPrefix: 'UTIB0001234',
      brandColor: 0xFF97144D,
      upiHandle: 'okaxis',
    ),
    SupportedBank(
      code: 'KOTAK',
      name: 'Kotak Mahindra Bank',
      shortName: 'KOTAK',
      ifscPrefix: 'KKBK0001234',
      brandColor: 0xFFED1C24,
      upiHandle: 'kotak',
    ),
    SupportedBank(
      code: 'PNB',
      name: 'Punjab National Bank',
      shortName: 'PNB',
      ifscPrefix: 'PUNB0001234',
      brandColor: 0xFFA20C32,
      upiHandle: 'pnb',
    ),
    SupportedBank(
      code: 'BOB',
      name: 'Bank of Baroda',
      shortName: 'BOB',
      ifscPrefix: 'BARB0001234',
      brandColor: 0xFFF26522,
      upiHandle: 'barodampay',
    ),
    SupportedBank(
      code: 'CANARA',
      name: 'Canara Bank',
      shortName: 'CANARA',
      ifscPrefix: 'CNRB0001234',
      brandColor: 0xFF0091DA,
      upiHandle: 'cnrb',
    ),
    SupportedBank(
      code: 'INDUSIND',
      name: 'IndusInd Bank',
      shortName: 'INDUS',
      ifscPrefix: 'INDB0001234',
      brandColor: 0xFF831B2A,
      upiHandle: 'indus',
    ),
    SupportedBank(
      code: 'FEDERAL',
      name: 'Federal Bank',
      shortName: 'FED',
      ifscPrefix: 'FDRL0001234',
      brandColor: 0xFF003087,
      upiHandle: 'federal',
    ),
    SupportedBank(
      code: 'UNION',
      name: 'Union Bank of India',
      shortName: 'UBI',
      ifscPrefix: 'UBIN0001234',
      brandColor: 0xFF024487,
      upiHandle: 'unionbank',
    ),
    SupportedBank(
      code: 'YES',
      name: 'Yes Bank',
      shortName: 'YES',
      ifscPrefix: 'YESB0001234',
      brandColor: 0xFF004E98,
      upiHandle: 'yesbank',
    ),
  ];
}

class BankAccount {
  final String id;
  final String bankName;
  final String accountNumberMasked;
  final String ifsc;
  double balance;
  final String vpa;
  final bool isPrimary;
  final int brandColor;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumberMasked,
    required this.ifsc,
    required this.balance,
    required this.vpa,
    this.isPrimary = false,
    this.brandColor = 0xFF0B57D0,
  });

  BankAccount copyWith({
    String? id,
    String? bankName,
    String? accountNumberMasked,
    String? ifsc,
    double? balance,
    String? vpa,
    bool? isPrimary,
    int? brandColor,
  }) {
    return BankAccount(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountNumberMasked: accountNumberMasked ?? this.accountNumberMasked,
      ifsc: ifsc ?? this.ifsc,
      balance: balance ?? this.balance,
      vpa: vpa ?? this.vpa,
      isPrimary: isPrimary ?? this.isPrimary,
      brandColor: brandColor ?? this.brandColor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bankName': bankName,
      'accountNumberMasked': accountNumberMasked,
      'ifsc': ifsc,
      'balance': balance,
      'vpa': vpa,
      'isPrimary': isPrimary,
      'brandColor': brandColor,
    };
  }

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      id: map['id'] ?? '',
      bankName: map['bankName'] ?? '',
      accountNumberMasked: map['accountNumberMasked'] ?? '•••• 0000',
      ifsc: map['ifsc'] ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 10000.0,
      vpa: map['vpa'] ?? '',
      isPrimary: map['isPrimary'] ?? false,
      brandColor: map['brandColor'] ?? 0xFF0B57D0,
    );
  }

  String toJson() => json.encode(toMap());
  factory BankAccount.fromJson(String source) => BankAccount.fromMap(json.decode(source));

  /// Discovers real bank accounts linked to a specific phone number via simulated NPCI UPI switch query
  static List<BankAccount> discoverAccountsForPhone(String phone, String name) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final last4 = clean.length >= 4 ? clean.substring(clean.length - 4) : '4291';
    final mid4 = clean.length >= 6 ? clean.substring(clean.length - 6, clean.length - 2) : '8820';
    final first4 = clean.length >= 4 ? clean.substring(0, 4) : '1044';

    return [
      BankAccount(
        id: 'acc_hdfc_${clean.hashCode.abs() % 10000}',
        bankName: 'HDFC Bank',
        accountNumberMasked: '•••• $last4',
        ifsc: 'HDFC0001234',
        balance: 45000.0,
        vpa: '$clean@sliceupi',
        isPrimary: true,
        brandColor: 0xFF004C8F,
      ),
      BankAccount(
        id: 'acc_sbi_${clean.hashCode.abs() % 10000}',
        bankName: 'State Bank of India',
        accountNumberMasked: '•••• $mid4',
        ifsc: 'SBIN0004567',
        balance: 18500.0,
        vpa: '$clean@oksbi',
        isPrimary: false,
        brandColor: 0xFF1C3F94,
      ),
      BankAccount(
        id: 'acc_icici_${clean.hashCode.abs() % 10000}',
        bankName: 'ICICI Bank',
        accountNumberMasked: '•••• $first4',
        ifsc: 'ICIC0007890',
        balance: 2450.0,
        vpa: '$clean@okicici',
        isPrimary: false,
        brandColor: 0xFFB02A30,
      ),
    ];
  }

  /// Creates a linked account for a newly selected bank linked to the phone
  static BankAccount discoverAccountForBank(SupportedBank bank, String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final suffixDigits = '${(bank.code.hashCode.abs() + clean.hashCode.abs()) % 9000 + 1000}';
    return BankAccount(
      id: 'acc_${bank.code.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
      bankName: bank.name,
      accountNumberMasked: '•••• $suffixDigits',
      ifsc: bank.ifscPrefix,
      balance: 15000.0,
      vpa: '$clean@${bank.upiHandle}',
      isPrimary: false,
      brandColor: bank.brandColor,
    );
  }

  static List<BankAccount> defaultAccounts() => [];
}
