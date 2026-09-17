import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QrPaymentPayload {
  final String vpa;
  final String name;
  final double? amount;
  final String? note;

  const QrPaymentPayload({
    required this.vpa,
    required this.name,
    this.amount,
    this.note,
  });
}

class QrScannerModal extends StatefulWidget {
  const QrScannerModal({super.key});

  static Future<QrPaymentPayload?> show(BuildContext context) {
    return showModalBottomSheet<QrPaymentPayload>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const QrScannerModal(),
    );
  }

  @override
  State<QrScannerModal> createState() => _QrScannerModalState();
}

class _QrScannerModalState extends State<QrScannerModal>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _animController;
  bool _isTorchOn = false;
  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    setState(() => _isCheckingPermission = true);
    final status = await Permission.camera.status;
    if (status.isGranted) {
      if (mounted) {
        setState(() {
          _hasPermission = true;
          _isCheckingPermission = false;
        });
      }
      return;
    }

    final req = await Permission.camera.request();
    if (mounted) {
      setState(() {
        _hasPermission = req.isGranted;
        _isCheckingPermission = false;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null && raw.isNotEmpty) {
        _handleScannedRaw(raw);
        break;
      }
    }
  }

  void _handleScannedRaw(String raw) {
    setState(() => _hasScanned = true);
    HapticFeedback.mediumImpact();

    final payload = _parseUpiString(raw);
    Navigator.of(context).pop(payload);
  }

  QrPaymentPayload _parseUpiString(String raw) {
    String vpa = '';
    String name = 'Merchant Store';
    double? amount;
    String? note;

    if (raw.startsWith('upi://pay?')) {
      final uri = Uri.tryParse(raw);
      if (uri != null) {
        vpa = uri.queryParameters['pa'] ?? '';
        name = uri.queryParameters['pn'] ?? 'UPI Merchant';
        final amStr = uri.queryParameters['am'];
        if (amStr != null) {
          amount = double.tryParse(amStr);
        }
        note = uri.queryParameters['tn'];
      }
    } else if (raw.contains('@')) {
      // Plain VPA scanned directly
      vpa = raw.trim();
      name = vpa.split('@')[0];
    } else {
      vpa = '$raw@upi';
      name = 'Scanned Merchant';
    }

    return QrPaymentPayload(
      vpa: vpa.isEmpty ? 'merchant@upi' : vpa,
      name: name,
      amount: amount,
      note: note,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0F1216),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Scan BharatQR / UPI QR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_hasPermission) ...[
                  IconButton(
                    icon: Icon(
                      _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      color: _isTorchOn ? Colors.amber : Colors.white70,
                    ),
                    onPressed: () async {
                      await _scannerController.toggleTorch();
                      setState(() => _isTorchOn = !_isTorchOn);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.flip_camera_android_rounded, color: Colors.white70),
                    onPressed: () => _scannerController.switchCamera(),
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Viewfinder Camera Area
          Expanded(
            child: _buildCameraBody(),
          ),
          // Bottom quick presets / fallback
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildCameraBody() {
    if (_isCheckingPermission) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (!_hasPermission) {
      return Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.videocam_off_rounded, size: 48, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Text(
              'Camera Access Required',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'SlicePay needs real camera access to scan physical BharatQR, Google Pay, PhonePe, and merchant stickers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _checkCameraPermission,
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Enable Camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F62FE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Open System Settings', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Live Real Hardware Camera
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
        ),
        // Darkened Overlay Frame
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.55),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Corner Borders
        SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            children: [
              // Top-left
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF0F62FE), width: 4),
                      left: BorderSide(color: Color(0xFF0F62FE), width: 4),
                    ),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(12)),
                  ),
                ),
              ),
              // Top-right
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF0F62FE), width: 4),
                      right: BorderSide(color: Color(0xFF0F62FE), width: 4),
                    ),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(12)),
                  ),
                ),
              ),
              // Bottom-left
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF0F62FE), width: 4),
                      left: BorderSide(color: Color(0xFF0F62FE), width: 4),
                    ),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12)),
                  ),
                ),
              ),
              // Bottom-right
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF0F62FE), width: 4),
                      right: BorderSide(color: Color(0xFF0F62FE), width: 4),
                    ),
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(12)),
                  ),
                ),
              ),
              // Animated Laser
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Positioned(
                    top: _animController.value * 250,
                    left: 4,
                    right: 4,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xFF0F62FE),
                            Color(0xFF00D4B2),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F62FE).withValues(alpha: 0.8),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // Instruction Pill
        Positioned(
          bottom: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.center_focus_strong, color: Color(0xFF00D4B2), size: 16),
                SizedBox(width: 8),
                Text(
                  'Point camera at any UPI or BharatQR code',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF161A20),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_auto_rounded, color: Color(0xFF0F62FE), size: 18),
              const SizedBox(width: 8),
              const Text(
                'Or test with instant merchant presets:',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _handleScannedRaw('upi://pay?pa=starbucks@okhdfcbank&pn=Starbucks%20Coffee&am=3500.00&cu=INR&tn=Starbucks+Order');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Starbucks ₹3500', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _handleScannedRaw('upi://pay?pa=croma.retail@icici&pn=Croma%20Electronics&am=5499.00&cu=INR&tn=Croma+Store');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Croma ₹5499', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
