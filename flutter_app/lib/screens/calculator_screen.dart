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
import '../widgets/contact_picker_sheet.dart';
import '../services/upi_intent_service.dart';

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
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _vpaController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedCategory = 'General';

  final List<String> _categoryTags = ['General', 'Dining', 'Groceries', 'Shopping', 'Bills'];

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

  void _handlePickContact() async {
    final contact = await ContactPickerSheet.show(context);
    if (contact != null) {
      setState(() {
        _nameController.text = contact.name;
        _vpaController.text = contact.vpa;
        _noteController.text = 'Payment to ${contact.name}';
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
      // Check for real installed UPI apps (GPay, PhonePe, Paytm, etc.)
      final canUpi = await UpiIntentService.instance.canLaunchUpi();
      if (canUpi && mounted) {
        final launchExternal = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.launch_rounded, color: Color(0xFF0F62FE)),
                SizedBox(width: 8),
                Text('Launch UPI App?'),
              ],
            ),
            content: Text(
              'SlicePay generated ${plan.tranches.length} tranches for ${plan.payeeName}.\n\nLaunch your installed UPI app (Google Pay / PhonePe / Paytm) to execute Tranche 1 (₹${plan.tranches.first.amount.toStringAsFixed(2)}), or proceed with SlicePay autonomous core switch?',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('SlicePay Core Switch'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F62FE),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Open UPI App'),
              ),
            ],
          ),
        );

        if (launchExternal == true) {
          final firstSlice = plan.tranches.first;
          await UpiIntentService.instance.launchUpiSlice(
            vpa: plan.payeeVpa,
            name: plan.payeeName,
            amount: firstSlice.amount,
            note: 'SlicePay Tranche 1/${plan.tranches.length}',
          );
        }
      }

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'RECENT PAYEES',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF44474E), letterSpacing: 0.5),
                    ),
                    InkWell(
                      onTap: _handlePickContact,
                      child: const Text(
                        'View Contacts',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F62FE)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (AppState.instance.contacts.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F62FE).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_search_rounded, color: Color(0xFF0F62FE), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No recent payees yet',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF16191D)),
                              ),
                              Text(
                                'Pick from contacts or scan QR to start',
                                style: TextStyle(fontSize: 11, color: Color(0xFF5F6368)),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: _handlePickContact,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            side: const BorderSide(color: Color(0xFF0F62FE)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Contacts', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F62FE))),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 84,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: AppState.instance.contacts.length + 1,
                      itemBuilder: (ctx, index) {
                        if (index == 0) {
                          return InkWell(
                            onTap: _handlePickContact,
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
                                      color: const Color(0xFF0F62FE).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF0F62FE).withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.person_search_rounded, color: Color(0xFF0F62FE), size: 22),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Contacts',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F62FE),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final contact = AppState.instance.contacts[index - 1];
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
                          Row(
                            children: [
                              InkWell(
                                onTap: _handlePickContact,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F62FE).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.contacts_rounded, size: 14, color: Color(0xFF0F62FE)),
                                      SizedBox(width: 4),
                                      Text('Contacts', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F62FE))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
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
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Payee Name',
                          hintText: 'e.g. Store Name or Contact',
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
                          hintText: 'Recipient UPI ID or mobile number',
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
                                  color: const Color(0xFF0F62FE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 14),
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
                              color: const Color(0xFFE8F0FE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'UPI Linked Account',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F62FE)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FE),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
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
                                    account.bankName,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Avail: ₹${account.balance.toStringAsFixed(2)} • ${account.vpa}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: _handleChangeAccount,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F62FE).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Text('Change', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F62FE))),
                                    Icon(Icons.chevron_right, size: 14, color: Color(0xFF0F62FE)),
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
                              decoration: const InputDecoration(border: InputBorder.none, hintText: '0'),
                              onChanged: (val) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Preset amount chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [500, 1000, 2500, 5000].map((preset) {
                          final isSelected = amount == preset.toDouble();
                          return InkWell(
                            onTap: () => setState(() => _amountController.text = preset.toString()),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF0F62FE).withValues(alpha: 0.12) : const Color(0xFFF8F9FE),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isSelected ? const Color(0xFF0F62FE) : const Color(0xFFE5E7EB)),
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
