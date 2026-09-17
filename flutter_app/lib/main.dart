import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/split_plan.dart';
import 'services/app_state.dart';
import 'screens/calculator_screen.dart';
import 'screens/switch_runner_screen.dart';
import 'screens/receipt_screen.dart';
import 'screens/history_screen.dart';
import 'screens/accounts_screen.dart';

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
      home: const RootNavigationHost(),
    );
  }
}

class RootNavigationHost extends StatefulWidget {
  const RootNavigationHost({super.key});

  @override
  State<RootNavigationHost> createState() => _RootNavigationHostState();
}

class _RootNavigationHostState extends State<RootNavigationHost> {
  int _currentIndex = 0;

  void _handlePlanProceed(SplitPlan plan) async {
    final completedPlan = await Navigator.push<SplitPlan>(
      context,
      MaterialPageRoute(
        builder: (ctx) => SwitchRunnerScreen(
          plan: plan,
          onCancel: () => Navigator.pop(ctx),
          onCompleted: (result) => Navigator.pop(ctx, result),
        ),
      ),
    );

    if (completedPlan != null && mounted) {
      // 1. Record payment & deduct real balance
      AppState.instance.recordSuccessfulPayment(completedPlan);

      // 2. Open Receipt Screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => ReceiptScreen(
            plan: completedPlan,
            onReset: () => Navigator.pop(ctx),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      CalculatorScreen(onProceed: _handlePlanProceed),
      HistoryScreen(state: AppState.instance),
      AccountsScreen(state: AppState.instance),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: Colors.white,
        elevation: 2,
        indicatorColor: const Color(0xFFD3E3FD),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.flash_on_outlined),
            selectedIcon: Icon(Icons.flash_on_rounded, color: Color(0xFF041E49)),
            label: 'Pay',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded, color: Color(0xFF041E49)),
            label: 'Passbook',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance_rounded, color: Color(0xFF041E49)),
            label: 'Accounts',
          ),
        ],
      ),
    );
  }
}
