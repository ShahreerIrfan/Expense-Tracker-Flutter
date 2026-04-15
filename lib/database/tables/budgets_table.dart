import 'package:drift/drift.dart';
import 'users_table.dart';
import 'categories_table.dart';

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  RealColumn get amount => real()();
  RealColumn get spent => real().withDefault(const Constant(0.0))();
  TextColumn get period => text()(); // weekly, monthly, yearly
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  BoolColumn get rollover =>
      boolean().withDefault(const Constant(false))();
  RealColumn get rolloverAmount => real().withDefault(const Constant(0.0))();
  BoolColumn get alertAt50 =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get alertAt80 =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get alertAt100 =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
