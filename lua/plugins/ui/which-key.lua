-- ============================================================================
-- 按键提示
-- 按下前缀键时弹出后续按键
-- 每个键的说明来自它自己的 desc，这里只负责给前缀取分组名
-- 分组名和 README「键位」一节的标题一一对应；空格 ? 打开完整总览
--
-- mode 写全 n / x / o：which-key 的 spec 默认只作用于普通模式，
-- 补上之后可视模式、操作符待定里的分组名和普通模式一致
-- ============================================================================
return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        spec = {
            -- ===== 空格（leader）分组 =====
            { "<leader>b", group = "缓冲区", mode = { "n", "x", "o" } }, -- bp / bo / bw
            { "<leader>c", group = "代码", mode = { "n", "x", "o" } }, -- ca
            { "<leader>d", group = "诊断与调试", mode = { "n", "x", "o" } }, -- dd / db / du
            { "<leader>g", group = "Git", mode = { "n", "x", "o" } }, -- gp / gs / gr / gb
            { "<leader>j", group = "标签跳转", mode = { "n", "x", "o" } }, -- js / jS / jR（flash）
            { "<leader>i", group = "类型提示", mode = { "n", "x", "o" } }, -- ih / it
            { "<leader>m", group = "浏览器预览", mode = { "n", "x", "o" } }, -- mp / mP
            { "<leader>r", group = "运行", mode = { "n", "x", "o" } }, -- rr / rt / rd，rust 另有 rk/re/rm/rc/rp/rj
            { "<leader>t", group = "翻译", mode = { "n", "x", "o" } }, -- tw / tv
            { "<leader>u", group = "sudo 提权", mode = { "n", "x", "o" } }, -- uW / uR
            { "<leader>w", group = "窗口与分屏", mode = { "n", "x", "o" } }, -- wv / ws / wc / wo
            { "<leader>x", group = "TODO", mode = { "n", "x", "o" } }, -- xt
            { "<leader>z", group = "折叠", mode = { "n", "x", "o" } }, -- za / zr / zm

            -- ===== 不带空格的常用前缀 =====
            { "g", group = "跳转", mode = { "n", "x", "o" } }, -- gd / gD / gI / gy / gO
            { "gr", group = "LSP", mode = { "n", "x", "o" } }, -- grn / gra / grr / gri / grt / grx
            { "gc", group = "注释", mode = { "n", "x", "o" } }, -- gcc / gcO / gco / gcI / gcA
            { "z", group = "折叠", mode = { "n", "x", "o" } }, -- za / zR / zM
            { "[", group = "上一个", mode = { "n", "x", "o" } }, -- [d / [e / [h / [b
            { "]", group = "下一个", mode = { "n", "x", "o" } }, -- ]d / ]e / ]h / ]b
            { "<C-w>", group = "窗口", mode = { "n", "x", "o" } }, -- nvim 自带的 <C-w> 系列
        },
    },
}
