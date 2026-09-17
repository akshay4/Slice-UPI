import 'package:flutter/material.dart';

class QrScanResult {
  final String vpa;
  final String name;
  final double? amount;
  final String? note;

  const QrScanResult({
    required this.vpa,
    required this.name,
    this.amount,
    this.note,
  });
}

class QrScannerModal extends StatefulWidget {
  const QrScannerModal({super.key});

  static Future<QrScanResult?> show(BuildContext context) {
    return showModalBottomSheet<QrScanResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const QrScannerModal(),
    );
  }

  @override
  State<QrScannerModal> createState() => _QrScannerModalState();
}

class _QrScannerModalState extends State<QrScannerModal> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;
  final TextEditingController _uriController = TextEditingController();

  final List<QrScanResult> _presets = const [
    QrScanResult(
      vpa: 'starbucks.retail@hdfcbank',
      name: 'Starbucks Coffee',
      amount: 2450.0,
      note: 'Mocha & Sandwiches',
    ),
    QrScanResult(
      vpa: 'apple.reseller@okicici',
      name: 'Imagine Apple Store',
      amount: 6990.0,
      note: 'AirPods Pro Case',
    ),
    QrScanResult(
      vpa: 'dmart.pos4@icici',
      name: 'DMart Supermarket',
      amount: 4200.0,
      note: 'Monthly Groceries',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _uriController.dispose();
    super.dispose();
  }

  void _parseUpiUri(String rawUri) {
    final uriString = rawUri.trim();
    if (uriString.isEmpty) return;

    try {
      final uri = Uri.parse(uriString);
      final params = uri.queryParameters;
      final pa = params['pa'] ?? uriString;
      final pn = params['pn'] ?? 'Merchant Store';
      final am = double.tryParse(params['am'] ?? '');
      final tn = params['tn'] ?? '';

      Navigator.pop(
        context,
        QrScanResult(
          vpa: pa,
          name: Uri.decodeComponent(pn),
          amount: am,
          note: Uri.decodeComponent(tn),
        ),
      );
    } catch (_) {
      Navigator.pop(
        context,
        QrScanResult(vpa: uriString, name: 'UPI Payee'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: bottomInset + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF0B57D0)),
                    SizedBox(width: 8),
                    Text(
                      'Scan Any UPI QR Code',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B1B1F)),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Animated Scanner Viewfinder Box
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF0B57D0), width: 2),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(Icons.qr_code_2, size: 120, color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (ctx, child) {
                        return Positioned(
                          top: 200 * _scanAnimation.value,
                          left: 10,
                          right: 10,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withValues(alpha: 0.8),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          'Point camera at UPI QR',
                          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sample QRs for quick testing
            const Text(
              'OR TAP A RECENT SCANNED QR:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF44474E), letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            ..._presets.map((preset) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.storefront_outlined, color: Color(0xFF0B57D0)),
                  title: Text(preset.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('${preset.vpa} • ₹${preset.amount?.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                  onTap: () => Navigator.pop(context, preset),
                ),
              );
            }),

            const SizedBox(height: 8),

            // Paste URI field
            TextField(
              controller: _uriController,
              decoration: InputDecoration(
                hintText: 'Paste UPI URI (e.g. upi://pay?pa=...)',
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                filled: true,
                fillColor: const Color(0xFFF3F4F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send_rounded, size: 18, color: Color(0xFF0B57D0)),
                  onPressed: () => _parseUpiUri(_uriController.text),
                ),
              ),
              onSubmitted: _parseUpiUri,
            ),
          ],
        ),
      ),
    );
  }
}
