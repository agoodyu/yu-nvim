-- Python 专用快捷键（只在 python 缓冲区生效）
local buf = vim.api.nvim_get_current_buf()
local map = vim.keymap.set

-- 空格 r r：用 uv 跑当前文件
-- uv run 会自动找项目里的 pyproject / 虚拟环境，脚本没有依赖时也行
map("n", "<leader>rr", function()
    require("core.run").file(function(file)
        return "uv run python " .. vim.fn.shellescape(file)
    end)
end, { buffer = buf, silent = true, desc = "运行当前文件（uv）" })
