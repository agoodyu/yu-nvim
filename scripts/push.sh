#!/usr/bin/env bash
# 一键格式化、提交并推送配置
#
# 用法:
#   push.sh "提交说明"              只格式化 + 提交 + 推送
#   push.sh "提交说明" v1.1.0       额外打标签并创建 GitHub Release

set -euo pipefail

cd "$(dirname "$0")/.."

if [ $# -lt 1 ]; then
    echo "用法: $(basename "$0") \"提交说明\" [版本号]" >&2
    echo "示例: $(basename "$0") \"加个新插件\" v1.1.0" >&2
    exit 1
fi

MSG="$1"
TAG="${2:-}"

# 1. 统一代码格式（.stylua.toml）
if command -v stylua >/dev/null 2>&1; then
    stylua .
    echo "==> 已按 .stylua.toml 格式化"
fi

# 2. 有没有改动
if git diff --quiet && git diff --cached --quiet; then
    echo "==> 没有改动，无需提交"
    exit 0
fi

# 3. 列出改动
echo "==> 本次改动:"
git status --short

# 4. 提交
git add -A
git commit -m "$MSG"
echo "==> 已提交"

# 5. 推送
git push
echo "==> 已推送"

# 6. 可选：打标签 + 创建 Release
if [ -n "$TAG" ]; then
    git tag -a "$TAG" -m "$TAG $MSG"
    git push origin "$TAG"
    echo "==> 标签 $TAG 已推送"

    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
        gh release create "$TAG" --title "$TAG" --generate-notes
        echo "==> Release 已创建: https://github.com/agoodyu/yu-nvim/releases/tag/$TAG"
    else
        echo "!! 未安装 gh 或未登录，跳过 Release 创建（标签已推送）"
    fi
fi

echo
echo "==> 完成。当前最新标签: $(git tag --sort=-v:refname | head -1)"
