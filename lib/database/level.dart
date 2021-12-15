import 'package:drift/drift.dart';

///Table in your database, named by default as your class
class Level extends Table {
  ///PK of the table
  IntColumn get id => integer().autoIncrement()();

  ///Seed of the level
  TextColumn get seed => text()();

  ///Highscore of the player if level was solved
  IntColumn get highscore => integer().nullable()();
}
