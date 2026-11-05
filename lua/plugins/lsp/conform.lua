-- ============================================================================
-- 格式化
-- 保存时自动格式化，也可以手动 <leader>f
-- ============================================================================
return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" }, -- 写入前才加载
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>f",
            function()
                require("conform").format({ async = true, lsp_format = "never" })
            end,
            desc = "格式化当前文件",
        },
    },
    opts = {
        -- ===== 各语言的格式化器 =====
        formatters_by_ft = {
            rust = { "rustfmt" }, -- rustup 自带
            c = { "clang_format" }, -- clang 包自带
            cpp = { "clang_format" },
            -- 保存时依次：自动修可安全修复的 lint 问题（未用 import、多余代码）→ 整理 import → 格式化
            python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
            html = { "prettier" },
            css = { "prettier" },
            markdown = { "prettier" },
            lua = { "stylua" },
        },
        -- rustfmt 会从 Cargo.toml 读 edition；没有 Cargo.toml 的单文件默认按 2021 解析，
        -- 和当前工具链（1.85+ 新建 crate 为 2024）对不上，这里对齐到 2024
        formatters = {
            rustfmt = { options = { default_edition = "2024" } },
        },
        format_on_save = {
            timeout_ms = 3000, -- 超过 3 秒放弃，避免卡住写入
            lsp_format = "never", -- 只用 conform 的格式化器，避免和 LSP 重复格式化
        },
    },
}
