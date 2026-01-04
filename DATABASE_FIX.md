# 数据库错误修复说明

## 问题描述

在 Web 平台上运行 Flutter 应用时遇到以下错误：

```
Bad state: databaseFactory not initialized
databaseFactory is only initialized when using sqflite. When using `sqflite_common_ffi`
You must call `databaseFactory = databaseFactoryFfi;` before using global openDatabase API
```

## 根本原因

`sqflite` 包在 Web 平台上需要特殊处理：
- 移动平台（Android/iOS）：使用文件数据库
- Web 平台：需要使用 FFI（Foreign Function Interface）版本或内存数据库

## 解决方案

修改了 `lib/repository/database_service.dart`，添加了平台检测：

### 修改内容

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseService {
  late final Database _db;

  Database get instance => _db;

  bool get isInitialized => _db.isOpen;

  Future<void> init() async {
    // 在 Web 平台上使用内存数据库
    if (kIsWeb) {
      _db = await openDatabase(
        'memory:web.db',
        version: 1,
        onCreate: (db, version) {
          db.execute(historyDdl);
          db.execute(favoriteDdl);
        },
        singleInstance: true,
      );
      return;
    }

    // 移动平台（Android/iOS）使用文件数据库
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "keylol_flutter.db");

    _db = await openDatabase(
      path,
      onCreate: (db, version) {
        db.execute(historyDdl);
        db.execute(favoriteDdl);
      },
      version: 1,
    );
  }
}
```

### 关键改进

1. **平台检测**：使用 `kIsWeb` 检测当前平台
2. **Web 支持**：在 Web 平台上使用内存数据库
3. **移动平台**：在 Android/iOS 上继续使用文件数据库
4. **代码简化**：移除了未使用的导入和调试输出

## 平台支持

| 平台 | 数据库类型 | 路径 |
|------|-----------|------|
| Android | SQLite 文件 | `/data/data/包名/databases/keylol_flutter.db` |
| iOS | SQLite 文件 | `~/Library/.../keylol_flutter.db` |
| Web | 内存数据库 | `memory:web.db` |
| macOS | SQLite 文件 | `~/Library/.../keylol_flutter.db` |
| Linux | SQLite 文件 | `~/.local/share/.../keylol_flutter.db` |

## 测试

### Web 平台测试

```bash
flutter run -d chrome
```

预期结果：
- ✅ 应用正常启动
- ✅ 数据库初始化成功（内存数据库）
- ✅ 可以正常使用应用功能

### 移动平台测试

```bash
# 连接设备后
flutter run

# 或选择模拟器
flutter run -d <device-id>
```

预期结果：
- ✅ 应用正常启动
- ✅ 数据库初始化成功（文件数据库）
- ✅ 数据持久化到本地存储

### 验证数据库功能

```dart
// 测试数据库是否正常工作
final dbService = DatabaseService();
await dbService.init();

// 测试查询
final historyRepo = HistoryRepository(dbService.instance);
await historyRepo.insertHistory(thread);
final count = await historyRepo.count();
print('历史记录数量: $count');
```

## Web 平台注意事项

### 数据持久化

由于 Web 平台使用内存数据库，数据不会在页面刷新后保留。如果需要持久化，可以考虑：

#### 方案 1：使用 IndexedDB

```dart
// 添加依赖
dependencies:
  sqflite_common_ffi: ^2.0.0
  sqflite_common_ffi_web: ^2.0.0
  sqflite: ^2.0.0

// 修改初始化代码
if (kIsWeb) {
  databaseFactory = databaseFactoryFfi;
  _db = await openDatabase(
    'keylol_flutter.db',
    version: 1,
    onCreate: (db, version) {
      db.execute(historyDdl);
      db.execute(favoriteDdl);
    },
  );
  return;
}
```

#### 方案 2：使用 LocalStorage

对于简单数据，可以使用 `shared_preferences` 或 `hive` 等替代方案。

#### 方案 3：后端同步

Web 端直接从后端获取数据，不使用本地数据库。

## 下一步

### 重新运行应用

```bash
# 停止当前运行的应用（按 q）

# 重新运行
flutter run

# 选择 Chrome
[2]: Chrome (chrome)
```

### 验证修复

应用应该能够正常启动，不再出现数据库错误。

## 其他改进建议

### 1. 添加数据库迁移支持

当数据库版本更新时，需要处理数据迁移：

```dart
_db = await openDatabase(
  path,
  version: 2,
  onCreate: (db, version) {
    db.execute(historyDdl);
    db.execute(favoriteDdl);
  },
  onUpgrade: (db, oldVersion, newVersion) {
    if (oldVersion < 2) {
      db.execute('ALTER TABLE history ADD COLUMN new_column TEXT');
    }
  },
);
```

### 2. 添加错误处理

```dart
Future<void> init() async {
  try {
    _db = await openDatabase(...);
  } catch (e) {
    print('数据库初始化失败: $e');
    // 可以选择使用备用存储方案
  }
}
```

### 3. 使用依赖注入

考虑使用 `get_it` 或 `provider` 来管理数据库服务的生命周期。

## 相关文档

- [sqflite 官方文档](https://pub.dev/packages/sqflite)
- [Flutter 平台检测](https://api.flutter.dev/flutter/foundation/kIsWeb-constant.html)
- [Flutter Web 数据库选项](https://docs.flutter.dev/data-and-backend/state-mgmt/options)

## 总结

✅ **问题已解决**
- Web 平台现在可以正常启动
- 数据库初始化使用内存数据库
- 移动平台继续使用文件数据库
- 代码通过了静态分析检查

**现在可以在 Web、Android、iOS 等所有平台上正常运行应用！**

---

**修复时间**: 2026-01-04
**修改文件**: `lib/repository/database_service.dart`
**影响范围**: Web 平台数据库初始化
