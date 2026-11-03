-- ============================================================================
-- 命令行浮窗
-- 只接管 cmdline 的显示，消息和补全菜单保持原样
-- ============================================================================
return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim", -- 浮窗渲染依赖
    },
    opts = {
        cmdline = {
            enabled = true, -- 接管命令行显示
            view = "cmdline_popup", -- 用浮窗，不用底部单行
        },
        views = {
            cmdline_popup = {
                position = { row = "0%", col = "50%" }, -- 顶部、水平居中
                size = { width = 60, height = "auto" }, -- 宽 60，高度随内容
                border = { style = "rounded" }, -- 圆角边框
            },
        },
        messages = { enabled = false }, -- 消息还用原生，避免撑开 cmdheight=0 的行
        lsp = {
            progress = { enabled = false }, -- 关掉右下角 LSP 进度浮窗，只影响显示
        },
        notify = { enabled = false }, -- vim.notify 保持原生
        popupmenu = { enabled = false }, -- 补全菜单交给 blink，不让 noice 抢
    },
}
