import 'package:drift/drift.dart';

///Table in your database, named by default as your class
class Highscore extends Table {
  ///PK of the table
  IntColumn get id => integer().autoIncrement()();

  ///Seed of the level
  TextColumn get seed => text()();

  ///Highscore of the player if level was solved
  IntColumn get score => integer().nullable()();

  ///Datetime the high score with entered
  DateTimeColumn get creationDate =>
      dateTime().withDefault(currentDateAndTime)();
}
