#!/bin/bash

# Flutter 自动安装脚本 for macOS (Apple Silicon)
# 适用于 keylol_flutter 项目开发

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查系统
print_info "检查系统环境..."

# 检查是否为 macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "此脚本仅适用于 macOS 系统"
    exit 1
fi

# 检查架构
ARCH=$(uname -m)
if [[ "$ARCH" != "arm64" ]]; then
    print_warning "检测到非 Apple Silicon 芯片 ($ARCH)"
    print_warning "此脚本专为 Apple Silicon 设计，可能需要修改"
fi

# 检查 Git
if ! command -v git &> /dev/null; then
    print_error "Git 未安装，请先安装 Git"
    exit 1
fi
print_success "Git 已安装: $(git --version)"

# 设置安装目录
FLUTTER_DIR="$HOME/flutter"
INSTALL_DIR="$HOME/development"

# 创建开发目录
mkdir -p "$INSTALL_DIR"

print_info "Flutter 将安装到: $FLUTTER_DIR"

# 检查是否已安装
if [ -d "$FLUTTER_DIR" ]; then
    print_warning "Flutter 目录已存在: $FLUTTER_DIR"
    read -p "是否要删除并重新安装? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "删除旧版 Flutter..."
        rm -rf "$FLUTTER_DIR"
    else
        print_error "安装已取消"
        exit 1
    fi
fi

# 下载 Flutter
print_info "正在下载 Flutter SDK..."

cd "$INSTALL_DIR"

# 使用 git clone 下载（推荐，更易更新）
print_info "使用 git clone 方式下载 Flutter..."
git clone https://github.com/flutter/flutter.git -b stable

print_success "Flutter SDK 下载完成"

# 切换到稳定分支
print_info "切换到稳定分支..."
cd flutter
git checkout stable
git pull origin stable

print_success "Flutter SDK 已更新到最新稳定版"

# 配置环境变量
print_info "配置环境变量..."

SHELL_RC="$HOME/.zshrc"

# 检查是否已配置 Flutter
if grep -q "flutter" "$SHELL_RC" 2>/dev/null; then
    print_warning "Flutter 配置已存在于 $SHELL_RC"
else
    # 添加 Flutter 到 PATH
    echo "" >> "$SHELL_RC"
    echo "# Flutter" >> "$SHELL_RC"
    echo "export PATH=\"\$PATH:\$HOME/flutter/bin\"" >> "$SHELL_RC"
    print_success "已添加 Flutter 到 PATH"
fi

# 配置 Android SDK 路径（如果存在）
if [ -d "$HOME/Library/Android/sdk" ]; then
    if ! grep -q "Android/sdk" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# Android SDK" >> "$SHELL_RC"
        echo "export ANDROID_HOME=\"\$HOME/Library/Android/sdk\"" >> "$SHELL_RC"
        echo "export PATH=\"\$PATH:\$ANDROID_HOME/emulator\"" >> "$SHELL_RC"
        echo "export PATH=\"\$PATH:\$ANDROID_HOME/tools\"" >> "$SHELL_RC"
        echo "export PATH=\"\$PATH:\$ANDROID_HOME/tools/bin\"" >> "$SHELL_RC"
        echo "export PATH=\"\$PATH:\$ANDROID_HOME/platform-tools\"" >> "$SHELL_RC"
        print_success "已添加 Android SDK 到 PATH"
    fi
fi

print_success "环境变量配置完成"
print_info "请运行: source ~/.zshrc"

# 运行 Flutter doctor 下载必要组件
print_info "运行 Flutter doctor 下载必要组件（首次运行可能需要几分钟）..."

# 临时添加到当前会话 PATH
export PATH="$PATH:$HOME/flutter/bin"

# 运行 flutter precache 下载必要组件
print_info "下载 Flutter 组件..."
flutter precache

print_success "必要组件下载完成"

# 显示安装信息
print_info "======================================"
print_info "Flutter 安装完成！"
print_info "======================================"
print_info ""
print_info "请执行以下步骤："
print_info ""
print_info "1. 重新加载 shell 配置："
print_info "   source ~/.zshrc"
print_info ""
print_info "2. 验证安装："
print_info "   flutter --version"
print_info ""
print_info "3. 检查环境："
print_info "   flutter doctor"
print_info ""
print_info "4. 安装缺失的依赖（根据 doctor 提示）："
print_info "   - Android Studio (Android 开发)"
print_info "   - Xcode (iOS 开发)"
print_info ""
print_info "Flutter 目录: $FLUTTER_DIR"
print_info "======================================"

# 询问是否运行 flutter doctor
read -p "是否现在运行 flutter doctor 检查环境? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "运行 flutter doctor..."
    flutter doctor
fi

print_success "安装脚本执行完成！"
