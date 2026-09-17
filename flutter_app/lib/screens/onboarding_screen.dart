import 'package:flutter/material.dart';
import '../services/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingScreen({super.key, required this.onCompleted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();
  bool _isMerchant = false;
  bool _isSubmitting = false;

  String get _generatedUpiId {
    final clean = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (clean.length == 10) {
      return '$clean@sliceupi';
    }
    return 'yournumber@sliceupi';
  }

  void _handleSubmit() async {
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final name = _nameController.text.trim();

    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number.'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name.'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    await AppState.instance.completeOnboarding(
      phone: phone,
      name: name,
      businessName: _isMerchant ? _businessController.text.trim() : null,
      isMerchant: _isMerchant,
    );

    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // App Logo Brand Badge
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F62FE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '₹',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SlicePay',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: const Color(0xFF16191D),
                        ),
                      ),
                      const Text(
                        'Autonomous UPI Core Switch',
                        style: TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 36),

              Text(
                'Enter your mobile number to get started',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF16191D),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We use your phone number to generate your instant UPI VPA and connect your bank accounts.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5F6368),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Phone Number Input
              const Text(
                'MOBILE NUMBER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5F6368),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      child: const Row(
                        children: [
                          Text('🇮🇳', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 6),
                          Text(
                            '+91',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16191D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 28,
                      color: const Color(0xFFD1D5DB),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: '98765 43210',
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        onChanged: (val) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Full Name Input
              const Text(
                'YOUR FULL NAME',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5F6368),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'e.g. Akshay Shekhawat',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FE),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (val) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // UPI ID Preview Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F62FE).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF0F62FE).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: Color(0xFF0F62FE), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Personal SlicePay UPI ID',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5F6368)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _generatedUpiId,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F62FE),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Merchant Mode Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.storefront_rounded, color: Color(0xFF0F62FE), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enable Merchant Receive Mode',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF16191D)),
                          ),
                          Text(
                            'Accept payments via QR & soundbox',
                            style: TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isMerchant,
                      activeThumbColor: const Color(0xFF0F62FE),
                      onChanged: (val) => setState(() => _isMerchant = val),
                    ),
                  ],
                ),
              ),

              if (_isMerchant) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _businessController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Business / Store Name',
                    hintText: 'e.g. Royal General Store',
                    prefixIcon: const Icon(Icons.store_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F62FE),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Register & Launch SlicePay',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF9CA3AF)),
                    SizedBox(width: 6),
                    Text(
                      'NPCI 256-bit Encrypted • Zero Data Sharing',
                      style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
