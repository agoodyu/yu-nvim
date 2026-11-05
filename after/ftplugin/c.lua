-- C 专用快捷键（只在 c 缓冲区生效）
local buf = vim.api.nvim_get_current_buf()

-- 空格 r r：clang 编译到 /tmp 再直接运行，不往源码目录丢产物
vim.keymap.set("n", "<leader>rr", function()
    require("core.run").file(function(file)
        local out = "/tmp/nvim-run-" .. vim.fn.fnamemodify(file, ":t:r")
        return ("clang -g -O0 -o %s %s && %s"):format(
            vim.fn.shellescape(out),
            vim.fn.shellescape(file),
            vim.fn.shellescape(out)
        )
    end)
end, { buffer = buf, silent = true, desc = "编译并运行（clang）" })
