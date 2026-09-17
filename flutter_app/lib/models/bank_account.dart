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

  static List<BankAccount> defaultAccounts() => [
    BankAccount(
      id: 'acc_hdfc_01',
      bankName: 'HDFC Bank',
      accountNumberMasked: '•••• 4291',
      ifsc: 'HDFC0001234',
      balance: 50000.0,
      vpa: 'akshay@sliceupi',
      isPrimary: true,
      brandColor: 0xFF004C8F,
    ),
    BankAccount(
      id: 'acc_sbi_02',
      bankName: 'State Bank of India',
      accountNumberMasked: '•••• 8820',
      ifsc: 'SBIN0004567',
      balance: 12500.0,
      vpa: 'akshay@oksbi',
      isPrimary: false,
      brandColor: 0xFF1C3F94,
    ),
    BankAccount(
      id: 'acc_icici_03',
      bankName: 'ICICI Bank',
      accountNumberMasked: '•••• 1044',
      ifsc: 'ICIC0007890',
      balance: 1200.0,
      vpa: 'akshay@okicici',
      isPrimary: false,
      brandColor: 0xFFB02A30,
    ),
  ];
}
