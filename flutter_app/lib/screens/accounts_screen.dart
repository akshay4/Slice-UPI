import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../models/bank_account.dart';
import '../widgets/mpin_modal_sheet.dart';

class AccountsScreen extends StatefulWidget {
  final AppState state;

  const AccountsScreen({super.key, required this.state});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final Map<String, bool> _revealedBalances = {};

  void _handleCheckBalance(BankAccount account) async {
    final pin = await MpinModalSheet.show(
      context,
      account: account,
      payeeName: 'Bank Balance Inquiry',
      payeeVpa: account.vpa,
      totalAmount: 0.0,
      trancheCount: 1,
    );

    if (pin != null) {
      if (widget.state.verifyMpin(pin)) {
        setState(() {
          _revealedBalances[account.id] = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${account.bankName} balance: ₹${account.balance.toStringAsFixed(2)}'),
              backgroundColor: const Color(0xFF146C2E),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incorrect UPI PIN entered. Try 1234.'),
              backgroundColor: Color(0xFFBA1A1A),
            ),
          );
        }
      }
    }
  }

  void _showBankDiscoveryBottomSheet() {
    final phone = widget.state.userProfile?.phone ?? '';
    final name = widget.state.userProfile?.name ?? 'Account Holder';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => _BankDiscoverySheet(
        phone: phone,
        userName: name,
        onBankSelected: (bank) async {
          Navigator.of(modalCtx).pop();
          _runBankDiscoveryProcess(bank);
        },
      ),
    );
  }

  void _runBankDiscoveryProcess(SupportedBank bank) {
    final phone = widget.state.userProfile?.phone ?? '';
    final name = widget.state.userProfile?.name ?? 'Account Holder';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => _AccountLinkingProgressDialog(
        bank: bank,
        phone: phone,
        userName: name,
        onSuccess: (newAcc) async {
          Navigator.of(dialogCtx).pop();
          await widget.state.linkAccountFromBank(bank);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Linked ${bank.name} (${newAcc.accountNumberMasked}) successfully!'),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF146C2E),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (ctx, _) {
        final accounts = widget.state.accounts;
        final selected = widget.state.selectedAccount;
        final phone = widget.state.userProfile?.phone ?? '';
        final name = widget.state.userProfile?.displayName ?? 'Account Holder';

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank Accounts & Cards',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F)),
                ),
                Text(
                  'Connected Core Banking Debit Sources',
                  style: TextStyle(fontSize: 11, color: Color(0xFF44474E)),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh Balances',
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0F62FE)),
                onPressed: () {
                  widget.state.resetDemoBalances();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account balances refreshed')),
                  );
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // SIM Binding & Phone Number Verified Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.sim_card_rounded, color: Color(0xFF146C2E), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '+91 $phone',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1B1B1F)),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC4EED0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified_rounded, color: Color(0xFF07270E), size: 10),
                                    SizedBox(width: 2),
                                    Text(
                                      'UPI VERIFIED',
                                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF07270E)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Registered to $name · NPCI SIM Bound',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'LINKED BANK ACCOUNTS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF44474E), letterSpacing: 0.5),
                  ),
                  Text(
                    '${accounts.length} Accounts',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...accounts.map((account) {
                final isSelected = account.id == selected.id;
                final isRevealed = _revealedBalances[account.id] ?? false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0F62FE) : const Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Color(account.brandColor),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    account.bankName.substring(0, account.bankName.indexOf(' ')).toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 9),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              account.bankName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isSelected) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFC4EED0),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'PRIMARY',
                                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF07270E)),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Savings A/C ${account.accountNumberMasked} • ${account.ifsc}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        account.vpa,
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF0F62FE), fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isSelected) ...[
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => widget.state.selectAccount(account),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Set Primary', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Available Balance', style: TextStyle(fontSize: 11, color: Color(0xFF44474E))),
                              const SizedBox(height: 2),
                              Text(
                                isRevealed
                                    ? '₹${account.balance.toStringAsFixed(2)}'
                                    : '••••••••',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F)),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _handleCheckBalance(account),
                            icon: Icon(
                              isRevealed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              size: 16,
                            ),
                            label: Text(
                              isRevealed ? 'Hide' : 'Check Balance',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE8EEFC),
                              foregroundColor: const Color(0xFF0F62FE),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),

              // Button to discover bank accounts via phone
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showBankDiscoveryBottomSheet,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text('Find & Link Bank Account (+91 $phone)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    foregroundColor: const Color(0xFF0F62FE),
                    side: const BorderSide(color: Color(0xFF0F62FE), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _BankDiscoverySheet extends StatefulWidget {
  final String phone;
  final String userName;
  final Function(SupportedBank bank) onBankSelected;

  const _BankDiscoverySheet({
    required this.phone,
    required this.userName,
    required this.onBankSelected,
  });

  @override
  State<_BankDiscoverySheet> createState() => _BankDiscoverySheetState();
}

class _BankDiscoverySheetState extends State<_BankDiscoverySheet> {
  String _searchQuery = '';

  List<SupportedBank> get _filteredBanks {
    if (_searchQuery.isEmpty) return SupportedBank.allBanks;
    return SupportedBank.allBanks
        .where((b) =>
            b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            b.shortName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_rounded, color: Color(0xFF0F62FE), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Bank to Link',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F)),
                      ),
                      Text(
                        'Fetching accounts registered with +91 ${widget.phone}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Search bank by name (e.g. Axis, Kotak)...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: const Color(0xFFF4F6FB),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _filteredBanks.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (ctx, index) {
                final bank = _filteredBanks[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Color(bank.brandColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      bank.shortName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                  ),
                  title: Text(
                    bank.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: Text(
                    'IFSC: ${bank.ifscPrefix} • +91 ${widget.phone}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () => widget.onBankSelected(bank),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountLinkingProgressDialog extends StatefulWidget {
  final SupportedBank bank;
  final String phone;
  final String userName;
  final Function(BankAccount account) onSuccess;

  const _AccountLinkingProgressDialog({
    required this.bank,
    required this.phone,
    required this.userName,
    required this.onSuccess,
  });

  @override
  State<_AccountLinkingProgressDialog> createState() => _AccountLinkingProgressDialogState();
}

class _AccountLinkingProgressDialogState extends State<_AccountLinkingProgressDialog> {
  int _step = 0;
  late BankAccount _discoveredAcc;

  @override
  void initState() {
    super.initState();
    _discoveredAcc = BankAccount.discoverAccountForBank(widget.bank, widget.phone);
    _runSteps();
  }

  void _runSteps() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _step = 1);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _step = 2);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      widget.onSuccess(_discoveredAcc);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Color(widget.bank.brandColor),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.bank.shortName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Linking ${widget.bank.name}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 4),
            Text(
              'Finding accounts linked to +91 ${widget.phone}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            _buildStepRow(
              index: 0,
              label: 'Verifying SIM binding (+91 ${widget.phone})',
            ),
            const SizedBox(height: 12),
            _buildStepRow(
              index: 1,
              label: 'Querying ${widget.bank.shortName} Core Switch',
            ),
            const SizedBox(height: 12),
            _buildStepRow(
              index: 2,
              label: 'Account found: ${_discoveredAcc.accountNumberMasked}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow({required int index, required String label}) {
    final isDone = _step > index;
    final isCurrent = _step == index;

    return Row(
      children: [
        if (isDone)
          const Icon(Icons.check_circle_rounded, color: Color(0xFF146C2E), size: 20)
        else if (isCurrent)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F62FE)),
          )
        else
          Icon(Icons.radio_button_unchecked_rounded, color: Colors.grey.shade400, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? const Color(0xFF1B1B1F) : Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
