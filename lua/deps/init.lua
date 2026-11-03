-- 外部依赖清单：health 检查和启动提示共用
return {
    { bin = "lua-language-server", pkg = "lua-language-server" },
    { bin = "clangd", pkg = "clang" },
    { bin = "clang-format", pkg = "clang" },
    { bin = "basedpyright-langserver", pkg = "basedpyright-bin (AUR)" },
    { bin = "marksman", pkg = "marksman" },
    { bin = "ruff", pkg = "ruff" },
    { bin = "stylua", pkg = "stylua" },
    { bin = "prettier", pkg = "prettier" },
    { bin = "vscode-html-language-server", pkg = "vscode-langservers-extracted (AUR)" },
    { bin = "vscode-css-language-server", pkg = "vscode-langservers-extracted (AUR)" },
    { bin = "rust-analyzer", pkg = "rustup component add rust-analyzer" },
    { bin = "rustfmt", pkg = "rustup component add rustfmt" },
    { bin = "tree-sitter", pkg = "tree-sitter-cli" },
    { bin = "node", pkg = "nodejs" },
}
