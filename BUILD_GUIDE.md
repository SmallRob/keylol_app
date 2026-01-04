# Keylol Flutter App - 构建指南

## 项目概述

Keylol Flutter App 是一个使用 Flutter 开发的 keylol.com 第三方客户端应用。

## 技术栈

- **Flutter**: 3.0.1+
- **状态管理**: BLoC + HydratedBloc
- **网络请求**: Dio + dio_cache_interceptor
- **日志**: Talker
- **本地存储**: SQLite (sqflite) + SharedPreferences
- **国际化**: flutter_localizations

## 前置要求

### 必需工具
- Flutter SDK (3.0.1 或更高版本)
- Dart SDK
- Git

### 平台特定要求

#### Android 开发
- Android Studio
- Android SDK (API 21+)
- Java 8 或更高版本

#### iOS 开发
- Xcode 14+
- macOS
- CocoaPods

## 快速开始

### 1. 克隆项目

```bash
git clone <repository-url>
cd keylol_app
```

### 2. 初始化子模块

项目使用 git 子模块来管理依赖：

```bash
git submodule update --init --recursive
```

### 3. 安装依赖

```bash
flutter pub get
```

### 4. 运行应用

```bash
# 调试模式运行
flutter run

# 在特定设备上运行
flutter run -d <device-id>

# 列出可用设备
flutter devices
```

## 构建脚本

项目提供了便捷的构建脚本 `build.sh`，支持多种构建场景。

### 使用方法

```bash
./build.sh [命令]
```

### 可用命令

| 命令 | 描述 |
|------|------|
| `dev` | 调试构建 |
| `release-apk` | 构建发布版 APK |
| `release-appbundle` | 构建发布版 App Bundle |
| `release-ios` | 构建 iOS (发布版) |
| `clean` | 清理构建缓存 |
| `analyze` | 分析代码 |
| `test` | 运行测试 |
| `--help` | 显示帮助信息 |

### 示例

```bash
# 调试构建
./build.sh dev

# 构建发布版 APK
./build.sh release-apk

# 构建发布版 App Bundle (用于 Google Play)
./build.sh release-appbundle

# 构建发布版 iOS
./build.sh release-ios

# 清理缓存
./build.sh clean

# 分析代码
./build.sh analyze
```

## 手动构建

如果需要手动构建，可以使用以下 Flutter 命令：

### Android APK

```bash
# 调试版本
flutter build apk --debug

# 发布版本
flutter build apk --release

# 指定架构
flutter build apk --release --target-platform android-arm64
```

### Android App Bundle

```bash
# 发布版本
flutter build appbundle --release
```

### iOS

```bash
# 调试版本
flutter build ios --debug

# 发布版本
flutter build ios --release

# 在 Xcode 中打开
open ios/Runner.xcworkspace
```

## 构建输出

### Android

- **APK 输出位置**: `build/app/outputs/flutter-apk/`
  - 调试版: `app-debug.apk`
  - 发布版: `app-release.apk`

- **App Bundle 输出位置**: `build/app/outputs/bundle/release/`
  - 发布版: `app-release.aab`

### iOS

- **输出位置**: `build/ios/iphoneos/`
  - 可以在 Xcode 中打开项目并归档

## 常见问题

### 1. 子模块未初始化

**问题**: 找不到 keylol_api 或 discuz_widgets 包

**解决**:
```bash
git submodule update --init --recursive
```

### 2. Flutter 版本不匹配

**问题**: Flutter 版本不符合要求

**解决**:
```bash
# 检查 Flutter 版本
flutter --version

# 升级 Flutter
flutter upgrade
```

### 3. iOS 构建失败

**问题**: CocoaPods 依赖安装失败

**解决**:
```bash
cd ios
pod install
cd ..
```

### 4. Android 构建失败

**问题**: Gradle 构建失败

**解决**:
```bash
# 清理构建
flutter clean

# 删除 Gradle 缓存
rm -rf ~/.gradle/caches/

# 重新构建
flutter build apk --release
```

### 5. 依赖冲突

**问题**: pub get 时出现版本冲突

**解决**:
```bash
# 升级依赖
flutter pub upgrade

# 或者升级主要版本
flutter pub upgrade --major-versions

# 检查过时的依赖
flutter pub outdated
```

## 性能优化

### 减少包体积

```bash
# 按需构建特定架构
flutter build apk --release --split-per-abi

# 构建精简版 (不包含调试符号)
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

### 启动优化

项目已实施以下优化：

1. ✅ 并行初始化关键组件
2. ✅ 优化启动屏配置
3. ✅ 延迟加载非关键资源

详见 `WHITE_SCREEN_FIX.md` 了解更多启动优化详情。

## 代码分析

### 运行静态分析

```bash
flutter analyze
```

### 运行测试

```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/widget_test.dart

# 生成测试覆盖率报告
flutter test --coverage
```

## 调试

### 启用调试模式

```bash
flutter run --debug
```

### 启用性能分析模式

```bash
flutter run --profile
```

### 使用 DevTools

```bash
# 启动应用
flutter run --profile

# 在另一个终端启动 DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

## 发布应用

### 发布到 Google Play Store

1. 构建 App Bundle:
   ```bash
   ./build.sh release-appbundle
   ```

2. 签名 App Bundle (如果在开发环境)

3. 上传到 Google Play Console

### 发布到 App Store

1. 构建 iOS 应用:
   ```bash
   ./build.sh release-ios
   ```

2. 在 Xcode 中打开项目:
   ```bash
   open ios/Runner.xcworkspace
   ```

3. 配置签名和证书

4. Archive 并上传到 App Store Connect

## 项目结构

```
keylol_app/
├── android/              # Android 平台代码
├── ios/                  # iOS 平台代码
├── lib/                  # Flutter 代码
│   ├── main.dart         # 应用入口
│   ├── bloc/             # BLoC 状态管理
│   ├── config/           # 配置文件
│   ├── l10n/             # 国际化
│   ├── repository/       # 数据仓库
│   ├── screen/           # 页面
│   ├── utils/            # 工具类
│   └── widgets/          # 自定义组件
├── images/               # 图片资源
├── build.sh              # 构建脚本
├── pubspec.yaml          # 项目依赖配置
└── README.md             # 项目说明
```

## 环境变量

如需配置环境变量，可以创建 `.env` 文件：

```
API_BASE_URL=https://api.keylol.com
DEBUG_MODE=true
```

## 联系方式

如有问题，请提交 Issue 或 Pull Request。

## 许可证

详见项目根目录的 LICENSE 文件。
