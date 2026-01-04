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
  late final Database _db;

  Database get instance => _db;

  bool get isInitialized => _db.isOpen;

  Future<void> init() async {
    // Web 平台：使用内存数据库（功能受限）
    if (kIsWeb) {
      try {
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
        // Web 平台数据库初始化失败
        print('[DatabaseService] Web 数据库初始化失败: $e');
        // 创建一个空数据库以避免应用崩溃
        _db = await openDatabase(
          inMemoryDatabasePath,
          version: 1,
        );
      }
      return;
    }

    // 移动平台（Android/iOS/macOS/Linux）：使用文件数据库
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
  }
}
