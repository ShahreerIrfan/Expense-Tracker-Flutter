import 'package:drift/drift.dart';
import 'users_table.dart';
import 'categories_table.dart';
import 'accounts_table.dart';

class Incomes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get accountId => integer().references(Accounts, #id)();
  RealColumn get amount => real()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  TextColumn get source => text().nullable()(); // salary, freelance, investment, etc.
  DateTimeColumn get date => dateTime()();
  BoolColumn get isRecurring =>
      boolean().withDefault(const Constant(false))();
  TextColumn get recurringType => text().nullable()();
  IntColumn get recurringInterval => integer().nullable()();
  DateTimeColumn get nextRecurringDate => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
