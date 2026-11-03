-- ============================================================================
-- 补全引擎
-- 候选来源：LSP / 文件路径 / 代码片段 / 缓冲区文字
-- ============================================================================
return {
    "saghen/blink.cmp",
    version = "1.*",                                -- 锁稳定版，自带预编译模糊匹配二进制
    event = { "InsertEnter", "CmdlineEnter" },      -- 进插入或命令行才加载
    dependencies = {
        "rafamadriz/friendly-snippets",             -- 各语言常用代码片段
    },
    opts = {
        -- ===== 键位 =====
        keymap = {
            preset = "default",
            ["<Tab>"] = { "accept", "snippet_forward", "fallback" },      -- 接受选中 / 片段跳转 / 缩进
            ["<S-Tab>"] = { "snippet_backward", "fallback" },             -- 片段回退
            ["<CR>"] = { "accept", "fallback" },                          -- 回车接受 / 换行
            ["<C-j>"] = { "select_next", "fallback" },                    -- 下一个候选
            ["<C-k>"] = { "select_prev", "fallback" },                    -- 上一个候选
            ["<C-n>"] = { "select_next", "fallback" },                    -- 下一个候选（备用）
            ["<C-p>"] = { "select_prev", "fallback" },                    -- 上一个候选（备用）
            ["<Up>"] = { "select_prev", "fallback" },                     -- 方向键上
            ["<Down>"] = { "select_next", "fallback" },                   -- 方向键下
        },

        -- ===== 命令行模式 =====
        cmdline = {
            keymap = { preset = "cmdline" },           -- 用命令行原生习惯，避免回车被吃掉
            completion = {
                menu = { auto_show = true },           -- 自动弹候选
                ghost_text = { enabled = true },       -- 淡色预览，依赖 noice 渲染
            },
        },

        appearance = {
            nerd_font_variant = "mono",                -- 字体是等宽 Nerd Font
        },

        -- ===== 候选来源及优先级 =====
        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
        },

        -- ===== 候选窗口 =====
        completion = {
            documentation = {
                auto_show = true,                      -- 自动显示文档
                auto_show_delay_ms = 300,              -- 悬停 300ms 后才弹
            },
            menu = {
                draw = { treesitter = { "lsp" } },     -- 菜单里的文字用 treesitter 高亮
            },
        },

        signature = { enabled = true },                -- 函数参数提示
        fuzzy = { implementation = "prefer_rust_with_warning" }, -- 用 Rust 写的模糊匹配
    },
}
