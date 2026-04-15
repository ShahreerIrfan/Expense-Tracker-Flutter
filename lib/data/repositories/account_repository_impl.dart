import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../database/daos/account_dao.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountDao _accountDao;

  AccountRepositoryImpl(this._accountDao);

  AccountEntity _mapToEntity(Account a) => AccountEntity(
        id: a.id,
        userId: a.userId,
        name: a.name,
        type: a.type,
        icon: a.icon,
        color: a.color,
        balance: a.balance,
        initialBalance: a.initialBalance,
        currency: a.currency,
        accountNumber: a.accountNumber,
        bankName: a.bankName,
        includeInTotal: a.includeInTotal,
        isActive: a.isActive,
        createdAt: a.createdAt,
        updatedAt: a.updatedAt,
      );

  @override
  Future<List<AccountEntity>> getAllAccounts(int userId) async {
    final results = await _accountDao.getAllAccounts(userId);
    return results.map(_mapToEntity).toList();
  }

  @override
  Stream<List<AccountEntity>> watchAllAccounts(int userId) {
    return _accountDao
        .watchAllAccounts(userId)
        .map((list) => list.map(_mapToEntity).toList());
  }

  @override
  Future<double> getTotalBalance(int userId) =>
      _accountDao.getTotalBalance(userId);

  @override
  Future<int> addAccount(AccountEntity account) =>
      _accountDao.insertAccount(AccountsCompanion.insert(
        userId: account.userId,
        name: account.name,
        type: account.type,
        icon: Value(account.icon),
        color: Value(account.color),
        balance: Value(account.balance),
        initialBalance: Value(account.initialBalance),
        currency: Value(account.currency),
        accountNumber: Value(account.accountNumber),
        bankName: Value(account.bankName),
        includeInTotal: Value(account.includeInTotal),
      ));

  @override
  Future<void> updateAccount(AccountEntity account) async {
    if (account.id == null) return;
    final existing = await _accountDao.getAccountById(account.id!);
    final updated = existing.copyWith(
      name: account.name,
      type: account.type,
      icon: account.icon,
      color: account.color,
      balance: account.balance,
      currency: account.currency,
      accountNumber: Value(account.accountNumber),
      bankName: Value(account.bankName),
      includeInTotal: account.includeInTotal,
      updatedAt: DateTime.now(),
    );
    await _accountDao.updateAccount(updated);
  }

  @override
  Future<void> deleteAccount(int id) => _accountDao.deleteAccount(id);

  @override
  Future<AccountEntity> getAccountById(int id) async {
    final result = await _accountDao.getAccountById(id);
    return _mapToEntity(result);
  }

  @override
  Future<void> updateBalance(int accountId, double amount) =>
      _accountDao.updateBalance(accountId, amount);

  @override
  Future<void> transferBetweenAccounts(
          int fromId, int toId, double amount) =>
      _accountDao.transferBetweenAccounts(fromId, toId, amount);

  @override
  Future<void> seedDefaultAccounts(int userId) =>
      _accountDao.seedDefaultAccounts(userId);
}
