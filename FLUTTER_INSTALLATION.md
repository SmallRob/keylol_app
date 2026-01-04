# Flutter 安装指南 (macOS Apple Silicon)

本指南适用于在 macOS (Apple Silicon/M1/M2/M3) 上安装 Flutter SDK。

## 系统要求

### 硬件要求
- Apple Silicon (M1/M2/M3) 或 Intel Mac
- 至少 2GB 可用磁盘空间（建议 10GB+）
- 至少 8GB RAM

### 软件要求
- macOS 15.7.2 或更高版本 ✅ (您的系统已满足)
- Git ✅ (已安装: 2.39.5)
- Java 8 或更高版本 ✅ (已安装: OpenJDK 20.0.1)
- Shell: zsh ✅ (您的系统已配置)

### 当前环境检测
```
✅ macOS 15.7.2 (arm64)
✅ Git 2.39.5
✅ Java 20.0.1
✅ zsh shell
❌ Flutter 未安装
❌ Xcode 未安装
```

## 安装方式

### 方式一：自动安装脚本（推荐）

我已经为您创建了自动安装脚本，可以一键完成 Flutter SDK 的下载、安装和配置。

#### 使用步骤

```bash
# 进入项目目录
cd /Users/healer2027/AndroidStudioProjects/keylol_app

# 运行安装脚本
./install_flutter.sh
```

#### 脚本功能
- ✅ 自动检测系统环境
- ✅ 下载最新稳定版 Flutter SDK
- ✅ 配置环境变量（PATH）
- ✅ 配置 Android SDK 路径（如果存在）
- ✅ 下载必要组件（flutter precache）
- ✅ 运行 Flutter doctor 检查

#### 注意事项
- Flutter 将安装到 `~/flutter` 目录
- 安装过程可能需要 5-10 分钟（取决于网络速度）
- 首次运行会下载必要组件（约 1-2GB）
- 安装完成后需要重新加载 shell 配置

### 方式二：手动安装

如果您想手动控制安装过程，可以按照以下步骤操作。

#### 步骤 1: 下载 Flutter SDK

**方法 A: 使用 Git（推荐）**

```bash
# 创建开发目录
mkdir -p ~/development

# 克隆 Flutter 仓库
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# 切换到稳定分支
cd flutter
git checkout stable
git pull origin stable
```

**方法 B: 下载压缩包**

```bash
# 创建开发目录
mkdir -p ~/development
cd ~/development

# 下载 Flutter SDK (Apple Silicon)
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.24.5-stable.tar.xz

# 解压
tar xf flutter_macos_arm64_3.24.5-stable.tar.xz

# 重命名目录
mv flutter flutter_sdk
```

#### 步骤 2: 配置环境变量

**编辑 ~/.zshrc 文件**

```bash
# 打开配置文件
nano ~/.zshrc

# 或使用 vim
vim ~/.zshrc
```

**添加以下内容**

```bash
# Flutter
export PATH="$PATH:$HOME/flutter/bin"

# 如果使用压缩包方式，路径为：
# export PATH="$PATH:$HOME/development/flutter_sdk/bin"
```

**保存并退出**
- nano: `Ctrl + O` 保存，`Ctrl + X` 退出
- vim: `:wq` 保存并退出

#### 步骤 3: 重新加载配置

```bash
# 重新加载 shell 配置
source ~/.zshrc

# 或重新打开终端
```

#### 步骤 4: 验证安装

```bash
# 查看 Flutter 版本
flutter --version

# 应该看到类似输出：
# Flutter 3.24.5 • channel stable • https://github.com/flutter/flutter.git
# Framework • revision c8944a91f9 (3 weeks ago) • 2024-12-11 15:15:07 -0800
# Engine • revision 2540912534
# Tools • Dart 3.5.4
```

#### 步骤 5: 下载必要组件

```bash
# 下载必要的组件（首次运行需要）
flutter precache

# 运行环境检查
flutter doctor
```

## 安装依赖工具

### Android 开发

#### 1. 安装 Android Studio

```bash
# 使用 Homebrew 安装
brew install --cask android-studio

# 或从官网下载
# https://developer.android.com/studio
```

#### 2. 配置 Android SDK

```bash
# 打开 Android Studio
open -a Android Studio

# 进入配置界面：
# Preferences > Appearance & Behavior > System Settings > Android SDK

# 安装 SDK Platforms：
# - Android 14.0 (API 34) 或更高
# - Android 13.0 (API 33)
```

#### 3. 配置 Android SDK 环境变量

```bash
# 编辑 ~/.zshrc
nano ~/.zshrc

# 添加以下内容
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/tools"
export PATH="$PATH:$ANDROID_HOME/tools/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"

# 保存并重新加载
source ~/.zshrc
```

#### 4. 接受 Android 许可

```bash
# 接受所有 SDK 许可
flutter doctor --android-licenses
```

### iOS 开发

#### 1. 安装 Xcode

```bash
# 使用 App Store 安装
open macappstore://apps/id497799835

# 或使用 Homebrew
brew install --cask xcode
```

#### 2. 安装 Xcode 命令行工具

```bash
# 同意 Xcode 许可
sudo xcodebuild -license

# 安装命令行工具
xcode-select --install
```

#### 3. 安装 CocoaPods

```bash
# 安装 CocoaPods
sudo gem install cocoapods

# 或使用 Homebrew
brew install cocoapods
```

#### 4. 配置 iOS 模拟器

```bash
# 查看可用的模拟器
xcrun simctl list devices

# 启动模拟器
open -a Simulator
```

### 其他工具

#### 1. 安装 Homebrew（如果没有）

```bash
# 安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 2. 安装常用工具

```bash
# 安装 Git（如果需要更新）
brew install git

# 安装 OpenJDK
brew install openjdk@17

# 安装其他工具
brew install wget
```

## 验证安装

### 运行 Flutter Doctor

```bash
# 完整的环境检查
flutter doctor

# 详细信息
flutter doctor -v
```

### 期望输出（示例）

```
[✓] Flutter (Channel stable, 3.24.5, on macOS 15.7.2 24G317, locale zh-Hans-CN)
    • Flutter version 3.24.5 on channel stable at /Users/healer2027/flutter
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision c8944a91f9 (3 weeks ago), 2024-12-11 15:15:07 -0800
    • Engine revision 2540912534
    • Dart version 3.5.4
    • DevTools version 2.34.5

[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
    • Android SDK at /Users/healer2027/Library/Android/sdk
    • Platform android-34, build-tools 34.0.0
    • Java binary at: /Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/java
    • Java version OpenJDK Runtime Environment (build 17.0.11+0-17.0.11b1207.24-11893864)
    • All Android licenses accepted.

[✓] Xcode - develop for iOS and macOS (Xcode 16.2)
    • Xcode at /Applications/Xcode.app/Contents/Developer
    • Build 16C5032a
    • CocoaPods version 1.15.2

[✓] Chrome - develop for the web
    • Chrome at /Applications/Google Chrome.app/Contents/MacOS/Google Chrome

[!] Android Studio (version 2024.2)
    • Android Studio at /Applications/Android Studio.app/Contents
    ✗ Flutter plugin not installed; this adds Flutter specific functionality.
    ✗ Dart plugin not installed; this adds Dart specific functionality.
    • For information about installing plugins, see
      https://flutter.dev/docs/get-started/editor/plugin-install

[✓] Connected device (3 available)
    • macOS (desktop) • macos  • darwin-arm64   • macOS 15.7.2 24G317
    • Chrome (web)    • chrome • web-javascript • Google Chrome 120.0.6099.109
    • Emulator        • emulator • android      • Android 14.0.0 (API 34) (emulator)

[!] No issues found!
```

### 常见警告和解决

#### 警告：Android Studio 插件未安装

```bash
# 打开 Android Studio
open -a Android Studio

# 进入 Preferences > Plugins
# 搜索并安装：
# - Flutter
# - Dart
```

#### 警告：CocoaPods 未安装

```bash
# 安装 CocoaPods
sudo gem install cocoapods

# 或更新 CocoaPods
sudo gem update cocoapods
```

#### 警告：Android 许可未接受

```bash
# 接受所有许可
flutter doctor --android-licenses
```

## 配置项目

安装完成后，配置 keylol_flutter 项目：

```bash
# 进入项目目录
cd /Users/healer2027/AndroidStudioProjects/keylol_app

# 初始化子模块
git submodule update --init --recursive

# 安装依赖
flutter pub get

# 运行应用
flutter run
```

## 使用构建脚本

使用项目提供的构建脚本：

```bash
# 赋予执行权限（如果还没有）
chmod +x build.sh

# 查看帮助
./build.sh --help

# 调试构建
./build.sh dev

# 发布构建
./build.sh release-apk
```

## 常见问题

### 1. Flutter 命令未找到

**问题**: 运行 `flutter` 命令提示 "command not found"

**解决**:
```bash
# 检查 Flutter 是否安装
ls -la ~/flutter

# 检查 PATH 配置
echo $PATH | grep flutter

# 重新加载配置
source ~/.zshrc

# 或手动添加到当前会话
export PATH="$PATH:$HOME/flutter/bin"
```

### 2. Flutter 下载速度慢

**问题**: 下载 Flutter SDK 或组件时速度很慢

**解决**:
```bash
# 使用国内镜像（中国用户）
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# 添加到 ~/.zshrc 持久化
```

### 3. Gradle 构建失败

**问题**: Android 构建时 Gradle 失败

**解决**:
```bash
# 清理构建
flutter clean

# 删除 Gradle 缓存
rm -rf ~/.gradle/caches/

# 重新构建
flutter pub get
flutter run
```

### 4. iOS 模拟器无法启动

**问题**: iOS 模拟器无法启动或黑屏

**解决**:
```bash
# 重置模拟器
xcrun simctl erase all

# 重启 Xcode
killall -9 Xcode
open -a Xcode
```

### 5. 权限问题

**问题**: 安装时提示权限不足

**解决**:
```bash
# 修复权限
sudo chown -R $(whoami) ~/flutter
sudo chown -R $(whoami) ~/development
```

## 卸载 Flutter

如果需要卸载 Flutter：

```bash
# 删除 Flutter SDK
rm -rf ~/flutter

# 删除 Flutter 配置
rm -rf ~/.flutter

# 编辑 ~/.zshrc，删除 Flutter 相关配置
nano ~/.zshrc

# 重新加载配置
source ~/.zshrc
```

## 更新 Flutter

定期更新 Flutter 到最新版本：

```bash
# 切换到稳定分支
cd ~/flutter
git checkout stable

# 拉取最新代码
git pull origin stable

# 或使用 Flutter 命令更新
flutter upgrade

# 查看版本
flutter --version
```

## 性能优化

### 1. 增加构建缓存

```bash
# 编辑 ~/.zshrc
nano ~/.zshrc

# 添加
export FLUTTER_ROOT="$HOME/flutter"
export FLUTTER_CACHE_DIR="$HOME/.flutter_cache"

# 重新加载
source ~/.zshrc
```

### 2. 使用镜像加速

```bash
# 编辑 ~/.zshrc
nano ~/.zshrc

# 添加（中国用户）
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# 重新加载
source ~/.zshrc
```

## 下一步

安装完成后，您可以：

1. 查看 [BUILD_GUIDE.md](./BUILD_GUIDE.md) 了解如何构建项目
2. 查看 [WHITE_SCREEN_FIX.md](./WHITE_SCREEN_FIX.md) 了解启动优化
3. 查看 [PROJECT_ANALYSIS.md](./PROJECT_ANALYSIS.md) 了解项目结构

## 获取帮助

- Flutter 官方文档: https://docs.flutter.dev/
- Flutter 中文网: https://flutter.cn/
- Flutter GitHub: https://github.com/flutter/flutter
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

---

**安装时间**: 2026-01-04
**系统版本**: macOS 15.7.2 (arm64)
**推荐版本**: Flutter 3.24.5 (stable)
