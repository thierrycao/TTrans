#!/bin/bash
# PyPI 发布脚本
# 使用: ./scripts/publish_pypi.sh [test|prod]
# test: 发布到 TestPyPI (测试)
# prod: 发布到 PyPI (正式)

set -e

MODE=${1:-test}

echo "=== TTrans PyPI 发布 ==="
echo "发布模式: $MODE"

# 进入项目根目录
cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)

# 检查是否有 dist 文件
if [ ! -d "dist" ] || [ -z "$(ls -A dist 2>/dev/null)" ]; then
    echo "❌ 没有 dist 文件，请先运行 ./scripts/build_local.sh"
    exit 1
fi

# 检查环境变量
if [ "$MODE" == "prod" ]; then
    if [ -z "$PYPI_TOKEN" ]; then
        echo "❌ 未设置 PYPI_TOKEN 环境变量"
        echo ""
        echo "请先设置:"
        echo "  export PYPI_TOKEN='your-pypi-token'"
        echo ""
        echo "获取 Token: https://pypi.org/manage/account/token/"
        exit 1
    fi
    TWINE_REPO="https://upload.pypi.org/legacy/"
    echo "目标: PyPI (正式)"
else
    if [ -z "$TEST_PYPI_TOKEN" ]; then
        echo "⚠ 未设置 TEST_PYPI_TOKEN，将使用交互式登录"
        TWINE_REPO="https://test.pypi.org/legacy/"
    else
        TWINE_REPO="https://test.pypi.org/legacy/"
    fi
    echo "目标: TestPyPI (测试)"
fi

# 安装 twine
echo "安装 twine..."
pip install --upgrade twine

# 检查包
echo ""
echo "=== 检查包有效性 ==="
twine check dist/*.whl dist/*.tar.gz

# 发布
echo ""
echo "=== 发布到 $MODE ==="

if [ "$MODE" == "prod" ]; then
    TWINE_USERNAME=__token__
    TWINE_PASSWORD=$PYPI_TOKEN
    twine upload dist/*.whl dist/*.tar.gz --repository-url "$TWINE_REPO"
else
    if [ -n "$TEST_PYPI_TOKEN" ]; then
        TWINE_USERNAME=__token__
        TWINE_PASSWORD=$TEST_PYPI_TOKEN
        twine upload dist/*.whl dist/*.tar.gz --repository-url "$TWINE_REPO"
    else
        twine upload dist/*.whl dist/*.tar.gz --repository testpypi
    fi
fi

echo ""
echo "✅ 发布完成！"
echo ""
if [ "$MODE" == "prod" ]; then
    echo "安装: pip install TTrans"
    echo "主页: https://pypi.org/project/TTrans/"
else
    echo "测试安装: pip install --index-url https://test.pypi.org/simple/ TTrans"
    echo "主页: https://test.pypi.org/project/TTrans/"
fi