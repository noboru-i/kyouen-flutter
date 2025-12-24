import 'package:flutter/foundation.dart';
import 'package:kyouen_flutter/src/data/local/dao/tume_kyouen_dao.dart';
import 'package:kyouen_flutter/src/data/local/entity/tume_kyouen.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' as web;

part 'database.g.dart';

class AppDatabase {
  AppDatabase._(this._database);

  final Database _database;

  static const _databaseName = 'kyouen.db';
  static const _databaseVersion = 3;

  static Future<AppDatabase> create() async {
    // Initialize sqflite for web
    if (kIsWeb) {
      databaseFactory = web.databaseFactoryFfiWeb;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    final database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return AppDatabase._(database);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${TumeKyouen.tableName} (
        uid INTEGER PRIMARY KEY AUTOINCREMENT,
        stage_no INTEGER UNIQUE NOT NULL,
        size INTEGER NOT NULL,
        stage TEXT NOT NULL,
        creator TEXT NOT NULL,
        clear_flag INTEGER NOT NULL DEFAULT 0,
        clear_date INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX index_stage_no ON ${TumeKyouen.tableName} (stage_no)
    ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle database migrations here if needed
    if (oldVersion < 3) {
      // Migration logic for version 3
      await _onCreate(db, newVersion);
    }
  }

  TumeKyouenDao get tumeKyouenDao => TumeKyouenDao(_database);

  Future<void> close() async {
    await _database.close();
  }
}

@riverpod
Future<AppDatabase> appDatabase(Ref ref) async {
  final database = await AppDatabase.create();
  ref.onDispose(database.close);
  return database;
}

@riverpod
Future<TumeKyouenDao> tumeKyouenDao(Ref ref) async {
  final database = await ref.watch(appDatabaseProvider.future);
  return database.tumeKyouenDao;
}
