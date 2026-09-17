import 'package:flutter/material.dart';
import '../services/app_state.dart';
import 'onboarding_screen.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _controller.forward();
    _checkNavigation();
  }

  void _checkNavigation() async {
    // Wait minimum 1.8 seconds for smooth splash experience
    await Future.delayed(const Duration(milliseconds: 1800));

    // Wait until AppState is ready
    while (!AppState.instance.isReady) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (ctx, anim1, anim2) => FadeTransition(
          opacity: anim1,
          child: AppState.instance.isOnboarded
              ? const RootNavigationHost()
              : OnboardingScreen(onCompleted: () {}),
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF060D1E),
              Color(0xFF0A1938),
              Color(0xFF040A18),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),
              // Center Branding
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Glowing Hero App Icon
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F62FE).withValues(alpha: 0.45),
                                  blurRadius: 40,
                                  spreadRadius: 8,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.asset(
                                'assets/images/app_logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Brand Typography
                          const Text(
                            'SlicePay',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F62FE).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF0F62FE).withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'AUTONOMOUS UPI CORE SWITCH',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF73A5FF),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                          // Subtle Activity Indicator
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F62FE)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Bottom Security Certification
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF146C2E).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF4CAF50)),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NPCI UPI 2.0 PROTOCOL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA0AEC0),
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'Hardware Level SIM Binding · 256-bit Encrypted',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
