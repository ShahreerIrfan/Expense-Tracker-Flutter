import 'package:drift/drift.dart';
import 'users_table.dart';
import 'accounts_table.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get type =>
      text()(); // expense, income, transfer
  IntColumn get referenceId => integer()(); // expense_id or income_id
  IntColumn get fromAccountId =>
      integer().nullable().references(Accounts, #id)();
  IntColumn get toAccountId =>
      integer().nullable().references(Accounts, #id)();
  RealColumn get amount => real()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
