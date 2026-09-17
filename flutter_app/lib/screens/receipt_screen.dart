import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/split_plan.dart';

class ReceiptScreen extends StatefulWidget {
  final SplitPlan plan;
  final VoidCallback onReset;

  const ReceiptScreen({
    super.key,
    required this.plan,
    required this.onReset,
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Success Badge Card
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFC4C6D0).withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC4EED0),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.check_rounded, color: Color(0xFF07270E), size: 36),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Paid successfully to',
                          style: TextStyle(fontSize: 13, color: Color(0xFF44474E)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.plan.payeeName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F)),
                        ),
                        Text(
                          widget.plan.payeeVpa,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '₹${widget.plan.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F)),
                        ),
                        if (widget.plan.totalSavings > 0) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC4EED0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF07270E)),
                                const SizedBox(width: 6),
                                Text(
                                  'Saved ~₹${widget.plan.totalSavings.toStringAsFixed(0)} in interchange fees',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF07270E)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Transaction Breakdown Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFC4C6D0).withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TRANSACTION BREAKDOWN',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF44474E), letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 14),
                        _buildRow('Execution Engine', 'SlicePay In-App UPI Switch (Direct Bank Debit)', isHighlight: true),
                        const Divider(height: 20),
                        _buildRow('Debited Account', '${widget.plan.account.bankName} ${widget.plan.account.accountNumberMasked}'),
                        const Divider(height: 20),
                        _buildRow('Total Tranches', '${widget.plan.tranches.length} Tranches (All Settled)'),
                        const Divider(height: 20),
                        ...widget.plan.tranches.map((tranche) {
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FD),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Slice #${tranche.order} • ₹${tranche.amount.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'NPCI UTR: ${tranche.utr ?? "N/A"} • ${tranche.latencyMs ?? 1000}ms',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF0B57D0), fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      'Settled',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF146C2E)),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF146C2E)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Done Button
                  FilledButton(
                    onPressed: widget.onReset,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0B57D0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Done • Start New Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Verification
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_outlined, size: 14, color: Color(0xFF146C2E)),
                      SizedBox(width: 6),
                      Text(
                        'Transaction settled securely under NPCI Unified Payments Interface',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Confetti Overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Color(0xFF0B57D0),
                  Color(0xFF146C2E),
                  Color(0xFFBA1A1A),
                  Color(0xFF00639B),
                  Colors.amber,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isHighlight ? const Color(0xFF0B57D0) : const Color(0xFF1B1B1F),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
