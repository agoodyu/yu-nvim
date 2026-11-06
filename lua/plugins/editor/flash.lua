-- ============================================================================
-- 标签跳转（folke/flash.nvim）
-- 按键全放在 <leader>j 下，语义和上游一致：s 跳转 / S 选节点 / r 远程 / R 搜索
-- 优化都在"少做事"这一侧，没有改功能语义：
--   1. 不设 event，只在按键时加载 —— 启动完成后 flash 完全没被 require
--   2. search 只搜当前窗口、pattern 限长，避免大文件白扫
--   3. backdrop 保持默认开启：跳转时非匹配区域变灰，只有目标保持原色
--   4. 关掉 f/t 增强，f/t 保持原生（跳转走 <leader>j s，不需要这套钩子）
-- ============================================================================
return {
    "folke/flash.nvim",
    keys = {
        {
            "<leader>js",
            mode = { "n", "x", "o" },
            function()
                require("flash").jump()
            end,
            desc = "标签跳转",
        },
        {
            "<leader>jS",
            mode = { "n", "x", "o" },
            function()
                require("flash").treesitter()
            end,
            desc = "选中语法节点",
        },
        {
            "<leader>jR",
            mode = { "o", "x" },
            function()
                require("flash").treesitter_search()
            end,
            desc = "语法树搜索",
        },
    },
    config = function(_, opts)
        require("flash").setup(opts)

        -- tokyonight 的默认是「浅紫字 + 亮粉底」（#c8d3f5 on #ff007c），对比度 2.5:1 看不清。
        -- 这里只动标签本身：近黑底 + 荧光绿字（约 13:1），匹配那两层保持默认
        local function flash_hl()
            vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#39ff14", bg = "#16161e", bold = true })
        end
        flash_hl()
        vim.api.nvim_create_autocmd("ColorScheme", { callback = flash_hl })
    end,
    opts = {
        search = {
            multi_window = false, -- 只搜当前窗口
            max_length = 30, -- pattern 最长 30 字符，防止白扫
        },
        jump = {
            -- autojump 没开：实测输入 "thr" 时只剩一个匹配就直接跳了，后面还
            -- 没打完的字符会漏到普通模式里当命令执行，容易误伤
            register = true, -- 写进搜索寄存器，跳完 n / N 能接着找
            history = true, -- 记进搜索历史，/ + ↑ 能翻出来
        },
        modes = {
            char = { enabled = false }, -- f / t / F / T 保持原生
        },
    },
}
