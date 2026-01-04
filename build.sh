#!/bin/bash

# Keylol Flutter App Build Script
# 支持调试和发布构建

set -e  # 遇到错误立即退出

PROJECT_DIR="/Users/healer2027/AndroidStudioProjects/keylol_app"
cd "$PROJECT_DIR"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
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

# 显示使用帮助
show_help() {
    cat << EOF
Keylol Flutter App 构建脚本

使用方法:
    ./build.sh [命令] [选项]

命令:
    dev                 调试构建
    release-apk         构建 Android APK (发布版)
    release-appbundle   构建 Android App Bundle (发布版)
    release-ios         构建 iOS (发布版)
    clean               清理构建缓存
    analyze             分析代码
    test                运行测试

选项:
    --help              显示此帮助信息

示例:
    ./build.sh dev                    # 调试构建
    ./build.sh release-apk            # 构建发布版 APK
    ./build.sh release-appbundle      # 构建发布版 App Bundle
    ./build.sh clean                  # 清理缓存

EOF
}

# 检查 Flutter 是否安装
check_flutter() {
    print_info "检查 Flutter 环境..."

    if ! command -v flutter &> /dev/null; then
        print_error "Flutter 未安装或未添加到 PATH"
        print_info "请访问 https://docs.flutter.dev/get-started/install 安装 Flutter"
        exit 1
    fi

    print_success "Flutter 环境检查通过"
}

# 检查依赖
check_dependencies() {
    print_info "检查项目依赖..."

    # 检查 git 子模块
    if [ -f ".gitmodules" ]; then
        print_info "检查 git 子模块..."
        if ! git submodule status | grep -q "^ "; then
            print_warning "部分 git 子模块可能未初始化"
            print_info "运行: git submodule update --init --recursive"
        else
            print_success "Git 子模块状态正常"
        fi
    fi
}

# 清理构建
clean_build() {
    print_info "清理构建缓存..."

    flutter clean
    rm -rf "$PROJECT_DIR/build"
    rm -rf "$PROJECT_DIR/.dart_tool"

    print_success "清理完成"
}

# 获取依赖
get_dependencies() {
    print_info "获取依赖..."

    flutter pub get

    print_success "依赖获取完成"
}

# 代码分析
analyze_code() {
    print_info "分析代码..."

    flutter analyze

    print_success "代码分析完成"
}

# 运行测试
run_tests() {
    print_info "运行测试..."

    flutter test

    print_success "测试完成"
}

# 调试构建
build_dev() {
    print_info "开始调试构建..."

    check_flutter
    check_dependencies
    get_dependencies

    print_info "构建调试版本..."
    flutter build apk --debug

    print_success "调试构建完成"
    print_info "APK 位置: build/app/outputs/flutter-apk/app-debug.apk"
}

# 构建 Android APK (Release)
build_release_apk() {
    print_info "开始构建 Android APK (Release)..."

    check_flutter
    check_dependencies
    get_dependencies
    analyze_code

    print_info "构建发布版 APK..."
    flutter build apk --release

    local apk_path="$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk"
    local apk_size=$(du -h "$apk_path" | cut -f1)

    print_success "APK 构建完成"
    print_info "APK 路径: $apk_path"
    print_info "APK 大小: $apk_size"
}

# 构建 Android App Bundle (Release)
build_release_appbundle() {
    print_info "开始构建 Android App Bundle (Release)..."

    check_flutter
    check_dependencies
    get_dependencies
    analyze_code

    print_info "构建发布版 App Bundle..."
    flutter build appbundle --release

    local aab_path="$PROJECT_DIR/build/app/outputs/bundle/release/app-release.aab"
    local aab_size=$(du -h "$aab_path" | cut -f1)

    print_success "App Bundle 构建完成"
    print_info "AAB 路径: $aab_path"
    print_info "AAB 大小: $aab_size"
    print_info "可以上传到 Google Play Console"
}

# 构建 iOS (Release)
build_release_ios() {
    print_info "开始构建 iOS (Release)..."

    # 检查是否在 macOS 上
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "iOS 构建只能在 macOS 上进行"
        exit 1
    fi

    check_flutter
    check_dependencies
    get_dependencies
    analyze_code

    print_info "构建发布版 iOS..."
    flutter build ios --release

    print_success "iOS 构建完成"
    print_info "可以在 Xcode 中打开项目并归档上传到 App Store"
    print_info "项目路径: ios/Runner.xcworkspace"
}

# 主函数
main() {
    case "$1" in
        dev)
            build_dev
            ;;
        release-apk)
            build_release_apk
            ;;
        release-appbundle)
            build_release_appbundle
            ;;
        release-ios)
            build_release_ios
            ;;
        clean)
            clean_build
            ;;
        analyze)
            analyze_code
            ;;
        test)
            run_tests
            ;;
        --help|-h|"")
            show_help
            ;;
        *)
            print_error "未知命令: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
