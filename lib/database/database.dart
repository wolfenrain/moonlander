import 'dart:math';
import 'package:drift/drift.dart';
import 'package:moonlander/database/level.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Level,
  ],
  include: {'level_query.drift'},
)

///The main class
class MoonLanderDatabase extends _$MoonLanderDatabase {
  ///Tell the database where to store the data with this constructor
  MoonLanderDatabase(QueryExecutor e) : super(e);

  // You should bump this number whenever you change or add a table definition.
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          final r = Random();
          //Create default levels
          final initialSeeds = List<String>.generate(
            25,
            (index) => String.fromCharCodes(
              List.generate(5, (index) => r.nextInt(25) + 65), //From A to Z
            ),
          );
          await batch(
            (batch) => initialSeeds.forEach(
              (seed) => batch.insert(
                level,
                LevelCompanion.insert(
                  seed: seed,
                ),
              ),
            ),
          );
        },
      );

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
