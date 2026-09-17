import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/split_plan.dart';
import 'screens/calculator_screen.dart';
import 'screens/switch_runner_screen.dart';
import 'screens/receipt_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const SlicePayApp());
}

class SlicePayApp extends StatelessWidget {
  const SlicePayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SlicePay UPI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B57D0),
          primary: const Color(0xFF0B57D0),
          surface: const Color(0xFFF8F9FD),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FD),
        fontFamily: 'Roboto',
      ),
      home: const MainNavigationFlow(),
    );
  }
}

class MainNavigationFlow extends StatefulWidget {
  const MainNavigationFlow({super.key});

  @override
  State<MainNavigationFlow> createState() => _MainNavigationFlowState();
}

class _MainNavigationFlowState extends State<MainNavigationFlow> {
  SplitPlan? _currentPlan;
  bool _isCompleted = false;

  void _handlePlanCreated(SplitPlan plan) {
    setState(() {
      _currentPlan = plan;
      _isCompleted = false;
    });
  }

  void _handleCompleted(SplitPlan plan) {
    setState(() {
      _currentPlan = plan;
      _isCompleted = true;
    });
  }

  void _handleReset() {
    setState(() {
      _currentPlan = null;
      _isCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPlan == null) {
      return CalculatorScreen(onProceed: _handlePlanCreated);
    }

    if (!_isCompleted) {
      return SwitchRunnerScreen(
        plan: _currentPlan!,
        onCancel: _handleReset,
        onCompleted: _handleCompleted,
      );
    }

    return ReceiptScreen(
      plan: _currentPlan!,
      onReset: _handleReset,
    );
  }
}
