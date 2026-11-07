-- ============================================================================
-- 翻译
-- 后端是 vim-translator（bing 引擎，无需 API key）
-- 它自己的浮窗绑了 CursorMoved / BufLeave 自动关闭，一聚焦就消失
-- 所以这里只借用它取翻译结果，面板我们自己开
-- ============================================================================

-- 调用翻译命令，等它出窗口，取出文本，关掉，再开一个可交互的浮窗
local function run_and_capture(cmd)
    vim.cmd(cmd)

    -- 等翻译窗口出现（请求是异步的）
    local ok = vim.wait(8000, function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_config(win).relative ~= "" then
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].filetype == "translator" then
                    return true
                end
            end
        end
        return false
    end, 50)

    if not ok then
        vim.notify("翻译超时或失败", vim.log.levels.WARN)
        return
    end

    -- 取内容
    local lines
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_config(win).relative ~= "" then
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "translator" then
                lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            end
        end
    end

    -- 关掉它自己的浮窗（含边框窗口），不碰其他浮窗
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_config(win).relative ~= "" then
            local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
            if ft == "translator" or ft == "translatorborder" then
                pcall(vim.api.nvim_win_close, win, true)
            end
        end
    end

    if not lines then
        return
    end

    -- 去掉首尾空行
    while #lines > 0 and vim.trim(lines[1]) == "" do
        table.remove(lines, 1)
    end
    while #lines > 0 and vim.trim(lines[#lines]) == "" do
        table.remove(lines)
    end

    -- 开自己的面板：可聚焦、可复制、可滚动
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = "wipe"

    -- 宽度按最长行算，最高不超过屏幕 70%
    local width = 0
    for _, line in ipairs(lines) do
        width = math.max(width, vim.fn.strdisplaywidth(line))
    end
    width = math.min(width + 4, math.floor(vim.o.columns * 0.7))

    -- 高度按行数算，最高不超过屏幕 60%
    local height = math.min(#lines, math.floor(vim.o.lines * 0.6))

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1), -- 垂直居中
        col = math.max(0, math.floor((vim.o.columns - width) / 2)), -- 水平居中
        style = "minimal",
        border = "rounded",
        title = " 翻译 ",
        title_pos = "center",
    })

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    local opts = { buffer = buf, silent = true, nowait = true }
    vim.keymap.set("n", "q", close, opts)
    vim.keymap.set("n", "<Esc>", close, opts)
end

return {
    "voldikss/vim-translator",
    cmd = { "Translate", "TranslateW", "TranslateR", "TranslateX" },
    keys = {
        {
            "<leader>tw",
            function()
                -- 可视模式下先取消选择，翻译光标下的词（和 tv 的区别就在这）
                if vim.fn.mode() ~= "n" then
                    vim.cmd("normal! \27")
                end
                -- 不带范围：插件会取光标下的词（expand('<cword>')）
                run_and_capture("TranslateW")
            end,
            mode = { "n", "v" },
            desc = "翻译光标下的词",
        },
        {
            "<leader>tv",
            function()
                -- 退出可视模式，'< '> 标记会被写入，命令再按这个范围取选中的文本
                -- 命令名是 TranslateW（带范围），不是 TranslateWV —— 后者只是 <Plug> 映射，
                -- 当命令用会报 E492: 不是编辑器的命令
                vim.cmd("normal! \27")
                run_and_capture("'<,'>TranslateW")
            end,
            mode = "v",
            desc = "翻译选中文本",
        },
    },
    init = function()
        vim.g.translator_target_lang = "zh" -- 目标语言：中文
        vim.g.translator_source_lang = "auto" -- 源语言自动识别
        vim.g.translator_window_type = "popup" -- 用浮窗
        vim.g.translator_window_max_width = 0.5 -- 宽度上限
        vim.g.translator_window_max_height = 0.5 -- 高度上限
        -- google 在国内不可达，失败后回退只会白等超时；youdao / haici 实测也拿不到内容
        vim.g.translator_default_engines = { "bing" }
    end,
}
