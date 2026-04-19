#!/bin/bash
# 本地二进制打包脚本 - 使用 PyInstaller
# 使用: ./scripts/build_binary.sh [平台]
# 平台: linux, macos, windows (默认当前系统)

set -e

echo "=== TTrans 二进制打包 ==="

# 进入项目根目录
cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)

# 检测当前平台
detect_platform() {
    case "$(uname -s)" in
        Linux*)  echo "linux";;
        Darwin*) echo "macos";;
        CYGWIN*|MINGW*|MSYS*) echo "windows";;
        *)       echo "unknown";;;
    esac
}

PLATFORM=${1:-$(detect_platform)}
echo "目标平台: $PLATFORM"
echo "项目目录: $PROJECT_ROOT"

# 清理旧构建
echo "清理旧构建文件..."
rm -rf build/ dist/

# 安装依赖
echo "安装依赖..."
pip install pyinstaller
pip install -r requirements.txt

# 构建
echo "PyInstaller 构建..."
pyinstaller TTrans.spec --noconfirm

# 重命名输出文件
case "$PLATFORM" in
    linux)
        mv dist/TTrans dist/TTrans-linux
        OUTPUT="dist/TTrans-linux"
        ;;
    macos)
        mv dist/TTrans dist/TTrans-macos
        OUTPUT="dist/TTrans-macos"
        ;;
    windows)
        if [ -f "dist/TTrans.exe" ]; then
            mv dist/TTrans.exe dist/TTrans-windows.exe
            OUTPUT="dist/TTrans-windows.exe"
        else
            OUTPUT="dist/TTrans.exe"
        fi
        ;;
esac

# 检查结果
echo ""
echo "=== 构建结果 ==="
ls -lh dist/

# 测试运行
echo ""
echo "=== 测试运行 ==="
if [ -f "$OUTPUT" ]; then
    echo "测试二进制..."
    "$OUTPUT" --version || echo "(--version 未实现，跳过)"
fi

echo ""
echo "✅ 二进制打包完成！"
echo "输出文件: $PROJECT_ROOT/$OUTPUT"
echo ""
echo "使用方法:"
case "$PLATFORM" in
    linux|macos)
        echo "  chmod +x $OUTPUT"
        echo "  $OUTPUT              # 启动 TUI"
        echo "  $OUTPUT Hello World  # 简洁模式"
        ;;
    windows)
        echo "  $OUTPUT              # 启动 TUI"
        echo "  $OUTPUT Hello World  # 简洁模式"
        ;;
esac