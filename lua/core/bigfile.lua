-- ============================================================================
-- 大文件 / 超长行降级
-- 实测：普通文件按一次 j 约 0.6ms，其中 0.49ms 是 treesitter 重画；
-- 一行 2800 字符的文件涨到 4.4ms，几十万行的文件更糟，移动就粘手
-- 超过阈值就把最贵的几层关掉：语法高亮、光标行、相对行号、treesitter 折叠与缩进
-- ============================================================================

-- ===== 大文件 / 超长行降级 =====
-- 实测（scripts/bench-keys.lua）：普通文件按一次 j 约 0.6ms，其中 0.49ms 花在
-- treesitter 重画；一行 2800 字符的文件涨到 4.4ms，几十万行的文件更糟，移动就粘手
-- 超过阈值就把最贵的几层关掉：语法高亮、光标行、相对行号、treesitter 折叠与缩进
-- 阈值比日常文件高很多——README 538 行 / 最长 274 字符，lua 配置最长 99 字符，都不会命中

local heavy = {
    lines = 2000, -- 行数
    bytes = 400 * 1024, -- 文件大小
    width = 1000, -- 单行字符数
}

-- 只在行数没超阈值时才扫宽度，避免打开超大文件先扫一遍
local function widest(buf, upto)
    local width = 0
    for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, upto, false)) do
        if #line > width then
            width = #line
        end
    end
    return width
end

local function too_heavy(buf)
    local lines = vim.api.nvim_buf_line_count(buf)
    if lines > heavy.lines then
        return ("%d 行"):format(lines)
    end

    -- 宽度放前面：长行的文件往往也大，先认出长行才能顺手开折行
    local width = widest(buf, lines)
    if width > heavy.width then
        return ("最长行 %d 字符"):format(width), true
    end

    local name = vim.api.nvim_buf_get_name(buf)
    local size = name ~= "" and vim.fn.getfsize(name) or -1
    if size > heavy.bytes then
        return ("%.0f KB"):format(size / 1024)
    end
end

-- 折叠从 0.10 起是窗口选项，所以这一组都按窗口设，不能按缓冲区设
local function window_opts(win, long_line)
    vim.wo[win].cursorline = false
    vim.wo[win].relativenumber = false
    vim.wo[win].foldmethod = "manual"
    vim.wo[win].foldexpr = "0"
    if long_line then
        -- 长行开折行后只画屏幕上那一段，实测比横向滚动快三成
        vim.wo[win].wrap = true
        vim.w[win].wrap_from_bigfile = true -- 记一下，换文件时要还原
    end
end

vim.api.nvim_create_autocmd("FileType", {
    callback = function(ev)
        if vim.bo[ev.buf].buftype ~= "" then
            return -- 终端、neo-tree、帮助这类缓冲区不用管
        end

        local reason, long_line = too_heavy(ev.buf)
        if not reason then
            return
        end

        -- 标记要先同步写下去：treesitter.lua 的 FileType 回调随后会读它
        vim.b[ev.buf].bigfile = reason
        vim.schedule(function()
            pcall(vim.treesitter.stop, ev.buf)
            vim.bo[ev.buf].indentexpr = ""
            for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
                window_opts(win, long_line)
            end
            vim.notify(
                ("大文件降级：%s，已关掉语法高亮和光标行"):format(reason),
                vim.log.levels.INFO
            )
        end)
    end,
    desc = "超大文件 / 超长行降级",
})

-- 已经降级的缓冲区在新窗口打开时，窗口选项要再关一次
vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function(ev)
        local reason = vim.b[ev.buf].bigfile
        if reason then
            window_opts(0, reason:find("最长行") ~= nil)
        elseif vim.w.wrap_from_bigfile then
            -- 上一个文件是长行降级过的，wrap 是窗口选项，别让它粘到普通文件上
            vim.wo.wrap = false
            vim.w.wrap_from_bigfile = nil
        end
    end,
    desc = "降级缓冲区的新窗口 / 还原折行",
})
