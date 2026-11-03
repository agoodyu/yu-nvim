#!/usr/bin/env fish
# nvim 外部依赖安装（Arch / CachyOS，可重复执行）

set -l pkgs git curl tar gcc make unzip nodejs tree-sitter-cli \
    clang marksman lua-language-server stylua prettier ruff

echo "==> 安装官方源软件包"
sudo pacman -S --needed $pkgs

if command -q paru
    echo "==> 安装 AUR 软件包"
    # 逐个安装，避免其中一个失败导致后面全部跳过
    for pkg in basedpyright-bin vscode-langservers-extracted codelldb-bin
        paru -S --needed $pkg
    end
else
    echo "!! 未找到 paru，请手动安装：basedpyright-bin vscode-langservers-extracted codelldb-bin"
end

if not command -q rustup
    echo "==> 安装 rustup"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
end

echo "==> 补齐 rust 组件"
rustup component add rust-analyzer rustfmt clippy

echo "==> 完成，运行 nvim 让其安装插件"
