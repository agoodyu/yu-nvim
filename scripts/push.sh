#!/usr/bin/env bash
# 一键格式化、提交并推送配置
#
# 用法:
#   push.sh "提交说明"              只格式化 + 提交 + 推送
#   push.sh "提交说明" v1.1.0       额外打标签并创建 GitHub Release
#
# 说明:
#   - 工作区干净且不传版本号时直接退出；传了版本号则会继续推送 + 打标签
#   - 标签在提交前先校验，重复会立刻失败，不会留下"提交了但没打上标签"的半截状态

set -euo pipefail

cd "$(dirname "$0")/.."

MSG="${1:-}"
TAG="${2:-}"

if [ -z "$MSG" ]; then
    echo "用法: $(basename "$0") \"提交说明\" [版本号]" >&2
    echo "示例: $(basename "$0") \"加个新插件\" v1.1.0" >&2
    exit 1
fi

# 1. 版本号先校验：格式、本地重名、远端重名，都在动仓库之前做完
if [ -n "$TAG" ]; then
    case "$TAG" in
        v[0-9]*) ;;
        *)
            echo "!! 版本号要以 v 开头，例如 v1.1.0" >&2
            exit 1
            ;;
    esac
    if git rev-parse -q --verify "refs/tags/$TAG" >/dev/null; then
        echo "!! 本地已有标签 $TAG，换一个版本号" >&2
        exit 1
    fi
    if [ -n "$(git ls-remote --tags origin "refs/tags/$TAG")" ]; then
        echo "!! 远端已有标签 $TAG，换一个版本号" >&2
        exit 1
    fi
fi

# 2. 统一代码格式（.stylua.toml）
if command -v stylua >/dev/null 2>&1; then
    stylua .
    echo "==> 已按 .stylua.toml 格式化"
else
    echo "!! 未安装 stylua，跳过格式化"
fi

# 3. 有没有改动：用 --porcelain，能看到 git diff 漏掉的未跟踪文件
if [ -n "$(git status --porcelain)" ]; then
    echo "==> 本次改动:"
    git status --short

    git add -A
    git commit -m "$MSG"
    echo "==> 已提交: $(git log --oneline -1)"
elif [ -z "$TAG" ]; then
    echo "==> 没有改动，无需提交"
    exit 0
else
    echo "==> 没有改动，跳过提交，直接在已有提交上打标签"
fi

# 4. 推送（首次推送没有上游时自动绑定）
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
    git push
else
    git push -u origin "$BRANCH"
fi
echo "==> 已推送 $BRANCH"

# 5. 可选：打标签 + 创建 Release
if [ -n "$TAG" ]; then
    git tag -a "$TAG" -m "$TAG $MSG"
    git push origin "$TAG"
    echo "==> 标签 $TAG 已推送"

    REMOTE="$(git remote get-url origin 2>/dev/null || true)"
    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1 && [[ "$REMOTE" == *github.com* ]]; then
        gh release create "$TAG" --title "$TAG" --generate-notes
        echo "==> Release 已创建: $(gh release view "$TAG" --json url -q .url)"
    else
        echo "!! gh 未安装/未登录，或 origin 不是 GitHub，跳过 Release 创建（标签已推送）"
    fi
fi

echo
echo "==> 完成。当前最新标签: $(git tag --sort=-v:refname | head -1)"
