-- ============================================================================
-- 语言服务器
-- Rust 由 rustaceanvim 单独接管，不在这里
-- ============================================================================
return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" }, -- 打开文件时才加载
    config = function()
        -- Lua：让 lua_ls 认识 vim 全局变量，按 LuaJIT 解析
        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    runtime = { version = "LuaJIT" },        -- nvim 用 LuaJIT
                    diagnostics = { globals = { "vim" } },   -- 不把 vim 报成未定义
                    telemetry = { enable = false },          -- 关闭遥测
                },
            },
        })

        -- Python：basedpyright，pyright 的社区分支，预编译二进制不需要 node
        vim.lsp.config("basedpyright", {
            settings = {
                basedpyright = {
                    analysis = { typeCheckingMode = "standard" }, -- 类型检查强度
                },
            },
        })

        -- 启用的服务器
        vim.lsp.enable({
            "clangd",       -- C / C++
            "basedpyright", -- Python
            "html",         -- HTML
            "cssls",        -- CSS
            "marksman",     -- Markdown
            "lua_ls",       -- Lua
        })
    end,
}
