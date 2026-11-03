#!/usr/bin/env bash
# 推送 + 打标签 + 创建 GitHub Release
#
# 用法:
#   release.sh v1.1.0                版本号同时作为提交说明
#   release.sh v1.1.0 "说明文字"     自定义提交说明
#
# 和 push.sh 的区别:
#   push.sh     日常改动用，工作区干净时直接退出，不会打标签
#   release.sh  专门发版本，工作区干净也会继续推送、打标签、建 Release

set -euo pipefail

cd "$(dirname "$0")/.."

TAG="${1:-}"
MSG="${2:-$TAG}"

if [ -z "$TAG" ]; then
    echo "用法: $(basename "$0") v1.1.0 [提交说明]" >&2
    echo "示例: $(basename "$0") v1.1.0" >&2
    exit 1
fi

case "$TAG" in
    v[0-9]*) ;;
    *)
        echo "!! 版本号要以 v 开头，例如 v1.1.0" >&2
        exit 1
        ;;
esac

# 标签不能重名，本地和远端都要查
if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
    echo "!! 本地已有标签 $TAG，换一个版本号" >&2
    exit 1
fi
if [ -n "$(git ls-remote --tags origin "refs/tags/$TAG")" ]; then
    echo "!! 远端已有标签 $TAG，换一个版本号" >&2
    exit 1
fi

BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# 1. 有改动就先格式化 + 提交；没有改动也继续，标签要打在已有提交上
if [ -n "$(git status --porcelain)" ]; then
    if command -v stylua >/dev/null 2>&1; then
        stylua .
        echo "==> 已按 .stylua.toml 格式化"
    fi
    echo "==> 本次改动:"
    git status --short
    git add -A
    git commit -m "$MSG"
    echo "==> 已提交"
else
    echo "==> 工作区干净，跳过提交"
fi

# 2. 先推分支，Release 才会指向最新提交
git push
echo "==> 已推送 $BRANCH"

# 3. 打附注标签并单独推送，推分支不会带走标签
git tag -a "$TAG" -m "$TAG $MSG"
git push origin "$TAG"
echo "==> 标签 $TAG 已推送"

# 4. 创建 Release（需要 gh 已登录，且 origin 指向 GitHub）
REMOTE="$(git remote get-url origin 2>/dev/null || true)"
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1 && [[ "$REMOTE" == *github.com* ]]; then
    gh release create "$TAG" --title "$TAG" --generate-notes
    echo "==> Release 已创建: $(gh release view "$TAG" --json url -q .url)"
else
    echo "!! gh 未安装/未登录，或 origin 不是 GitHub，跳过 Release 创建（标签已推送）"
fi

echo
echo "==> 完成。当前最新标签: $(git tag --sort=-v:refname | head -1)"
