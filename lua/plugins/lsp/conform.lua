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
            python = { "ruff_organize_imports", "ruff_format" }, -- 先整理 import 再格式化
            html = { "prettier" },
            css = { "prettier" },
            markdown = { "prettier" },
            lua = { "stylua" },
        },
        format_on_save = {
            timeout_ms = 3000, -- 超过 3 秒放弃，避免卡住写入
            lsp_format = "never", -- 只用 conform 的格式化器，避免和 LSP 重复格式化
        },
    },
}
