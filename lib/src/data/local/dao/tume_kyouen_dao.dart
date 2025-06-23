import 'package:kyouen_flutter/src/data/local/entity/tume_kyouen.dart';
import 'package:sqflite/sqflite.dart';

class TumeKyouenDao {
  const TumeKyouenDao(this._database);

  final Database _database;

  static const String _tableName = TumeKyouen.tableName;

  Future<void> insertAll(List<TumeKyouen> tumeKyouens) async {
    final batch = _database.batch();
    for (final tumeKyouen in tumeKyouens) {
      batch.insert(
        _tableName,
        tumeKyouen.toJson()..remove('uid'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<void> updateAll(List<TumeKyouen> tumeKyouens) async {
    final batch = _database.batch();
    for (final tumeKyouen in tumeKyouens) {
      batch.update(
        _tableName,
        tumeKyouen.toJson(),
        where: 'uid = ?',
        whereArgs: [tumeKyouen.uid],
      );
    }
    await batch.commit();
  }

  Future<TumeKyouen?> findStage(int stageNo) async {
    final results = await _database.query(
      _tableName,
      where: 'stage_no = ?',
      whereArgs: [stageNo],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }
    return TumeKyouen.fromJson(results.first);
  }

  Future<int> selectMaxStageNo() async {
    final results = await _database.rawQuery(
      'SELECT MAX(stage_no) as max_stage_no FROM $_tableName',
    );
    return (results.first['max_stage_no'] as int?) ?? 0;
  }

  Future<Map<String, int>> selectStageCount() async {
    final results = await _database.rawQuery(
      'SELECT COUNT(*) AS count, SUM(clear_flag) AS clear_count FROM $_tableName',
    );
    final result = results.first;
    return {
      'count': result['count']! as int,
      'clear_count': (result['clear_count'] as int?) ?? 0,
    };
  }

  Future<List<TumeKyouen>> selectAllClearStage() async {
    final results = await _database.query(
      _tableName,
      where: 'clear_flag = ?',
      whereArgs: [TumeKyouen.cleared],
    );

    return results.map(TumeKyouen.fromJson).toList();
  }

  Future<void> clearStage(int stageNo, int clearDate) async {
    await _database.update(
      _tableName,
      {'clear_flag': TumeKyouen.cleared, 'clear_date': clearDate},
      where: 'stage_no = ?',
      whereArgs: [stageNo],
    );
  }
}
