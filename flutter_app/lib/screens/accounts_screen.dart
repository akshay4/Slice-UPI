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
              content: Text('Incorrect UPI PIN entered.'),
              backgroundColor: Color(0xFFBA1A1A),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (ctx, _) {
        final accounts = widget.state.accounts;
        final selected = widget.state.selectedAccount;

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
                tooltip: 'Reset Balances',
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0B57D0)),
                onPressed: () {
                  widget.state.resetDemoBalances();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bank account balances reset to initial values')),
                  );
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'LINKED BANK ACCOUNTS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF44474E), letterSpacing: 0.5),
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
                      color: isSelected ? const Color(0xFF0B57D0) : const Color(0xFFC4C6D0).withValues(alpha: 0.4),
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
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        account.bankName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                                  Text(
                                    'Savings A/C ${account.accountNumberMasked} • ${account.ifsc}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (!isSelected)
                            TextButton(
                              onPressed: () => widget.state.selectAccount(account),
                              child: const Text('Set Primary', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
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
                          OutlinedButton.icon(
                            onPressed: () => _handleCheckBalance(account),
                            icon: Icon(isRevealed ? Icons.refresh : Icons.visibility_outlined, size: 14),
                            label: Text(isRevealed ? 'Refresh' : 'Check Balance', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0B57D0),
                              side: const BorderSide(color: Color(0xFF0B57D0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
