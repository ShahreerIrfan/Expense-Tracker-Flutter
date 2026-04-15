import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/transactions_table.dart';
import '../tables/accounts_table.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions, Accounts])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Future<List<Transaction>> getAllTransactions(int userId) =>
      (select(transactions)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Stream<List<Transaction>> watchAllTransactions(int userId) =>
      (select(transactions)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<List<Transaction>> getTransactionsByDateRange(
      int userId, DateTime start, DateTime end) =>
      (select(transactions)
            ..where((t) =>
                t.userId.equals(userId) &
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerOrEqualValue(end))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Future<List<Transaction>> getTransactionsByAccount(
      int userId, int accountId) =>
      (select(transactions)
            ..where((t) =>
                t.userId.equals(userId) &
                (t.fromAccountId.equals(accountId) |
                    t.toAccountId.equals(accountId)))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Future<int> insertTransaction(TransactionsCompanion transaction) =>
      into(transactions).insert(transaction);

  Future<int> deleteTransaction(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  Future<int> deleteByReference(String type, int referenceId) =>
      (delete(transactions)
            ..where(
                (t) => t.type.equals(type) & t.referenceId.equals(referenceId)))
          .go();
}
