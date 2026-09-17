import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/app_state.dart';

class ReceiveMoneyScreen extends StatefulWidget {
  final AppState state;

  const ReceiveMoneyScreen({super.key, required this.state});

  @override
  State<ReceiveMoneyScreen> createState() => _ReceiveMoneyScreenState();
}

class _ReceiveMoneyScreenState extends State<ReceiveMoneyScreen> {
  double? _requestedAmount;
  bool _isSoundboxActive = true;
  String? _recentPaymentAlert;

  String get _upiPayload {
    final profile = widget.state.userProfile;
    final vpa = profile?.upiId ?? widget.state.selectedAccount.vpa;
    final name = Uri.encodeComponent(profile?.displayName ?? 'Merchant');

    if (_requestedAmount != null && _requestedAmount! > 0) {
      return 'upi://pay?pa=$vpa&pn=$name&am=${_requestedAmount!.toStringAsFixed(2)}&cu=INR&tn=Merchant+Payment';
    }
    return 'upi://pay?pa=$vpa&pn=$name&cu=INR';
  }

  void _copyUpiId() {
    final profile = widget.state.userProfile;
    final vpa = profile?.upiId ?? widget.state.selectedAccount.vpa;
    Clipboard.setData(ClipboardData(text: vpa));
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('UPI ID $vpa copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF16191D),
      ),
    );
  }

  void _simulateSoundboxAlert() {
    final amt = _requestedAmount ?? 250.0;
    HapticFeedback.heavyImpact();

    setState(() {
      _recentPaymentAlert = 'Received ₹${amt.toStringAsFixed(0)} on UPI from Ramesh Rao';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: Colors.amberAccent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '🔔 Soundbox: Received ₹${amt.toStringAsFixed(0)} on UPI!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF146C2E),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSetAmountDialog() {
    final controller = TextEditingController(
      text: _requestedAmount != null ? _requestedAmount!.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.currency_rupee_rounded, color: Color(0xFF0F62FE)),
            SizedBox(width: 8),
            Text('Set Request Amount'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specify an amount so the customer does not have to enter it manually:',
              style: TextStyle(fontSize: 13, color: Color(0xFF5F6368)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: const Color(0xFFF8F9FE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (_requestedAmount != null)
            TextButton(
              onPressed: () {
                setState(() => _requestedAmount = null);
                Navigator.of(ctx).pop();
              },
              child: const Text('Clear Amount', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              setState(() => _requestedAmount = val != null && val > 0 ? val : null);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F62FE),
              foregroundColor: Colors.white,
            ),
            child: const Text('Update QR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.state.userProfile;
    final displayName = profile?.displayName ?? 'Merchant Partner';
    final vpa = profile?.upiId ?? widget.state.selectedAccount.vpa;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.qr_code_2_rounded, color: Color(0xFF0F62FE)),
            SizedBox(width: 8),
            Text(
              'Receive Payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF16191D)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSoundboxActive ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: _isSoundboxActive ? const Color(0xFF0F62FE) : Colors.grey,
            ),
            tooltip: 'Soundbox Alerts',
            onPressed: () {
              setState(() => _isSoundboxActive = !_isSoundboxActive);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isSoundboxActive ? 'Soundbox enabled' : 'Soundbox muted'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            if (_recentPaymentAlert != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF34A853)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF137333)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _recentPaymentAlert!,
                        style: const TextStyle(
                          color: Color(0xFF137333),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Color(0xFF137333)),
                      onPressed: () => setState(() => _recentPaymentAlert = null),
                    ),
                  ],
                ),
              ),
            ],
            // Merchant QR Stand Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Merchant Name Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F62FE).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.storefront_rounded, color: Color(0xFF0F62FE), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF16191D),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified_rounded, color: Color(0xFF0F62FE), size: 16),
                              ],
                            ),
                            const Text(
                              'Verified BharatQR & UPI Merchant',
                              style: TextStyle(fontSize: 11, color: Color(0xFF5F6368)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Dynamic QR Code Container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: _upiPayload,
                      version: QrVersions.auto,
                      size: 220,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF16191D),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF16191D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Optional Amount Badge
                  if (_requestedAmount != null && _requestedAmount! > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F62FE).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF0F62FE)),
                      ),
                      child: Text(
                        'Amount: ₹${_requestedAmount!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F62FE),
                        ),
                      ),
                    ),

                  // UPI ID with Copy
                  InkWell(
                    onTap: _copyUpiId,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            vpa,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16191D),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF0F62FE)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Accepted UPI Apps Footer
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Accepts GPay • PhonePe • Paytm • BHIM • Cred',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF5F6368)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Controls Card
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showSetAmountDialog,
                    icon: const Icon(Icons.edit_note_rounded),
                    label: Text(_requestedAmount != null ? 'Edit Amount' : 'Set Amount'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF0F62FE)),
                      foregroundColor: const Color(0xFF0F62FE),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _simulateSoundboxAlert,
                    icon: const Icon(Icons.speaker_phone_rounded),
                    label: const Text('Test Soundbox'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF0F62FE),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
