import 'package:flutter/material.dart';

import '../widgets/bottom_nav_bar.dart';
import '../widgets/glow_background.dart';
import 'account_screen.dart';
import 'analytics_screen.dart';
import 'calculator_screen.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  static const String routeName = '/main';

  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<NavItem> _items = [
    NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    NavItem(
      icon: Icons.directions_car_outlined,
      activeIcon: Icons.directions_car_rounded,
      label: 'Calculator',
    ),
    NavItem(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
      label: 'Analytics',
    ),
    NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Account',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlowBackground(
        variant: GlowVariant.pageTop,
        child: IndexedStack(
          index: _index,
          children: const [
            HomeScreen(),
            CalculatorScreen(),
            AnalyticsScreen(),
            AccountScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        index: _index,
        items: _items,
        onChanged: (value) => setState(() => _index = value),
      ),
    );
  }
}
