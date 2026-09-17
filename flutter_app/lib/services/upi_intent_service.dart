import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class UpiIntentService {
  UpiIntentService._();
  static final UpiIntentService instance = UpiIntentService._();

  /// Check if device can launch a UPI intent URI
  Future<bool> canLaunchUpi() async {
    try {
      final testUri = Uri.parse('upi://pay?pa=test@upi&pn=Test&am=1.00&cu=INR');
      return await canLaunchUrl(testUri);
    } catch (e) {
      debugPrint('Error checking UPI launcher: $e');
      return false;
    }
  }

  /// Launch a payment slice via the native Android UPI intent
  Future<bool> launchUpiSlice({
    required String vpa,
    required String name,
    required double amount,
    required String note,
    String? transactionRef,
  }) async {
    final tr = transactionRef ?? 'SLICE${DateTime.now().millisecondsSinceEpoch}';
    final query = <String, String>{
      'pa': vpa,
      'pn': name,
      'am': amount.toStringAsFixed(2),
      'cu': 'INR',
      'tn': note,
      'tr': tr,
    };

    final upiUri = Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: query,
    );

    debugPrint('Launching UPI Intent: $upiUri');

    try {
      final launched = await launchUrl(
        upiUri,
        mode: LaunchMode.externalApplication,
      );
      return launched;
    } catch (e) {
      debugPrint('Failed to launch UPI URL: $e');
      return false;
    }
  }
}
