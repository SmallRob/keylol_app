#!/bin/bash

# 测试 Flutter Web 应用

echo "========================================"
echo "启动 Flutter Web 应用"
echo "========================================"
echo ""

# 检查是否有正在运行的 Flutter 进程
if pgrep -f "flutter run" > /dev/null; then
    echo "⚠️  检测到正在运行的 Flutter 进程"
    echo "请先停止当前运行的应用（在 Flutter 终端按 'q'）"
    exit 1
fi

echo "开始构建并运行 Web 应用..."
echo ""

# 运行 Flutter Web 应用
flutter run -d chrome

echo ""
echo "========================================"
echo "应用已启动"
echo "========================================"
