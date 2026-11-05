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
            -- 右上角通知：借用 mini 视图，贴右上角，新消息在最上面
            topright = {
                view = "mini",
                position = { row = 1, col = "100%" },
                align = "message-right",
                timeout = 3000,
                reverse = false,
                size = { width = "auto", height = "auto", max_height = 10 },
                border = { style = "rounded" },
            },
        },
        -- 消息和通知全部走右上角浮窗，不再占用命令行，也就不会弹 hit-enter
        messages = {
            enabled = true,
            view = "topright",
            view_error = "topright",
            view_warn = "topright",
            view_history = "messages", -- :messages 仍然用独立的列表窗口
            view_search = "virtualtext", -- 搜索计数留在底部，别浮到角上
        },
        lsp = {
            progress = { enabled = false }, -- 关掉右下角 LSP 进度浮窗，只影响显示
        },
        notify = { enabled = true, view = "topright" },
        popupmenu = { enabled = false }, -- 补全菜单交给 blink，不让 noice 抢
    },
}
