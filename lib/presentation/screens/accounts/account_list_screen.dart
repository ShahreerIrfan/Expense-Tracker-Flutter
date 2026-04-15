import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../utils/formatters.dart';
import '../../../domain/entities/account.dart';

class AccountListScreen extends ConsumerWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final currency = user?.currency ?? AppConstants.defaultCurrency;
    final accountsAsync = ref.watch(accountsProvider);
    final totalBalanceAsync = ref.watch(totalBalanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: Column(
        children: [
          // Total balance header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet,
                    color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Balance',
                          style: TextStyle(color: Colors.white70)),
                      totalBalanceAsync.when(
                        data: (v) => Text(
                          AppFormatters.currency(v, currencyCode: currency),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        loading: () => const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                        error: (_, __) => const Text('---',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          // Transfer button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showTransferDialog(context, ref),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Transfer Between Accounts'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Accounts list
          Expanded(
            child: accountsAsync.when(
              data: (accounts) {
                if (accounts.isEmpty) {
                  return const Center(
                      child: Text('No accounts',
                          style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor:
                              AppFormatters.parseColor(account.color)
                                  .withValues(alpha: 0.15),
                          child: Icon(
                            AppFormatters.getIconData(account.icon),
                            color: AppFormatters.parseColor(account.color),
                          ),
                        ),
                        title: Text(account.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(account.type.toUpperCase(),
                            style: const TextStyle(fontSize: 11)),
                        trailing: Text(
                          AppFormatters.currency(account.balance,
                              currencyCode: currency),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: account.balance >= 0
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                        ),
                      ),
                    )
                        .animate(delay: Duration(milliseconds: 50 * index))
                        .fadeIn(duration: 200.ms);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_account',
        onPressed: () => Navigator.pushNamed(context, '/add-account'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showTransferDialog(BuildContext context, WidgetRef ref) async {
    final accounts = ref.read(accountsProvider).valueOrNull ?? [];
    if (accounts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Need at least 2 accounts to transfer')),
      );
      return;
    }

    int? fromId;
    int? toId;
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Transfer Funds'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: fromId,
                  decoration: const InputDecoration(labelText: 'From Account'),
                  items: accounts
                      .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(
                              '${a.name} (${AppFormatters.compactCurrency(a.balance)})')))
                      .toList(),
                  onChanged: (v) => setDialogState(() => fromId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: toId,
                  decoration: const InputDecoration(labelText: 'To Account'),
                  items: accounts
                      .where((a) => a.id != fromId)
                      .map((a) => DropdownMenuItem(
                          value: a.id, child: Text(a.name)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => toId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (double.tryParse(v) == null || double.parse(v) <= 0) {
                      return 'Invalid amount';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate() &&
                    fromId != null &&
                    toId != null) {
                  await ref.read(accountActionsProvider).transfer(
                        fromId!,
                        toId!,
                        double.parse(amountController.text),
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Transfer'),
            ),
          ],
        ),
      ),
    );
    amountController.dispose();
  }
}
