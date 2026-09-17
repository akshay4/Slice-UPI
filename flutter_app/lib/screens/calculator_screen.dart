import 'package:flutter/material.dart';
import '../models/bank_account.dart';
import '../models/split_plan.dart';
import '../services/slicing_engine.dart';
import '../widgets/bank_selector_sheet.dart';
import '../widgets/compliance_dialog.dart';
import '../widgets/live_preview_card.dart';
import '../widgets/mpin_modal_sheet.dart';

class CalculatorScreen extends StatefulWidget {
  final ValueChanged<SplitPlan> onProceed;

  const CalculatorScreen({
    super.key,
    required this.onProceed,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _amountController = TextEditingController(text: '3500');
  final TextEditingController _vpaController = TextEditingController(text: 'merchantstore@oksbi');
  final TextEditingController _nameController = TextEditingController(text: 'Suresh Electronics');
  final TextEditingController _noteController = TextEditingController(text: 'Hardware accessories');

  BankAccount _selectedAccount = BankAccount.defaultAccounts.first;
  bool _isUpiIdMode = true;

  double get _currentAmount => double.tryParse(_amountController.text) ?? 0.0;

  void _setPreset(int amount) {
    setState(() {
      _amountController.text = amount.toString();
    });
  }

  void _handleChangeAccount() async {
    final account = await BankSelectorSheet.show(context, currentAccount: _selectedAccount);
    if (account != null) {
      setState(() {
        _selectedAccount = account;
      });
    }
  }

  void _handlePay() async {
    final amount = _currentAmount;
    if (amount <= 0) return;

    if (_selectedAccount.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient balance in ${_selectedAccount.bankName} (₹${_selectedAccount.balance.toStringAsFixed(2)})'),
          backgroundColor: const Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    final plan = SlicingEngine.createPlan(
      totalAmount: amount,
      payeeVpa: _vpaController.text.trim(),
      payeeName: _nameController.text.trim(),
      account: _selectedAccount,
      note: _noteController.text.trim(),
    );

    final pin = await MpinModalSheet.show(
      context,
      account: _selectedAccount,
      payeeName: plan.payeeName,
      payeeVpa: plan.payeeVpa,
      totalAmount: plan.totalAmount,
      trancheCount: plan.tranches.length,
    );

    if (pin != null && pin.isNotEmpty) {
      widget.onProceed(plan);
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = _currentAmount;
    final isOverBalance = _selectedAccount.balance < amount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B57D0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '₹',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Slice ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F)),
                              ),
                              Text(
                                'UPI',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B57D0)),
                              ),
                            ],
                          ),
                          Text(
                            'Autonomous In-App Switch • Material 3',
                            style: TextStyle(fontSize: 11, color: Color(0xFF44474E)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () => ComplianceDialog.show(context),
                    icon: const Icon(Icons.help_outline_rounded, size: 16),
                    label: const Text('Rules Guide', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF041E49),
                      backgroundColor: const Color(0xFFD3E3FD),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Payee Verified Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC4C6D0).withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFD3E3FD),
                      child: const Text(
                        'SU',
                        style: TextStyle(color: Color(0xFF041E49), fontWeight: FontWeight.bold, fontSize: 16),
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
                                  _nameController.text,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.check_circle, size: 16, color: Color(0xFF146C2E)),
                            ],
                          ),
                          Text(
                            _vpaController.text,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('QR Code scanner initialized')),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner, size: 16),
                      label: const Text('Scan QR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFD3E3FD).withValues(alpha: 0.5),
                        side: BorderSide.none,
                        foregroundColor: const Color(0xFF041E49),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Payee Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC4C6D0).withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PAYEE DETAILS',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF44474E), letterSpacing: 0.5),
                        ),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => setState(() => _isUpiIdMode = true),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _isUpiIdMode ? const Color(0xFFCCE5FF) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.alternate_email, size: 12, color: Color(0xFF001D32)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'UPI ID',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: _isUpiIdMode ? const Color(0xFF001D32) : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => setState(() => _isUpiIdMode = false),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: !_isUpiIdMode ? const Color(0xFFCCE5FF) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.phone_android, size: 12, color: Color(0xFF001D32)),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Mobile No',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: !_isUpiIdMode ? const Color(0xFF001D32) : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _vpaController,
                      decoration: InputDecoration(
                        labelText: 'Virtual Payment Address (VPA)',
                        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FD),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Payee Name',
                        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FD),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) => setState(() {}),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // SlicePay UPI Engine Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC4C6D0).withValues(alpha: 0.5)),
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
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B57D0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.bolt, color: Colors.white, size: 14),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'SLICEPAY UPI ENGINE',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F), letterSpacing: 0.5),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC4EED0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '0% MDR • Direct Bank-to-Bank',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF07270E)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Color(_selectedAccount.brandColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _selectedAccount.bankName.substring(0, _selectedAccount.bankName.indexOf(' ')).toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_selectedAccount.bankName} (${_selectedAccount.accountNumberMasked})',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  'Avail: ₹${_selectedAccount.balance.toStringAsFixed(2)} • ${_selectedAccount.vpa}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _selectedAccount.balance < amount ? const Color(0xFFBA1A1A) : Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: _handleChangeAccount,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCE5FF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    'Change',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF001D32)),
                                  ),
                                  Icon(Icons.chevron_right, size: 14, color: Color(0xFF001D32)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Autonomous In-App Switch debits directly via NPCI Common Library MPIN. No third-party apps needed.',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Amount Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC4C6D0).withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'ENTER TOTAL AMOUNT',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF44474E), letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          '₹',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F)),
                        ),
                        const SizedBox(width: 4),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F)),
                            decoration: const InputDecoration(border: InputBorder.none),
                            onChanged: (val) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Preset chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [2000, 3500, 5000, 7500].map((preset) {
                        final isSelected = amount == preset.toDouble();
                        return InkWell(
                          onTap: () => _setPreset(preset),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFCCE5FF) : const Color(0xFFF3F4F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF00639B) : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              '₹$preset',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? const Color(0xFF001D32) : const Color(0xFF1B1B1F),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        labelText: 'Add a note (optional)',
                        labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FD),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // Live Preview Card
              LivePreviewCard(amount: amount, account: _selectedAccount),

              const SizedBox(height: 20),

              // Proceed CTA Button
              FilledButton(
                onPressed: (amount > 0 && !isOverBalance) ? _handlePay : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0B57D0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Text(
                  isOverBalance
                      ? 'Insufficient Bank Balance'
                      : 'Proceed to Pay ₹${amount > 0 ? amount.toStringAsFixed(0) : "0"}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
