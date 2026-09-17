import 'package:flutter/material.dart';
import '../models/bank_account.dart';

class BankSelectorSheet extends StatelessWidget {
  final BankAccount selectedAccount;
  final ValueChanged<BankAccount> onSelect;

  const BankSelectorSheet({
    super.key,
    required this.selectedAccount,
    required this.onSelect,
  });

  static Future<BankAccount?> show(
    BuildContext context, {
    required BankAccount currentAccount,
  }) {
    return showModalBottomSheet<BankAccount>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => BankSelectorSheet(
        selectedAccount: currentAccount,
        onSelect: (acc) => Navigator.pop(ctx, acc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Select Debit Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B1B1F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Direct bank debits powered by SlicePay In-App Switch',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          ...BankAccount.defaultAccounts.map((account) {
            final isSelected = account.id == selectedAccount.id;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD3E3FD).withValues(alpha: 0.35) : const Color(0xFFF8F9FD),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0B57D0) : const Color(0xFFC4C6D0).withValues(alpha: 0.5),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Color(account.brandColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    account.bankName.substring(0, account.bankName.indexOf(' ')).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      account.bankName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      account.accountNumberMasked,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Avail: ₹${account.balance.toStringAsFixed(2)} • ${account.vpa}',
                      style: TextStyle(
                        fontSize: 12,
                        color: account.balance < 2000 ? const Color(0xFFBA1A1A) : const Color(0xFF146C2E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0B57D0))
                    : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                onTap: () => onSelect(account),
              ),
            );
          }),
        ],
      ),
    );
  }
}
