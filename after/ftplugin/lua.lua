-- Lua 专用快捷键（只在 lua 缓冲区生效）
local buf = vim.api.nvim_get_current_buf()

-- 空格 r r：用系统 lua 跑当前文件
vim.keymap.set("n", "<leader>rr", function()
    require("core.run").file(function(file)
        return "lua " .. vim.fn.shellescape(file)
    end)
end, { buffer = buf, silent = true, desc = "运行当前文件（lua）" })
