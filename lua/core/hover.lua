-- ============================================================================
-- LSP hover 浮窗
-- 自己发 textDocument/hover 请求、自己开窗，打开后把焦点切进去
-- 默认浮窗不抢焦点，按键都落在代码窗口里；这里 q / Esc 关闭并回到原窗口
-- ============================================================================

local map = vim.keymap.set

-- ===== hover 浮窗 =====
-- 默认浮窗不抢焦点，按键都落在代码窗口里
-- 这里自己发请求、自己开窗，打开后把焦点切进去，滚动键直接可用
-- q 或 Esc 关闭并回到原窗口

local function hover()
    local buf = vim.api.nvim_get_current_buf() -- 当前缓冲区
    local params = vim.lsp.util.make_position_params(0, "utf-8") -- 光标位置参数
    local origin = vim.api.nvim_get_current_win() -- 记下原窗口，关闭后回去

    vim.lsp.buf_request(buf, "textDocument/hover", params, function(err, result, _)
        if err or not result or vim.tbl_isempty(result) then
            return -- 没有内容就不开窗
        end

        -- 自己渲染浮窗：vim.lsp.handlers.hover 在 0.12 已标记废弃
        local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)

        -- 去掉首尾空行
        -- 官方推荐 vim.split + trimempty，但那个会连中间的代码块空行一起删掉
        -- vim.lsp.util.trim_empty_lines 已废弃，这里自己实现同样的首尾裁剪
        while #lines > 0 and vim.trim(lines[1]) == "" do
            table.remove(lines, 1)
        end
        while #lines > 0 and vim.trim(lines[#lines]) == "" do
            table.remove(lines)
        end

        if #lines == 0 then
            return
        end

        local fb, win = vim.lsp.util.open_floating_preview(lines, "markdown", {
            border = "rounded",
            max_height = math.max(6, math.floor(vim.o.lines * 0.6)), -- 最高屏幕的 60%
            focusable = true, -- 允许聚焦
        })
        if not win then
            return
        end

        -- 关闭浮窗并回到原窗口
        local function close()
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
            if vim.api.nvim_win_is_valid(origin) then
                vim.api.nvim_set_current_win(origin)
            end
        end

        local opts = { buffer = fb, silent = true, nowait = true }
        map("n", "q", close, opts) -- q 关闭
        map("n", "<Esc>", close, opts) -- Esc 关闭

        vim.wo[win].cursorline = true -- 高亮当前行，滚动时能看清位置
        vim.api.nvim_set_current_win(win) -- 焦点切进浮窗
    end)
end

return hover
