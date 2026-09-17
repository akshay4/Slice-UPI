import 'package:flutter/material.dart';
import '../models/split_plan.dart';
import '../models/contact.dart';
import '../services/slicing_engine.dart';
import '../services/app_state.dart';
import '../widgets/bank_selector_sheet.dart';
import '../widgets/compliance_dialog.dart';
import '../widgets/live_preview_card.dart';
import '../widgets/mpin_modal_sheet.dart';
import '../widgets/qr_scanner_modal.dart';

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

  String _selectedCategory = 'Electronics';

  final List<String> _categoryTags = ['Dining', 'Groceries', 'Electronics', 'Shopping', 'Bills'];

  double get _currentAmount => double.tryParse(_amountController.text) ?? 0.0;

  void _selectContact(Contact contact) {
    setState(() {
      _nameController.text = contact.name;
      _vpaController.text = contact.vpa;
      _noteController.text = contact.category;
    });
  }

  void _handleScanQr() async {
    final result = await QrScannerModal.show(context);
    if (result != null) {
      setState(() {
        _vpaController.text = result.vpa;
        _nameController.text = result.name;
        if (result.amount != null && result.amount! > 0) {
          _amountController.text = result.amount!.toStringAsFixed(0);
        }
        if (result.note != null && result.note!.isNotEmpty) {
          _noteController.text = result.note!;
        }
      });
    }
  }

  void _handleChangeAccount() async {
    final account = await BankSelectorSheet.show(
      context,
      currentAccount: AppState.instance.selectedAccount,
    );
    if (account != null) {
      AppState.instance.selectAccount(account);
    }
  }

  void _handlePay() async {
    final amount = _currentAmount;
    if (amount <= 0) return;

    final account = AppState.instance.selectedAccount;
    if (account.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient balance in ${account.bankName} (₹${account.balance.toStringAsFixed(2)})'),
          backgroundColor: const Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    final plan = SlicingEngine.createPlan(
      totalAmount: amount,
      payeeVpa: _vpaController.text.trim(),
      payeeName: _nameController.text.trim(),
      account: account,
      note: _noteController.text.trim(),
      merchantCategory: _selectedCategory,
    );

    final pin = await MpinModalSheet.show(
      context,
      account: account,
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
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (ctx, _) {
        final account = AppState.instance.selectedAccount;
        final amount = _currentAmount;
        final isOverBalance = account.balance < amount;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 16,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B57D0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text('₹', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Slice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F))),
                        Text('Pay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0B57D0))),
                      ],
                    ),
                    Text('Autonomous UPI Core Switch', style: TextStyle(fontSize: 10, color: Color(0xFF44474E))),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Compliance Rules',
                icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF0B57D0)),
                onPressed: () => ComplianceDialog.show(context),
              ),
              IconButton(
                tooltip: 'Scan QR',
                icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF0B57D0)),
                onPressed: _handleScanQr,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Recent Frequent Payees Carousel
                const Text(
                  'RECENT PAYEES',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF44474E), letterSpacing: 0.5),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 84,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppState.instance.contacts.length,
                    itemBuilder: (ctx, index) {
                      final contact = AppState.instance.contacts[index];
                      final isSelected = _vpaController.text == contact.vpa;

                      return InkWell(
                        onTap: () => _selectContact(contact),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 72,
                          margin: const EdgeInsets.only(right: 8),
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Color(contact.avatarColor).withValues(alpha: isSelected ? 1.0 : 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF0B57D0) : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  contact.initials,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Color(contact.avatarColor),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                contact.name.split(' ').first,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: const Color(0xFF1B1B1F),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Payee Details Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC4C6D0).withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'PAYEE DETAILS',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF44474E), letterSpacing: 0.5),
                          ),
                          InkWell(
                            onTap: _handleScanQr,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD3E3FD).withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.qr_code_scanner, size: 14, color: Color(0xFF041E49)),
                                  SizedBox(width: 4),
                                  Text('Scan QR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF041E49))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 10),
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
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Core Switch Bank Source Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC4C6D0).withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
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
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0B57D0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.bolt, color: Colors.white, size: 14),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'DEBIT SOURCE',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F), letterSpacing: 0.5),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC4EED0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '0% Surcharge • Core Bank',
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
                                color: Color(account.brandColor),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                account.bankName.substring(0, account.bankName.indexOf(' ')).toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${account.bankName} (${account.accountNumberMasked})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Text(
                                    'Avail: ₹${account.balance.toStringAsFixed(2)} • ${account.vpa}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: account.balance < amount ? const Color(0xFFBA1A1A) : Colors.grey.shade700,
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
                                    Text('Change', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF001D32))),
                                    Icon(Icons.chevron_right, size: 14, color: Color(0xFF001D32)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Amount & Tags Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC4C6D0).withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'ENTER AMOUNT',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF44474E), letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const Text('₹', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F))),
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
                      const SizedBox(height: 10),
                      // Preset amount chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [2000, 3500, 5000, 7500].map((preset) {
                          final isSelected = amount == preset.toDouble();
                          return InkWell(
                            onTap: () => setState(() => _amountController.text = preset.toString()),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFCCE5FF) : const Color(0xFFF3F4F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isSelected ? const Color(0xFF00639B) : Colors.grey.shade300),
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
                      const SizedBox(height: 14),
                      // Tags
                      Wrap(
                        spacing: 6,
                        children: _categoryTags.map((tag) {
                          final isSelected = _selectedCategory == tag;
                          return ChoiceChip(
                            label: Text(tag, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                            selected: isSelected,
                            onSelected: (val) => setState(() => _selectedCategory = tag),
                            selectedColor: const Color(0xFFD3E3FD),
                            backgroundColor: const Color(0xFFF3F4F9),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Live Preview Card
                LivePreviewCard(amount: amount, account: account),

                const SizedBox(height: 20),

                // Proceed CTA
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
        );
      },
    );
  }
}
