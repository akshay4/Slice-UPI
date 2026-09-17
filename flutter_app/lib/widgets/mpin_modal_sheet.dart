import 'package:flutter/material.dart';
import '../models/bank_account.dart';
import '../services/app_state.dart';

class MpinModalSheet extends StatefulWidget {
  final BankAccount account;
  final String payeeName;
  final String payeeVpa;
  final double totalAmount;
  final int trancheCount;
  final ValueChanged<String> onSubmit;

  const MpinModalSheet({
    super.key,
    required this.account,
    required this.payeeName,
    required this.payeeVpa,
    required this.totalAmount,
    required this.trancheCount,
    required this.onSubmit,
  });

  static Future<String?> show(
    BuildContext context, {
    required BankAccount account,
    required String payeeName,
    required String payeeVpa,
    required double totalAmount,
    required int trancheCount,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => MpinModalSheet(
        account: account,
        payeeName: payeeName,
        payeeVpa: payeeVpa,
        totalAmount: totalAmount,
        trancheCount: trancheCount,
        onSubmit: (pin) => Navigator.pop(ctx, pin),
      ),
    );
  }

  @override
  State<MpinModalSheet> createState() => _MpinModalSheetState();
}

class _MpinModalSheetState extends State<MpinModalSheet> {
  String _pin = '';
  bool _showPin = false;
  String? _errorMessage;
  int _attemptsRemaining = 3;

  void _handleDigit(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _errorMessage = null;
        _pin += digit;
      });

      if (_pin.length == 4) {
        _verifyAndSubmit();
      }
    }
  }

  void _handleBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _errorMessage = null;
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _verifyAndSubmit() {
    if (_pin.length != 4) return;

    if (AppState.instance.verifyMpin(_pin)) {
      widget.onSubmit(_pin);
    } else {
      setState(() {
        _attemptsRemaining--;
        if (_attemptsRemaining > 0) {
          _errorMessage = 'Incorrect UPI PIN. $_attemptsRemaining attempts remaining.';
        } else {
          _errorMessage = 'UPI PIN blocked. Please try again after 24 hours.';
        }
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isZeroAmount = widget.totalAmount <= 0;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Bank header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(widget.account.brandColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.account.bankName.substring(0, widget.account.bankName.indexOf(' ')).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.account.bankName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Savings A/C ${widget.account.accountNumberMasked}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
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

          // Payee & Amount
          Text(
            widget.payeeName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F)),
            textAlign: TextAlign.center,
          ),
          Text(
            widget.payeeVpa,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          if (!isZeroAmount && widget.trancheCount > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD3E3FD).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'SlicePay Multi-Tranche (${widget.trancheCount} slices < ₹2,000)',
                style: const TextStyle(fontSize: 11, color: Color(0xFF041E49), fontWeight: FontWeight.w600),
              ),
            ),
          if (!isZeroAmount)
            Text(
              '₹${widget.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F)),
            ),

          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF0B57D0)),
              SizedBox(width: 6),
              Text(
                'ENTER 4-DIGIT UPI PIN',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0B57D0), letterSpacing: 0.5),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 4-digit PIN indicator boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: List.generate(4, (index) {
                  final bool filled = index < _pin.length;
                  return Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: _errorMessage != null
                          ? const Color(0xFFFFDAD6)
                          : filled
                              ? const Color(0xFFD3E3FD).withValues(alpha: 0.4)
                              : const Color(0xFFF3F4F9),
                      border: Border.all(
                        color: _errorMessage != null
                            ? const Color(0xFFBA1A1A)
                            : filled
                                ? const Color(0xFF0B57D0)
                                : const Color(0xFFC4C6D0),
                        width: filled ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: filled
                        ? (_showPin
                            ? Text(
                                _pin[index],
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0B57D0)),
                              )
                            : Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0B57D0),
                                  shape: BoxShape.circle,
                                ),
                              ))
                        : null,
                  );
                }),
              ),
              IconButton(
                icon: Icon(
                  _showPin ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                onPressed: () => setState(() => _showPin = !_showPin),
              ),
            ],
          ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 12, color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold),
              ),
            ),

          const SizedBox(height: 16),

          // Numeric touch keypad (3x4 grid)
          Column(
            children: [
              _buildKeypadRow(['1', '2', '3']),
              const SizedBox(height: 10),
              _buildKeypadRow(['4', '5', '6']),
              const SizedBox(height: 10),
              _buildKeypadRow(['7', '8', '9']),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.backspace_outlined,
                    onTap: _handleBackspace,
                    color: Colors.grey.shade200,
                    iconColor: Colors.black87,
                  ),
                  _buildNumberButton('0'),
                  _buildActionButton(
                    icon: Icons.check,
                    onTap: _verifyAndSubmit,
                    color: _pin.length == 4 ? const Color(0xFF0B57D0) : Colors.grey.shade300,
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF146C2E)),
              const SizedBox(width: 6),
              Text(
                'NPCI Common Library • 256-Bit Bank End-to-End Encryption',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildNumberButton(d)).toList(),
    );
  }

  Widget _buildNumberButton(String digit) {
    return InkWell(
      onTap: () => _handleDigit(digit),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 80,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F9),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1B1B1F)),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 80,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}
