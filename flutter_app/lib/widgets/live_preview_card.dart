import 'package:flutter/material.dart';
import '../models/bank_account.dart';
import '../services/slicing_engine.dart';

class LivePreviewCard extends StatelessWidget {
  final double amount;
  final BankAccount account;

  const LivePreviewCard({
    super.key,
    required this.amount,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    if (amount <= 0) return const SizedBox.shrink();

    final bool isSplitNeeded = amount > SlicingEngine.npciThreshold;
    final List<double> tranches = SlicingEngine.calculateTranches(amount, enableJitter: true);
    final double savings = SlicingEngine.calculateSavings(amount);
    final bool hasInsufficientFunds = account.balance < amount;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F9),
        border: Border.all(
          color: hasInsufficientFunds ? const Color(0xFFBA1A1A).withValues(alpha: 0.5) : const Color(0xFFC4C6D0),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isSplitNeeded ? Icons.alt_route_rounded : Icons.flash_on_rounded,
                    size: 18,
                    color: const Color(0xFF0B57D0),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SLICING ENGINE & JITTER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Color(0xFF0B57D0),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSplitNeeded ? const Color(0xFFC4EED0) : const Color(0xFFCCE5FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isSplitNeeded ? 'Auto-Split (> ₹2,000)' : 'Direct (≤ ₹2,000)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSplitNeeded ? const Color(0xFF07270E) : const Color(0xFF001D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasInsufficientFunds)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAD6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFBA1A1A)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Account balance (₹${account.balance.toStringAsFixed(2)}) is lower than total amount.',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF410002), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          Column(
            children: tranches.asMap().entries.map((entry) {
              final int index = entry.key;
              final double trancheAmount = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Slice #${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(Under ₹2,000)',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    Text(
                      '₹${trancheAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B57D0)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.security_rounded, size: 14, color: Color(0xFF146C2E)),
                  const SizedBox(width: 4),
                  Text(
                    'Anti-Velocity Jitter Active (±₹30)',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              if (savings > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC4EED0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Est. Save ₹${savings.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF07270E),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
