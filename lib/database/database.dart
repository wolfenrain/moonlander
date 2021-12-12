// These imports are only needed to open the database
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:moonlander/database/level.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(
  tables: [
    Level,
  ],
  include: {'level_query.drift'},
)

///The main class
class MoonLanderDatabase extends _$MoonLanderDatabase {
  ///Tell the database where to store the data with this constructor
  MoonLanderDatabase() : super(_openConnection());

  // You should bump this number whenever you change or add a table definition.
  @override
  int get schemaVersion => 1;

  ///Get all levels from the database
  Future<List<LevelData>> getAllLevels() async {
    return (select(level)
          ..orderBy(
            [
              (lvl) => OrderingTerm(expression: lvl.id),
            ],
          ))
        .get();
  }
}
