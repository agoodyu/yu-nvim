-- ============================================================================
-- 底部终端
-- 工作目录跟随当前文件，再次触发时关闭窗口并清理 buffer
-- 对外提供 toggle()（空格 T）和 run(cmd)（语言运行用）
-- ============================================================================

local M = {}

local term_win -- 记住终端窗口，用于开关切换

-- 关掉终端窗口并删 buffer
-- 只关窗口的话 buffer 会留在内存里，bufferline 上会多一个空标签
local function close()
    if not (term_win and vim.api.nvim_win_is_valid(term_win)) then
        return
    end
    local buf = vim.api.nvim_win_get_buf(term_win)
    vim.api.nvim_win_close(term_win, true)
    if vim.api.nvim_buf_is_valid(buf) then
        pcall(vim.api.nvim_buf_delete, buf, { force = true }) -- force 会杀掉终端内进程
    end
    term_win = nil
end

-- 打开底部终端，cmd 为空时就是普通 shell
local function open(cmd)
    -- 工作目录跟随当前文件，没有文件就用 nvim 的 cwd
    local dir = vim.fn.expand("%:p:h")
    if dir == "" or vim.fn.isdirectory(dir) == 0 then
        dir = vim.fn.getcwd()
    end

    vim.cmd("botright split") -- 底部水平分屏
    term_win = vim.api.nvim_get_current_win() -- 记录新窗口
    vim.cmd("lcd " .. vim.fn.fnameescape(dir)) -- 只改这个窗口的 cwd，不影响其他
    vim.cmd("terminal " .. cmd) -- cmd 为空时启动 $SHELL
    vim.cmd("startinsert") -- 直接进插入模式
end

-- 空格 T：开 / 关终端
function M.toggle()
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        close()
        return
    end
    open("")
end

-- 在底部终端里跑一条命令，重复调用会先关掉上一个终端
function M.run(cmd)
    close()
    open(cmd)
end

vim.keymap.set("n", "<leader>T", M.toggle, { silent = true, desc = "终端开关" })

vim.api.nvim_create_autocmd("TermOpen", {
    callback = function(ev)
        -- 终端里按 Esc 或 jj 回到普通模式
        vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = ev.buf, silent = true })
        vim.keymap.set("t", "jj", "<C-\\><C-n>", { buffer = ev.buf, silent = true })

        -- 用别的方式关窗口（:q 等）时也把 buffer 清掉
        vim.api.nvim_create_autocmd("BufWinLeave", {
            buffer = ev.buf,
            once = true,
            callback = function()
                vim.schedule(function()
                    -- 确认这个 buffer 已经没有任何窗口显示了再删
                    if vim.api.nvim_buf_is_valid(ev.buf) and #vim.fn.win_findbuf(ev.buf) == 0 then
                        pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
                    end
                end)
            end,
        })
    end,
})

return M
