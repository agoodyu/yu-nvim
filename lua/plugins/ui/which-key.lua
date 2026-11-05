-- ============================================================================
-- 按键提示
-- 按下前缀键时弹出后续按键和说明
-- 说明来自各 keymap 的 desc，这里只补中文分组名，不定义按键
-- ============================================================================
return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        spec = {
            { "<leader>c", group = "代码" },
            { "<leader>d", group = "诊断/调试" },
            { "<leader>f", desc = "格式化当前文件" },
            { "<leader>g", group = "Git" },
            { "<leader>h", group = "跳转" },
            { "<leader>r", group = "运行代码" },
            -- <leader>rr 不在这里定义：各语言的 ftplugin 用 buffer-local 映射注册，
            -- which-key 会按当前缓冲区收集，所以面板天然跟着文件类型变
            { "<leader>t", group = "翻译" },
            { "<leader>u", group = "sudo 提权" },
            { "<leader>w", group = "窗口/分屏" },
            { "<leader>z", group = "折叠" },

            { "g", group = "跳转" }, -- gd / gD / gI / gy
            { "[", group = "上一个" }, -- [d
            { "]", group = "下一个" }, -- ]d
        },
    },
}
