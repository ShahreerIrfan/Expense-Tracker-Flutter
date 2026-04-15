import '../entities/account.dart';

abstract class AccountRepository {
  Future<List<AccountEntity>> getAllAccounts(int userId);
  Stream<List<AccountEntity>> watchAllAccounts(int userId);
  Future<double> getTotalBalance(int userId);
  Future<int> addAccount(AccountEntity account);
  Future<void> updateAccount(AccountEntity account);
  Future<void> deleteAccount(int id);
  Future<AccountEntity> getAccountById(int id);
  Future<void> updateBalance(int accountId, double amount);
  Future<void> transferBetweenAccounts(int fromId, int toId, double amount);
  Future<void> seedDefaultAccounts(int userId);
}
