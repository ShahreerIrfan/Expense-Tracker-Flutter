import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/accounts_table.dart';

part 'account_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountDao extends DatabaseAccessor<AppDatabase>
    with _$AccountDaoMixin {
  AccountDao(super.db);

  Future<List<Account>> getAllAccounts(int userId) =>
      (select(accounts)
            ..where((t) =>
                t.userId.equals(userId) & t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  Stream<List<Account>> watchAllAccounts(int userId) =>
      (select(accounts)
            ..where((t) =>
                t.userId.equals(userId) & t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<double> getTotalBalance(int userId) async {
    final query = selectOnly(accounts)
      ..addColumns([accounts.balance.sum()])
      ..where(accounts.userId.equals(userId) &
          accounts.isActive.equals(true) &
          accounts.includeInTotal.equals(true));
    final result = await query.getSingle();
    return result.read(accounts.balance.sum()) ?? 0.0;
  }

  Future<int> insertAccount(AccountsCompanion account) =>
      into(accounts).insert(account);

  Future<bool> updateAccount(Account account) =>
      update(accounts).replace(account);

  Future<int> deleteAccount(int id) =>
      (update(accounts)..where((t) => t.id.equals(id)))
          .write(const AccountsCompanion(isActive: Value(false)));

  Future<Account> getAccountById(int id) =>
      (select(accounts)..where((t) => t.id.equals(id))).getSingle();

  Future<void> updateBalance(int accountId, double amount) async {
    final account = await getAccountById(accountId);
    await (update(accounts)..where((t) => t.id.equals(accountId))).write(
      AccountsCompanion(
        balance: Value(account.balance + amount),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> transferBetweenAccounts(
      int fromId, int toId, double amount) async {
    await updateBalance(fromId, -amount);
    await updateBalance(toId, amount);
  }

  Future<void> seedDefaultAccounts(int userId) async {
    final defaults = [
      AccountsCompanion.insert(
        userId: userId,
        name: 'Cash',
        type: 'cash',
        icon: const Value('money'),
        color: const Value('#4CAF50'),
      ),
      AccountsCompanion.insert(
        userId: userId,
        name: 'Bank Account',
        type: 'bank',
        icon: const Value('account_balance'),
        color: const Value('#2196F3'),
      ),
      AccountsCompanion.insert(
        userId: userId,
        name: 'bKash',
        type: 'mobile_wallet',
        icon: const Value('phone_android'),
        color: const Value('#E91E63'),
      ),
      AccountsCompanion.insert(
        userId: userId,
        name: 'Nagad',
        type: 'mobile_wallet',
        icon: const Value('phone_android'),
        color: const Value('#FF9800'),
      ),
    ];
    for (final account in defaults) {
      await into(accounts).insert(account);
    }
  }
}
