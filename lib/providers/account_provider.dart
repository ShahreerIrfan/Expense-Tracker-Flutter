import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/account.dart';
import 'database_provider.dart';
import 'auth_provider.dart';

// All accounts
final accountsProvider = StreamProvider<List<AccountEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.id == null) return Stream.value([]);
  return ref.watch(accountRepositoryProvider).watchAllAccounts(user!.id!);
});

// Total balance
final totalBalanceProvider = FutureProvider<double>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user?.id == null) return 0.0;
  return ref.watch(accountRepositoryProvider).getTotalBalance(user!.id!);
});

// Account actions
final accountActionsProvider =
    Provider<AccountActions>((ref) => AccountActions(ref));

class AccountActions {
  final Ref _ref;

  AccountActions(this._ref);

  Future<int> addAccount(AccountEntity account) =>
      _ref.read(accountRepositoryProvider).addAccount(account);

  Future<void> updateAccount(AccountEntity account) =>
      _ref.read(accountRepositoryProvider).updateAccount(account);

  Future<void> deleteAccount(int id) =>
      _ref.read(accountRepositoryProvider).deleteAccount(id);

  Future<void> transfer(int fromId, int toId, double amount) =>
      _ref
          .read(accountRepositoryProvider)
          .transferBetweenAccounts(fromId, toId, amount);
}
