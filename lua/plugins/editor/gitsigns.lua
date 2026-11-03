-- ============================================================================
-- Git 标记
-- 左侧符号列显示增删改，支持逐块跳转、暂存、撤销、预览
-- ============================================================================
return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        signs = {
            add = { text = "▎" },          -- 新增行
            change = { text = "▎" },       -- 修改行
            delete = { text = "" },       -- 删除行（显示在上一行）
            topdelete = { text = "" },    -- 文件顶部的删除
            changedelete = { text = "▎" }, -- 修改并删除
            untracked = { text = "▎" },    -- 未跟踪文件
        },
        signs_staged = {
            add = { text = "▎" },          -- 已暂存的新增
            change = { text = "▎" },       -- 已暂存的修改
        },
        on_attach = function(bufnr)
            local gs = require("gitsigns")

            local function map(lhs, rhs, desc)
                vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
            end

            map("]h", gs.next_hunk, "下一个改动")     -- 跳到下一个 hunk
            map("[h", gs.prev_hunk, "上一个改动")     -- 跳到上一个 hunk
            map("<leader>gp", gs.preview_hunk, "预览改动")
            map("<leader>gs", gs.stage_hunk, "暂存改动")
            map("<leader>gr", gs.reset_hunk, "撤销改动")
            map("<leader>gb", function()
                gs.blame_line({ full = true })        -- 显示这一行的提交历史
            end, "查看行历史")
        end,
    },
}
