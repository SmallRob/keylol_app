import 'package:keylol_api/keylol_api.dart';
import 'package:sqflite/sqflite.dart';

class HistoryRepository {
  final Database? _db;

  HistoryRepository(this._db);

  Future<void> insertHistory(Thread thread) async {
    if (_db == null) return;
    try {
      await _db!.insert(
        'history',
        {
          'tid': thread.tid,
          'fid': thread.fid,
          'author_id': thread.authorId,
          'author': thread.author,
          'subject': thread.subject,
          'dateline': thread.dateline,
          'date': DateTime.now().toString()
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // 忽略或记录错误
    }
  }

  Future<int> count({String? text}) async {
    if (_db == null) return 0;
    if (text == null) {
      final result = await _db!.rawQuery('SELECT COUNT(0) FROM history');
      return Sqflite.firstIntValue(result) ?? 0;
    } else {
      final result = await _db!
          .rawQuery('SELECT COUNT(0) FROM history WHERE subject LIKE %$text%');
      return Sqflite.firstIntValue(result) ?? 0;
    }
  }

  Future<List<Map<String, dynamic>>> histories({
    String? text,
    int? page,
    int limit = 100,
  }) async {
    if (_db == null) return [];
    int? offset = page == null ? null : (page - 1) * limit;
    final list = await _db!.query(
      'history',
      where: text != null ? 'subject LIKE ?' : null,
      whereArgs: text != null ? ['%$text%'] : null,
      orderBy: 'rowId DESC',
      offset: offset,
      limit: limit,
    );

    return list;
  }
}
