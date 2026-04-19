#!/bin/bash
# 版本管理脚本
# 使用: ./scripts/version.sh [get|set|bump]

set -e

cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)

# 从 pyproject.toml 获取版本
get_version() {
    grep 'version = ' pyproject.toml | head -1 | sed 's/version = "//' | sed 's/"//'
}

# 设置版本
set_version() {
    NEW_VERSION=$1
    if [ -z "$NEW_VERSION" ]; then
        echo "❌ 请提供版本号"
        exit 1
    fi

    # 验证版本格式
    if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "❌ 版本格式错误，应为 X.Y.Z (如 1.2.3)"
        exit 1
    fi

    # 更新 pyproject.toml
    sed -i.bak "s/version = \"[0-9]+\.[0-9]+\.[0-9]+\"/version = \"$NEW_VERSION\"/" pyproject.toml
    rm -f pyproject.toml.bak

    # 更新 CHANGELOG.md
    if [ -f "CHANGELOG.md" ]; then
        TODAY=$(date +%Y-%m-%d)
        # 在文件开头插入新版本
        sed -i.bak "1i\\
## [$NEW_VERSION] - $TODAY\\
\\
### Added\\
- \\$NEW_VERSION release\\
\\
" CHANGELOG.md
        rm -f CHANGELOG.md.bak
    fi

    echo "✅ 版本已更新为 $NEW_VERSION"
}

# 自动递增版本
bump_version() {
    TYPE=${1:-patch}  # major, minor, patch

    CURRENT=$(get_version)
    MAJOR=$(echo $CURRENT | cut -d. -f1)
    MINOR=$(echo $CURRENT | cut -d. -f2)
    PATCH=$(echo $CURRENT | cut -d. -f3)

    case "$TYPE" in
        major)
            NEW_VERSION="$((MAJOR+1)).0.0"
            ;;
        minor)
            NEW_VERSION="$MAJOR.$((MINOR+1)).0"
            ;;
        patch)
            NEW_VERSION="$MAJOR.$MINOR.$((PATCH+1))"
            ;;
        *)
            echo "❌ 无效类型: $TYPE (应为 major/minor/patch)"
            exit 1
            ;;
    esac

    set_version "$NEW_VERSION"
}

# 主逻辑
ACTION=${1:-get}
PARAM=${2:-}

case "$ACTION" in
    get)
        echo "当前版本: $(get_version)"
        ;;
    set)
        set_version "$PARAM"
        ;;
    bump)
        bump_version "$PARAM"
        ;;
    *)
        echo "用法: $0 [get|set|bump]"
        echo ""
        echo "命令:"
        echo "  get              - 获取当前版本"
        echo "  set 1.2.3        - 设置指定版本"
        echo "  bump [type]      - 递增版本 (major/minor/patch)"
        ;;
esac