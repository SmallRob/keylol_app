import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';

// Web 平台特定的导入
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' as sqflite_ffi_web;

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
    // Web 平台：使用 Web 版本的 FFI
    if (kIsWeb) {
      // 初始化 Web FFI
      sqflite_ffi_web.sqfliteFfiInit();
      databaseFactory = sqflite_ffi_web.databaseFactoryFfi;
      
      _db = await openDatabase(
        'keylol_flutter.db',
        version: 1,
        onCreate: (db, version) async {
          await db.execute(historyDdl);
          await db.execute(favoriteDdl);
        },
      );
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
