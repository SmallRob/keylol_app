#!/bin/bash

# Flutter 路径问题快速修复脚本

echo "======================================"
echo "Flutter 路径诊断和修复"
echo "======================================"
echo ""

# 检查 Flutter 是否已安装
if [ ! -d "$HOME/flutter" ]; then
    echo "❌ Flutter 未安装在 ~/flutter"
    echo "请运行 ./install_flutter.sh 安装 Flutter"
    exit 1
fi

echo "✅ Flutter 已安装在: ~/flutter"
echo ""

# 检查 Flutter 二进制文件
if [ ! -f "$HOME/flutter/bin/flutter" ]; then
    echo "❌ Flutter 二进制文件不存在"
    exit 1
fi

echo "✅ Flutter 二进制文件存在"
echo ""

# 测试 Flutter 是否工作
echo "测试 Flutter..."
if $HOME/flutter/bin/flutter --version > /dev/null 2>&1; then
    echo "✅ Flutter 可以正常工作"
    $HOME/flutter/bin/flutter --version
else
    echo "❌ Flutter 无法正常工作"
    exit 1
fi

echo ""
echo "======================================"
echo "环境变量检查"
echo "======================================"

# 检查 .zshrc 配置
if grep -q "flutter" ~/.zshrc 2>/dev/null; then
    echo "✅ .zshrc 中已配置 Flutter"
    echo ""
    echo "配置内容："
    grep -A 2 "Flutter" ~/.zshrc
else
    echo "❌ .zshrc 中未配置 Flutter"
    echo ""
    echo "正在添加配置..."
    echo "" >> ~/.zshrc
    echo "# Flutter" >> ~/.zshrc
    echo "export PATH=\"\$PATH:\$HOME/flutter/bin\"" >> ~/.zshrc
    echo "✅ 已添加配置"
fi

echo ""
echo "======================================"
echo "修复步骤"
echo "======================================"
echo ""
echo "Flutter 已经安装，但当前终端会话可能未加载配置。"
echo ""
echo "请在终端中执行以下命令之一："
echo ""
echo "方法 1（推荐）：重新加载配置"
echo "  source ~/.zshrc"
echo ""
echo "方法 2：打开新终端"
echo "  关闭当前终端，重新打开"
echo ""
echo "方法 3：临时添加到当前会话"
echo "  export PATH=\"\$PATH:\$HOME/flutter/bin\""
echo ""
echo "验证安装："
echo "  flutter --version"
echo "  flutter doctor"
echo ""
echo "======================================"

# 询问是否立即运行 flutter doctor
read -p "是否立即运行 flutter --version 测试? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "运行 flutter --version:"
    $HOME/flutter/bin/flutter --version
    echo ""
    echo "✅ Flutter 工作正常！"
    echo ""
    echo "请运行 'source ~/.zshrc' 重新加载配置"
fi
