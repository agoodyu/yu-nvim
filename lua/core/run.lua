-- ============================================================================
-- 运行当前文件
-- 各语言的 ftplugin 只负责拼命令，存盘 / 校验 / 交给底部终端都在这里
-- ============================================================================

local M = {}

-- build(file) 返回要执行的 shell 命令
function M.file(build)
    local buf = vim.api.nvim_get_current_buf()
    local file = vim.api.nvim_buf_get_name(buf)
    if file == "" then
        vim.notify("先保存文件再运行", vim.log.levels.WARN)
        return
    end

    if vim.bo[buf].modified then
        vim.cmd("silent write") -- 跑之前先存盘，否则跑的是旧代码
    end

    require("core.terminal").run(build(file))
end

return M
