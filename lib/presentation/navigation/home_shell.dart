import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/expenses/expense_list_screen.dart';
import '../screens/income/income_list_screen.dart';
import '../screens/budgets/budget_list_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../../core/constants/colors.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    ExpenseListScreen(),
    IncomeListScreen(),
    BudgetListScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.arrow_upward_outlined),
            selectedIcon: Icon(Icons.arrow_upward),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.arrow_downward_outlined),
            selectedIcon: Icon(Icons.arrow_downward),
            label: 'Income',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_main',
        onPressed: () => _showQuickAdd(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showQuickAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Quick Add',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _QuickAddButton(
                    icon: Icons.arrow_upward,
                    label: 'Expense',
                    color: AppColors.expense,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, '/add-expense');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickAddButton(
                    icon: Icons.arrow_downward,
                    label: 'Income',
                    color: AppColors.income,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, '/add-income');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAddButton(
                    icon: Icons.swap_horiz,
                    label: 'Transfer',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, '/accounts');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickAddButton(
                    icon: Icons.mic,
                    label: 'Voice',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(ctx);
                      // TODO: voice input
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
