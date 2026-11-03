-- ============================================================================
-- LSP 通用配置
-- 诊断外观、hover 浮窗、接入缓冲区后的快捷键
-- 具体语言服务器的启用在 lua/plugins/lsp/lspconfig.lua
-- ============================================================================

-- ===== 诊断外观 =====
vim.diagnostic.config({
    virtual_text = { spacing = 4, prefix = "●" }, -- 行尾虚拟文字，圆点开头，离代码 4 格
    signs = true,                                  -- 左侧符号列显示图标
    underline = true,                              -- 出错位置加下划线
    severity_sort = true,                          -- 同一行多个诊断时按严重程度排序
    update_in_insert = true,                       -- 插入模式下也刷新诊断
    float = { border = "rounded", source = true }, -- <leader>dd 浮窗：圆角，显示来源
    jump = { float = true },                       -- ]d / [d 跳转时用浮窗预览
})

local map = vim.keymap.set

-- ===== hover 浮窗 =====
-- 默认浮窗不抢焦点，按键都落在代码窗口里
-- 这里自己发请求、自己开窗，打开后把焦点切进去，滚动键直接可用
-- q 或 Esc 关闭并回到原窗口

local function hover()
    local buf = vim.api.nvim_get_current_buf()                   -- 当前缓冲区
    local params = vim.lsp.util.make_position_params(0, "utf-8") -- 光标位置参数
    local origin = vim.api.nvim_get_current_win()                -- 记下原窗口，关闭后回去

    vim.lsp.buf_request(buf, "textDocument/hover", params, function(err, result, ctx)
        if err or not result or vim.tbl_isempty(result) then
            return -- 没有内容就不开窗
        end

        local ok, fb, win = pcall(vim.lsp.handlers.hover, nil, result, ctx, {
            border = "rounded",
            max_height = math.max(6, math.floor(vim.o.lines * 0.6)), -- 最高屏幕的 60%
            focusable = true,                                        -- 允许聚焦
            focus_id = "hover",                                      -- 同 id 的浮窗复用
            close_events = { "InsertEnter" },                        -- 进插入模式时自动关
        })
        if not (ok and win and fb) then
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
        map("n", "q", close, opts)     -- q 关闭
        map("n", "<Esc>", close, opts) -- Esc 关闭

        vim.wo[win].cursorline = true     -- 高亮当前行，滚动时能看清位置
        vim.api.nvim_set_current_win(win) -- 焦点切进浮窗
    end)
end

-- ===== 接入缓冲区后的快捷键 =====
-- 只在挂了语言服务器的 buffer 生效
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local function opts(desc)
            return { buffer = ev.buf, silent = true, desc = desc }
        end

        -- 悬停
        map("n", "K", hover, opts("悬停文档"))

        -- 跳转
        map("n", "gd", vim.lsp.buf.definition, opts("跳转定义"))
        map("n", "gD", vim.lsp.buf.declaration, opts("跳转声明"))
        map("n", "gI", vim.lsp.buf.implementation, opts("跳转实现"))
        map("n", "gy", vim.lsp.buf.type_definition, opts("跳转类型定义"))

        -- 编辑
        map("n", "<leader>rn", vim.lsp.buf.rename, opts("重命名符号"))
        map("n", "<leader>ca", vim.lsp.buf.code_action, opts("代码操作"))
        map("x", "<leader>ca", vim.lsp.buf.code_action, opts("代码操作"))

        -- 诊断
        map("n", "<leader>dd", vim.diagnostic.open_float, opts("查看诊断"))
        map("n", "[d", function()
            vim.diagnostic.jump({ count = -1 })
        end, opts("上一个诊断"))
        map("n", "]d", function()
            vim.diagnostic.jump({ count = 1 })
        end, opts("下一个诊断"))
    end,
})
