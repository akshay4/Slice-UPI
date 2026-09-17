import 'package:flutter/material.dart';
import '../models/split_plan.dart';
import '../models/tranche.dart';
import '../services/native_switch_service.dart';

class SwitchRunnerScreen extends StatefulWidget {
  final SplitPlan plan;
  final VoidCallback onCancel;
  final ValueChanged<SplitPlan> onCompleted;

  const SwitchRunnerScreen({
    super.key,
    required this.plan,
    required this.onCancel,
    required this.onCompleted,
  });

  @override
  State<SwitchRunnerScreen> createState() => _SwitchRunnerScreenState();
}

class _SwitchRunnerScreenState extends State<SwitchRunnerScreen> {
  late List<Tranche> _tranches;
  bool _isRunning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tranches = List.from(widget.plan.tranches);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSequentialExecution();
    });
  }

  void _startSequentialExecution() async {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _errorMessage = null;
    });

    for (int i = 0; i < _tranches.length; i++) {
      setState(() {
        _tranches[i] = _tranches[i].copyWith(status: TrancheStatus.processing);
      });

      try {
        final updated = await NativeSwitchService.executeTranche(
          tranche: _tranches[i],
          account: widget.plan.account,
          mpin: '1234',
        );

        if (!mounted) return;
        setState(() {
          _tranches[i] = updated;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _tranches[i] = _tranches[i].copyWith(
            status: TrancheStatus.failed,
            error: e.toString(),
          );
          _errorMessage = e.toString();
          _isRunning = false;
        });
        return;
      }
    }

    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 600));

    final completedPlan = SplitPlan(
      id: widget.plan.id,
      totalAmount: widget.plan.totalAmount,
      payeeVpa: widget.plan.payeeVpa,
      payeeName: widget.plan.payeeName,
      merchantCategory: widget.plan.merchantCategory,
      note: widget.plan.note,
      account: widget.plan.account,
      createdAt: widget.plan.createdAt,
      tranches: _tranches,
      totalSavings: widget.plan.totalSavings,
      antiVelocityJitter: widget.plan.antiVelocityJitter,
    );

    widget.onCompleted(completedPlan);
  }

  @override
  Widget build(BuildContext context) {
    final int settledCount = _tranches.where((t) => t.status == TrancheStatus.success).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _isRunning ? null : widget.onCancel,
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SlicePay Switch Engine',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F)),
                      ),
                      Text(
                        'Autonomous Bank Debit Protocol',
                        style: TextStyle(fontSize: 11, color: Color(0xFF44474E)),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Payment Target Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC4C6D0).withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Paying ${widget.plan.payeeName}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${widget.plan.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Debited from ${widget.plan.account.bankName} ${widget.plan.account.accountNumberMasked}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF001D32)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Execution Progress Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TRANCHE EXECUTION ($settledCount/${_tranches.length})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF44474E), letterSpacing: 0.5),
                  ),
                  if (_isRunning)
                    const Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0B57D0)),
                        ),
                        SizedBox(width: 6),
                        Text('Switch Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0B57D0))),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Tranches List
              Expanded(
                child: ListView.builder(
                  itemCount: _tranches.length,
                  itemBuilder: (ctx, index) {
                    final tranche = _tranches[index];
                    final bool isSuccess = tranche.status == TrancheStatus.success;
                    final bool isProcessing = tranche.status == TrancheStatus.processing;
                    final bool isFailed = tranche.status == TrancheStatus.failed;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isProcessing
                              ? const Color(0xFF0B57D0)
                              : isSuccess
                                  ? const Color(0xFF146C2E).withValues(alpha: 0.4)
                                  : isFailed
                                      ? const Color(0xFFBA1A1A).withValues(alpha: 0.4)
                                      : Colors.grey.shade200,
                          width: (isProcessing || isSuccess) ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (isProcessing)
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0B57D0)),
                                    )
                                  else if (isSuccess)
                                    const Icon(Icons.check_circle, size: 18, color: Color(0xFF146C2E))
                                  else if (isFailed)
                                    const Icon(Icons.error_outline, size: 18, color: Color(0xFFBA1A1A))
                                  else
                                    const Icon(Icons.schedule, size: 18, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Slice #${tranche.order} • ₹${tranche.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isSuccess
                                      ? const Color(0xFFC4EED0)
                                      : isProcessing
                                          ? const Color(0xFFCCE5FF)
                                          : isFailed
                                              ? const Color(0xFFFFDAD6)
                                              : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isSuccess
                                      ? 'Settled'
                                      : isProcessing
                                          ? 'Debiting...'
                                          : isFailed
                                              ? 'Failed'
                                              : 'Queued',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSuccess
                                      ? const Color(0xFF07270E)
                                      : isProcessing
                                          ? const Color(0xFF001D32)
                                          : isFailed
                                              ? const Color(0xFF410002)
                                              : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (isSuccess && tranche.utr != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'NPCI UTR: ${tranche.utr} • ${tranche.latencyMs ?? 1000}ms',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),

              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDAD6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF410002), fontWeight: FontWeight.bold),
                  ),
                ),

              // Bottom Security Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 14, color: Color(0xFF146C2E)),
                  const SizedBox(width: 6),
                  Text(
                    '256-Bit NPCI CL End-to-End Encrypted Tunnel',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
