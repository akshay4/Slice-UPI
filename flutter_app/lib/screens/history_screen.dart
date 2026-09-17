import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import 'receipt_screen.dart';

class HistoryScreen extends StatelessWidget {
  final AppState state;

  const HistoryScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (ctx, _) {
        final history = state.history;
        final double totalSavings = history.fold(0.0, (sum, p) => sum + p.totalSavings);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 1,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UPI Passbook',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F)),
                ),
                Text(
                  'Autonomous Switch Transaction Ledger',
                  style: TextStyle(fontSize: 11, color: Color(0xFF44474E)),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Summary Savings Banner
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B57D0), Color(0xFF00639B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B57D0).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Interchange Saved',
                          style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${totalSavings.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '100% 0% MDR Surcharge Bypass',
                          style: TextStyle(fontSize: 11, color: Color(0xFFC4EED0), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.savings_outlined, color: Colors.white, size: 28),
                    ),
                  ],
                ),
              ),

              // Transactions Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECENT TRANSACTIONS (${history.length})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF44474E), letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),

              // Transactions List
              Expanded(
                child: history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('No transactions yet', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: history.length,
                        itemBuilder: (ctx, index) {
                          final plan = history[index];
                          final dateFormatted = DateFormat('dd MMM yyyy, hh:mm a').format(plan.createdAt);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFC4C6D0).withValues(alpha: 0.4)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD3E3FD).withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  plan.payeeName.length >= 2 ? plan.payeeName.substring(0, 2).toUpperCase() : 'UP',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF041E49), fontSize: 14),
                                ),
                              ),
                              title: Text(
                                plan.payeeName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  Text(
                                    dateFormatted,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F9),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${plan.tranches.length} slices',
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF041E49)),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      if (plan.totalSavings > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFC4EED0),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Saved ₹${plan.totalSavings.toStringAsFixed(0)}',
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF07270E)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '-₹${plan.totalAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1B1B1F)),
                                  ),
                                  const SizedBox(height: 4),
                                  const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Settled', style: TextStyle(fontSize: 10, color: Color(0xFF146C2E), fontWeight: FontWeight.bold)),
                                      SizedBox(width: 2),
                                      Icon(Icons.check_circle, size: 10, color: Color(0xFF146C2E)),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => ReceiptScreen(
                                      plan: plan,
                                      onReset: () => Navigator.pop(ctx),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
