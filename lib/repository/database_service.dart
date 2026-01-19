import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';

const String historyDdl = '''
CREATE TABLE history (
  tid TEXT PRIMARY KEY, 
  fid TEXT, 
  author_id TEXT, 
  author TEXT, 
  subject TEXT, 
  dateline TEXT, 
  date TEXT
);
''';

const String favoriteDdl = '''
CREATE TABLE favorite (
  fav_id TEXT PRIMARY KEY, 
  uid TEXT, 
  id TEXT, 
  id_type TEXT, 
  space_uid TEXT, 
  title TEXT, 
  description TEXT, 
  dateline TEXT, 
  icon TEXT, 
  url TEXT, 
  author TEXT
);
''';

class DatabaseService {
  Database? _db;

  /// 获取数据库实例。支持可空返回以提高 Web 平台的鲁棒性。
  Database? get instance => _db;

  bool get isInitialized => _db != null && _db!.isOpen;

  Future<void> init() async {
    // Web 平台：尝试使用内存数据库
    if (kIsWeb) {
      try {
        // 在 Web 平台，如果没有设置 databaseFactory，这里必定报错
        _db = await openDatabase(
          inMemoryDatabasePath,
          version: 1,
          onCreate: (db, version) async {
            await db.execute(historyDdl);
            await db.execute(favoriteDdl);
          },
        );
        print('[DatabaseService] Web 平台使用内存数据库（数据不持久化）');
      } catch (e) {
        print('[DatabaseService] Web 数据库不可用 (缺少 sqflite_common_ffi_web 支持): $e');
        // 不再重试，保持 _db 为 null
      }
      return;
    }

    // 移动平台（Android/iOS/macOS/Linux）：使用文件数据库
    try {
      final databasesPath = await getDatabasesPath();
      final path = '$databasesPath/keylol_flutter.db';

      _db = await openDatabase(
        path,
        onCreate: (db, version) async {
          await db.execute(historyDdl);
          await db.execute(favoriteDdl);
        },
        version: 1,
      );
    } catch (e) {
      print('[DatabaseService] 移动端数据库初始化失败: $e');
      rethrow;
    }
  }
}
