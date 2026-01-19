# Keylol Flutter 数据库分析报告

## 1. 为什么使用本地数据库

### 1.1 业务功能需求

**浏览历史记录 (History)**
- 存储用户浏览过的帖子信息
- 支持搜索、分页、排序功能
- 提供快速回溯浏览记录的能力
- 位置: `lib/repository/history_repository.dart`

**收藏功能 (Favorite)**
- 缓存用户从服务器获取的收藏列表
- 支持离线查看收藏的帖子
- 自动更新机制（每小时检查一次）
- 位置: `lib/repository/favorite_repository.dart`

### 1.2 性能优势

**响应速度**
- 本地查询毫秒级响应 vs 网络请求秒级响应
- 支持复杂查询（LIKE、排序、分页）

**减少网络请求**
- 收藏列表只定期从服务器同步
- 历史记录完全本地化
- 节省流量，提升用户体验

**离线支持**
- Web 平台：内存数据库（数据不持久化）
- 移动平台：文件数据库（数据持久化）

### 1.3 用户体验

**搜索功能**
```dart
// lib/repository/history_repository.dart:30:32
final result = await _db.rawQuery(
  'SELECT COUNT(0) FROM history WHERE subject LIKE %$text%'
);
```

**分页显示**
```dart
// lib/repository/history_repository.dart:36:52
Future<List<Map<String, dynamic>>> histories({
  String? text,
  int? page,
  int limit = 100,
}) async {
  int? offset = page == null ? null : (page - 1) * limit;
  final list = await _db.query(
    'history',
    where: text != null ? 'subject LIKE ?' : null,
    whereArgs: text != null ? ['%$text%'] : null,
    orderBy: 'rowId DESC',
    offset: offset,
    limit: limit,
  );
  return list;
}
```

## 2. 数据库表结构

### 2.1 History 表（浏览历史）

| 字段名 | 类型 | 说明 | 约束 |
|--------|------|------|------|
| tid | TEXT | 帖子ID | PRIMARY KEY |
| fid | TEXT | 版块ID | - |
| author_id | TEXT | 作者ID | - |
| author | TEXT | 作者名称 | - |
| subject | TEXT | 帖子标题 | - |
| dateline | TEXT | 发帖时间 | - |
| date | TEXT | 浏览时间 | - |

### 2.2 Favorite 表（收藏帖子）

| 字段名 | 类型 | 说明 | 约束 |
|--------|------|------|------|
| fav_id | TEXT | 收藏ID | PRIMARY KEY |
| uid | TEXT | 用户ID | - |
| id | TEXT | 帖子ID | - |
| id_type | TEXT | 类型 | - |
| space_uid | TEXT | 空间用户ID | - |
| title | TEXT | 标题 | - |
| description | TEXT | 描述 | - |
| dateline | TEXT | 收藏时间 | - |
| icon | TEXT | 图标URL | - |
| url | TEXT | 帖子链接 | - |
| author | TEXT | 作者 | - |

## 3. 数据库初始化分析

### 3.1 当前初始化流程

```dart
// lib/main.dart:35:36
final databaseService = DatabaseService();
await databaseService.init();
```

```dart
// lib/repository/database_service.dart:39:76
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
      print('[DatabaseService] Web 数据库初始化失败: $e');
      _db = await openDatabase(inMemoryDatabasePath, version: 1);
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
```

### 3.2 当前失败处理机制

**优点**
- 平台差异化处理（Web vs 移动）
- 异常捕获避免崩溃
- 降级方案保证应用可运行

**不足**
- 错误信息简单，仅打印日志
- 缺少用户友好的错误提示
- Web 平台数据不持久化但未明确告知用户
- 缺少数据库完整性检查
- 没有数据库迁移机制（version:1 但未实现 onUpgrade）

### 3.3 初始化失败的影响

**功能影响**
- Web 平台：历史记录和收藏数据在页面刷新后丢失
- 初始化失败：无法浏览历史、无法查看收藏

**用户体验影响**
- 无提示用户数据库功能受限
- 数据丢失可能导致困惑

## 4. 改进建议

### 4.1 增强错误处理

```dart
class DatabaseInitializationException implements Exception {
  final String message;
  DatabaseInitializationException(this.message);
  
  @override
  String toString() => '数据库初始化失败: $message';
}

Future<void> init() async {
  try {
    if (kIsWeb) {
      await _initWebDatabase();
    } else {
      await _initMobileDatabase();
    }
  } catch (e, stackTrace) {
    talker.error('数据库初始化失败', e, stackTrace);
    // 可以在这里触发错误提示
    rethrow;
  }
}
```

### 4.2 添加数据库迁移机制

```dart
const int dbVersion = 2; // 每次表结构变更递增

_db = await openDatabase(
  path,
  onCreate: (db, version) async {
    await db.execute(historyDdl);
    await db.execute(favoriteDdl);
  },
  onUpgrade: (db, oldVersion, newVersion) async {
    // 处理版本升级
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE history ADD COLUMN tags TEXT');
    }
  },
  version: dbVersion,
);
```

### 4.3 添加数据库健康检查

```dart
Future<bool> healthCheck() async {
  try {
    await _db.rawQuery('SELECT 1');
    return true;
  } catch (e) {
    talker.error('数据库健康检查失败', e);
    return false;
  }
}
```

### 4.4 Web 平台持久化方案

考虑使用 IndexedDB 或 LocalStorage 作为 Web 平台的持久化方案：
- 安装 `sqflite_common_ffi` 和 `sqflite_common_ffi_web`
- 或使用 Hive (支持 Web 持久化)
- 或明确告知用户 Web 平台数据不持久化

## 5. 数据库初始化脚本

已创建独立初始化脚本：`database_init.sh`

**使用方法**
```bash
chmod +x database_init.sh
./database_init.sh
```

**脚本功能**
- 显示数据库版本和表结构说明
- 输出完整的 SQL DDL 语句
- 平台差异说明

## 6. 总结

**数据库使用原因**
1. 浏览历史记录本地化
2. 收藏功能缓存支持离线
3. 性能优化（快速查询、分页、搜索）
4. 用户体验提升

**初始化失败处理**
- 当前：捕获异常，创建空数据库
- 建议：增强错误处理、添加迁移机制、健康检查

**初始化脚本**
- 已创建 `database_init.sh`
- 包含完整的 DDL 和表结构说明
- 可用于文档和测试
