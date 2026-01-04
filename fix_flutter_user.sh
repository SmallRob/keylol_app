#!/bin/bash

# Flutter 用户路径修复脚本
# 修复 HOME 环境变量问题，确保 Flutter 可以被当前用户使用

echo "========================================"
echo "Flutter 用户路径修复"
echo "========================================"
echo ""

# 获取当前用户
CURRENT_USER=$(whoami)
echo "当前用户: $CURRENT_USER"

# 获取实际的用户目录
if [ "$CURRENT_USER" = "healer2027" ]; then
    USER_HOME="/Users/healer2027"
else
    USER_HOME="/Users/$CURRENT_USER"
fi

echo "实际用户目录: $USER_HOME"
echo "当前 HOME 环境变量: $HOME"
echo ""

# 检查是否使用正确的 HOME
if [ "$HOME" != "$USER_HOME" ]; then
    echo "⚠️  检测到 HOME 环境变量异常"
    echo "当前 HOME: $HOME"
    echo "应该是: $USER_HOME"
    echo ""
    echo "正在修复..."
fi

# 检查 Flutter 安装位置
FLUTTER_DIR="$USER_HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
    echo "❌ Flutter 未安装在 $FLUTTER_DIR"
    echo "请先运行 ./install_flutter.sh"
    exit 1
fi

echo "✅ Flutter 安装位置: $FLUTTER_DIR"
echo ""

# 测试 Flutter
echo "测试 Flutter..."
if [ -f "$FLUTTER_DIR/bin/flutter" ]; then
    FLUTTER_VERSION=$($FLUTTER_DIR/bin/flutter --version 2>&1 | head -n 1)
    echo "✅ Flutter 版本: $FLUTTER_VERSION"
else
    echo "❌ Flutter 二进制文件不存在"
    exit 1
fi

echo ""
echo "========================================"
echo "配置修复"
echo "========================================"
echo ""

# 修复 .zshrc 中的路径
ZSHRC="$USER_HOME/.zshrc"

if [ -f "$ZSHRC" ]; then
    echo "找到 .zshrc: $ZSHRC"
else
    echo "未找到 .zshrc，将创建新文件"
fi

echo ""

# 检查并修复 Flutter 路径配置
if grep -q "flutter/bin" "$ZSHRC" 2>/dev/null; then
    echo "✅ .zshrc 中已配置 Flutter"
    echo ""
    echo "当前配置："
    grep "flutter" "$ZSHRC"
else
    echo "正在添加 Flutter 配置..."
    echo "" >> "$ZSHRC"
    echo "# Flutter" >> "$ZSHRC"
    echo "if [ -d \"$FLUTTER_DIR/bin\" ]; then" >> "$ZSHRC"
    echo "  export PATH=\"\$PATH:$FLUTTER_DIR/bin\"" >> "$ZSHRC"
    echo "fi" >> "$ZSHRC"
    echo "✅ 已添加配置"
fi

echo ""
echo "========================================"
echo "创建快捷启动脚本"
echo "========================================"
echo ""

# 创建项目目录下的快速设置脚本
PROJECT_DIR="/Users/healer2027/AndroidStudioProjects/keylol_app"
SETUP_SCRIPT="$PROJECT_DIR/setup_flutter_env.sh"

cat > "$SETUP_SCRIPT" << 'EOF'
#!/bin/bash
# 快速设置 Flutter 环境

# 获取当前用户
CURRENT_USER=$(whoami)
USER_HOME="/Users/$CURRENT_USER"

# 设置 Flutter 路径
if [ -d "$USER_HOME/flutter/bin" ]; then
    export PATH="$PATH:$USER_HOME/flutter/bin"
    echo "✅ Flutter 环境已设置"
    echo "Flutter 版本: $(flutter --version | head -n 1)"
else
    echo "❌ Flutter 未安装"
fi
EOF

chmod +x "$SETUP_SCRIPT"
echo "✅ 已创建快速设置脚本: $SETUP_SCRIPT"

echo ""
echo "========================================"
echo "修复完成"
echo "========================================"
echo ""
echo "Flutter 已正确安装在当前用户目录下"
echo ""
echo "请在终端中执行以下任一命令："
echo ""
echo "方法 1：修复 HOME 环境变量并重新加载配置"
echo "  export HOME=\"$USER_HOME\""
echo "  source ~/.zshrc"
echo ""
echo "方法 2：使用项目中的快速设置脚本"
echo "  cd /Users/healer2027/AndroidStudioProjects/keylol_app"
echo "  source setup_flutter_env.sh"
echo ""
echo "方法 3：直接在命令中指定完整路径"
echo "  $FLUTTER_DIR/bin/flutter --version"
echo ""
echo "验证安装："
echo "  export HOME=\"$USER_HOME\""
echo "  source ~/.zshrc"
echo "  flutter --version"
echo "  flutter doctor"
echo ""

# 询问是否立即测试
read -p "是否立即测试 Flutter? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "设置 Flutter 环境变量..."
    export HOME="$USER_HOME"
    export PATH="$PATH:$FLUTTER_DIR/bin"

    echo ""
    echo "运行 flutter --version:"
    flutter --version

    echo ""
    echo "✅ Flutter 工作正常！"
    echo ""
    echo "建议将以下命令添加到您的 shell 配置中："
    echo "export HOME=\"$USER_HOME\""
fi
