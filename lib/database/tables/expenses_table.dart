import 'package:drift/drift.dart';
import 'users_table.dart';
import 'categories_table.dart';
import 'accounts_table.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get accountId => integer().references(Accounts, #id)();
  RealColumn get amount => real()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get isRecurring =>
      boolean().withDefault(const Constant(false))();
  TextColumn get recurringType => text().nullable()(); // daily, weekly, monthly, yearly
  IntColumn get recurringInterval => integer().nullable()();
  DateTimeColumn get nextRecurringDate => dateTime().nullable()();
  TextColumn get location => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get receiptPath => text().nullable()();
  TextColumn get tags => text().nullable()(); // JSON array of tags
  TextColumn get splitWith => text().nullable()(); // JSON array of split details
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [];
}
