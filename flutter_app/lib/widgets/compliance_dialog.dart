import 'package:flutter/material.dart';

class ComplianceDialog extends StatelessWidget {
  const ComplianceDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const ComplianceDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Color(0xFF0B57D0)),
                      SizedBox(width: 8),
                      Text(
                        'Rules & Compliance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B1B1F),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: '1. NPCI/RBI 1.1% Surcharge Rules',
                content:
                    'Under NPCI guidelines effective April 2023, merchant transactions above ₹2,000 via Prepaid Payment Instruments (wallets/PPI) incur up to 1.1% interchange fee. Peer-to-peer and direct bank-to-bank account debits remain strictly 0% surcharge.',
                icon: Icons.account_balance_wallet_outlined,
                color: const Color(0xFF00639B),
              ),
              const SizedBox(height: 14),
              _buildSection(
                title: '2. PMLA Anti-Structuring & Jitter',
                content:
                    'To comply with PMLA (Prevention of Money Laundering Act) rules regarding transaction splitting, SlicePay incorporates random anti-velocity jitter variance (±₹30) between tranches, preventing artificial clustering patterns.',
                icon: Icons.alt_route_rounded,
                color: const Color(0xFF146C2E),
              ),
              const SizedBox(height: 14),
              _buildSection(
                title: '3. SlicePay Autonomous Core Switch',
                content:
                    'SlicePay functions as a direct in-app autonomous switch executing sequential tranches through the bank API with NPCI Common Library 256-bit encryption. No 3rd-party UPI apps or external escrow required.',
                icon: Icons.bolt_rounded,
                color: const Color(0xFF0B57D0),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0B57D0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}
