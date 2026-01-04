#!/bin/bash

# 磁盘清理脚本

echo "========================================="
echo "磁盘空间检查与清理"
echo "========================================="
echo ""

# 检查当前磁盘使用情况
echo "当前磁盘使用情况："
df -h /System/Volumes/Data
echo ""

# 检查可能的大目录
echo "检查占用空间的目录："
du -sh ~/Library/Developer 2>/dev/null || echo "Developer 目录不存在"
du -sh ~/Library/Caches 2>/dev/null || echo "Caches 目录不存在"
du -sh ~/.flutter 2>/dev/null || echo "Flutter 目录不存在"
du -sh ~/AndroidStudioProjects 2>/dev/null || echo "AndroidStudioProjects 目录不存在"
du -sh ~/.npm 2>/dev/null || echo "npm 目录不存在"
du -sh ~/.gradle 2>/dev/null || echo "gradle 目录不存在"
echo ""

echo "========================================="
echo "建议清理项目"
echo "========================================="
echo ""

# 清理 Flutter 缓存
echo "1. 清理 Flutter 构建缓存"
echo "   flutter clean"
echo "   rm -rf ~/.flutter_tool_state"
echo ""

# 清理 Gradle 缓存
echo "2. 清理 Gradle 缓存"
echo "   rm -rf ~/.gradle/caches/"
echo ""

# 清理 npm 缓存
echo "3. 清理 npm 缓存"
echo "   npm cache clean --force"
echo ""

# 清理 Xcode 缓存
echo "4. 清理 Xcode 缓存"
echo "   rm -rf ~/Library/Developer/Xcode/DerivedData"
echo ""

# 清理系统缓存
echo "5. 清理系统缓存"
echo "   sudo rm -rf /System/Volumes/Data/.Spotlight-V100"
echo "   sudo rm -rf /System/Volumes/Data/.Trashes"
echo ""

echo "========================================="
echo "是否执行自动清理？"
echo "========================================="
echo ""
read -p "是否清理 Flutter 构建缓存? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "正在清理 Flutter 构建缓存..."
    cd /Users/healer2027/AndroidStudioProjects/keylol_app
    flutter clean
    rm -rf /Users/healer2027/.flutter_tool_state
    echo "✅ Flutter 缓存清理完成"
fi

echo ""
read -p "是否清理 Gradle 缓存? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "正在清理 Gradle 缓存..."
    rm -rf ~/.gradle/caches/
    echo "✅ Gradle 缓存清理完成"
fi

echo ""
read -p "是否清理 npm 缓存? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "正在清理 npm 缓存..."
    npm cache clean --force 2>/dev/null || echo "npm 未安装或缓存为空"
    echo "✅ npm 缓存清理完成"
fi

echo ""
echo "========================================="
echo "清理后磁盘使用情况"
echo "========================================="
df -h /System/Volumes/Data
echo ""

echo "如果仍然空间不足，请手动检查并删除不需要的大文件"
