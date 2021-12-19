import 'package:drift/web.dart';
import 'package:moonlander/database/database.dart';

///Create database
MoonLanderDatabase constructDb() {
  return MoonLanderDatabase(
    WebDatabase.withStorage(
      DriftWebStorage.indexedDb(
        'db',
        migrateFromLocalStorage: false,
      ),
    ),
  );
}
