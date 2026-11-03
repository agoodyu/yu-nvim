-- ============================================================================
-- LSP 通用配置
-- 诊断外观、hover 浮窗、接入缓冲区后的快捷键
-- 具体语言服务器的启用在 lua/plugins/lsp/lspconfig.lua
-- ============================================================================

-- ===== 诊断外观 =====
vim.diagnostic.config({
    virtual_text = { spacing = 4, prefix = "●" }, -- 行尾虚拟文字，圆点开头，离代码 4 格
    signs = true, -- 左侧符号列显示图标
    underline = true, -- 出错位置加下划线
    severity_sort = true, -- 同一行多个诊断时按严重程度排序
    update_in_insert = true, -- 插入模式下也刷新诊断
    float = { border = "rounded", source = true }, -- <leader>dd 浮窗：圆角，显示来源
    jump = { float = true }, -- ]d / [d 跳转时用浮窗预览
})

-- 类型提示的全局开关，LspAttach 和新开的缓冲区都读它
vim.g.inlay_hints = true

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

        -- 代码操作：过滤掉没有标题的条目
        -- 有些服务器只给 provider 名字（比如 basedpyright），
        -- 这种条目在菜单里完全看不出能干什么，不如不显示
        local function code_action()
            vim.lsp.buf.code_action({
                filter = function(action)
                    return type(action.title) == "string" and action.title ~= ""
                end,
            })
        end

        map("n", "<leader>ca", code_action, opts("代码操作"))
        map("x", "<leader>ca", code_action, opts("代码操作"))

        -- 类型内联提示：变量 / 参数后面直接显示推断出来的类型
        -- 只有服务器支持才开，不支持时 enable 是空操作，键位也别占位置
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client:supports_method("textDocument/inlayHint") then
            if vim.g.inlay_hints then
                vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
            end

            -- 插入模式下隐藏、离开后恢复：每敲一个字符服务器都要重算一遍提示，
            -- 一边打字一边刷新会卡，而且提示跳来跳去很干扰
            local group = vim.api.nvim_create_augroup("InlayHints" .. ev.buf, { clear = true })
            vim.api.nvim_create_autocmd("InsertEnter", {
                group = group,
                buffer = ev.buf,
                callback = function()
                    vim.lsp.inlay_hint.enable(false, { bufnr = ev.buf })
                end,
            })
            vim.api.nvim_create_autocmd("InsertLeave", {
                group = group,
                buffer = ev.buf,
                callback = function()
                    if vim.g.inlay_hints then
                        vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
                    end
                end,
            })

            -- 全局开关：切换后所有缓冲区一起生效，新开的文件也遵守
            map("n", "<leader>ih", function()
                vim.g.inlay_hints = not vim.g.inlay_hints
                vim.lsp.inlay_hint.enable(vim.g.inlay_hints)
                vim.notify(
                    vim.g.inlay_hints and "类型提示：已开启" or "类型提示：已关闭"
                )
            end, opts("类型提示开关"))
        end

        -- 诊断
        map("n", "<leader>dd", vim.diagnostic.open_float, opts("查看诊断"))
        map("n", "[d", function()
            vim.diagnostic.jump({ count = -1 })
        end, opts("上一个诊断"))
        map("n", "]d", function()
            vim.diagnostic.jump({ count = 1 })
        end, opts("下一个诊断"))
        -- 只在错误之间跳，不被警告干扰
        map("n", "[e", function()
            vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
        end, opts("上一个错误"))
        map("n", "]e", function()
            vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
        end, opts("下一个错误"))
    end,
})
