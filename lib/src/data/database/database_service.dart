import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'stage_entity.dart';

part 'database_service.g.dart';

@riverpod
DatabaseService databaseService(Ref ref) {
  return DatabaseService();
}

class DatabaseService {
  static const String _databaseName = 'kyouen.db';
  static const int _databaseVersion = 3;
  static const String _tableName = 'tume_kyouen';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        uid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        stage_no INTEGER NOT NULL,
        size INTEGER NOT NULL,
        stage TEXT NOT NULL,
        creator TEXT NOT NULL,
        clear_flag INTEGER NOT NULL,
        clear_date INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX index_tume_kyouen_stage_no 
      ON $_tableName (stage_no)
    ''');
  }

  Future<int> insertStage(StageEntity stage) async {
    final db = await database;
    return await db.insert(
      _tableName,
      stage.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<StageEntity>> getStages({int? startStageNo, int? limit}) async {
    final db = await database;
    
    String? where;
    List<Object?>? whereArgs;
    
    if (startStageNo != null) {
      where = 'stage_no >= ?';
      whereArgs = [startStageNo];
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'stage_no ASC',
      limit: limit,
    );

    return maps.map((map) => StageEntity.fromMap(map)).toList();
  }

  Future<StageEntity?> getStage(int stageNo) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'stage_no = ?',
      whereArgs: [stageNo],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return StageEntity.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateStage(StageEntity stage) async {
    final db = await database;
    return await db.update(
      _tableName,
      stage.toMap(),
      where: 'uid = ?',
      whereArgs: [stage.uid],
    );
  }

  Future<int> updateClearStatus(int stageNo, bool isCleared) async {
    final db = await database;
    return await db.update(
      _tableName,
      {
        'clear_flag': isCleared ? 1 : 0,
        'clear_date': isCleared ? DateTime.now().millisecondsSinceEpoch : 0,
      },
      where: 'stage_no = ?',
      whereArgs: [stageNo],
    );
  }

  Future<int> deleteStage(int stageNo) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'stage_no = ?',
      whereArgs: [stageNo],
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}