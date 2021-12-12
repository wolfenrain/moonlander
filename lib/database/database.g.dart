// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class LevelData extends DataClass implements Insertable<LevelData> {
  ///PK of the table
  final int id;

  ///Seed of the level
  final int seed;

  ///Highscore of the player if level was solved
  final int? highscore;
  LevelData({required this.id, required this.seed, this.highscore});
  factory LevelData.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return LevelData(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      seed: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}seed'])!,
      highscore: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}highscore']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['seed'] = Variable<int>(seed);
    if (!nullToAbsent || highscore != null) {
      map['highscore'] = Variable<int?>(highscore);
    }
    return map;
  }

  LevelCompanion toCompanion(bool nullToAbsent) {
    return LevelCompanion(
      id: Value(id),
      seed: Value(seed),
      highscore: highscore == null && nullToAbsent
          ? const Value.absent()
          : Value(highscore),
    );
  }

  factory LevelData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LevelData(
      id: serializer.fromJson<int>(json['id']),
      seed: serializer.fromJson<int>(json['seed']),
      highscore: serializer.fromJson<int?>(json['highscore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'seed': serializer.toJson<int>(seed),
      'highscore': serializer.toJson<int?>(highscore),
    };
  }

  LevelData copyWith({int? id, int? seed, int? highscore}) => LevelData(
        id: id ?? this.id,
        seed: seed ?? this.seed,
        highscore: highscore ?? this.highscore,
      );
  @override
  String toString() {
    return (StringBuffer('LevelData(')
          ..write('id: $id, ')
          ..write('seed: $seed, ')
          ..write('highscore: $highscore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, seed, highscore);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LevelData &&
          other.id == this.id &&
          other.seed == this.seed &&
          other.highscore == this.highscore);
}

class LevelCompanion extends UpdateCompanion<LevelData> {
  final Value<int> id;
  final Value<int> seed;
  final Value<int?> highscore;
  const LevelCompanion({
    this.id = const Value.absent(),
    this.seed = const Value.absent(),
    this.highscore = const Value.absent(),
  });
  LevelCompanion.insert({
    this.id = const Value.absent(),
    required int seed,
    this.highscore = const Value.absent(),
  }) : seed = Value(seed);
  static Insertable<LevelData> custom({
    Expression<int>? id,
    Expression<int>? seed,
    Expression<int?>? highscore,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seed != null) 'seed': seed,
      if (highscore != null) 'highscore': highscore,
    });
  }

  LevelCompanion copyWith(
      {Value<int>? id, Value<int>? seed, Value<int?>? highscore}) {
    return LevelCompanion(
      id: id ?? this.id,
      seed: seed ?? this.seed,
      highscore: highscore ?? this.highscore,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (seed.present) {
      map['seed'] = Variable<int>(seed.value);
    }
    if (highscore.present) {
      map['highscore'] = Variable<int?>(highscore.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LevelCompanion(')
          ..write('id: $id, ')
          ..write('seed: $seed, ')
          ..write('highscore: $highscore')
          ..write(')'))
        .toString();
  }
}

class $LevelTable extends Level with TableInfo<$LevelTable, LevelData> {
  final GeneratedDatabase _db;
  final String? _alias;
  $LevelTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<int?> seed = GeneratedColumn<int?>(
      'seed', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _highscoreMeta = const VerificationMeta('highscore');
  @override
  late final GeneratedColumn<int?> highscore = GeneratedColumn<int?>(
      'highscore', aliasedName, true,
      type: const IntType(), requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, seed, highscore];
  @override
  String get aliasedName => _alias ?? 'level';
  @override
  String get actualTableName => 'level';
  @override
  VerificationContext validateIntegrity(Insertable<LevelData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('seed')) {
      context.handle(
          _seedMeta, seed.isAcceptableOrUnknown(data['seed']!, _seedMeta));
    } else if (isInserting) {
      context.missing(_seedMeta);
    }
    if (data.containsKey('highscore')) {
      context.handle(_highscoreMeta,
          highscore.isAcceptableOrUnknown(data['highscore']!, _highscoreMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LevelData map(Map<String, dynamic> data, {String? tablePrefix}) {
    return LevelData.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $LevelTable createAlias(String alias) {
    return $LevelTable(_db, alias);
  }
}

abstract class _$MoonLanderDatabase extends GeneratedDatabase {
  _$MoonLanderDatabase(QueryExecutor e)
      : super(SqlTypeSystem.defaultInstance, e);
  late final $LevelTable level = $LevelTable(this);
  Selectable<LevelData> getTopTenScore() {
    return customSelect(
        'SELECT * FROM level WHERE level.highscore <> null ORDER BY level.highscore DESC LIMIT 10',
        variables: [],
        readsFrom: {
          level,
        }).map(level.mapFromRow);
  }

  Future<int> updateScoreForLevel(int? newHighscore, int levelId) {
    return customUpdate(
      'UPDATE level SET highscore=:newHighscore WHERE id=:levelId',
      variables: [Variable<int?>(newHighscore), Variable<int>(levelId)],
      updates: {level},
      updateKind: UpdateKind.update,
    );
  }

  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [level];
}
