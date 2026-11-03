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

-- ===== 本行变量类型 =====
-- inlay hints 由服务器决定发不发：`a = 18` 这种字面量赋值它认为类型显然，不发提示
-- 这里按需自己发 hover 请求，把光标所在行里每个变量的类型拼出来

-- 常见的语言关键字，没必要为它们发请求
local keywords = {
    ["and"] = true,
    ["as"] = true,
    ["assert"] = true,
    ["async"] = true,
    ["await"] = true,
    ["break"] = true,
    ["case"] = true,
    ["class"] = true,
    ["continue"] = true,
    ["def"] = true,
    ["del"] = true,
    ["elif"] = true,
    ["else"] = true,
    ["except"] = true,
    ["False"] = true,
    ["finally"] = true,
    ["for"] = true,
    ["from"] = true,
    ["global"] = true,
    ["if"] = true,
    ["import"] = true,
    ["in"] = true,
    ["is"] = true,
    ["lambda"] = true,
    ["let"] = true,
    ["None"] = true,
    ["nonlocal"] = true,
    ["not"] = true,
    ["or"] = true,
    ["pass"] = true,
    ["raise"] = true,
    ["return"] = true,
    ["self"] = true,
    ["True"] = true,
    ["try"] = true,
    ["while"] = true,
    ["with"] = true,
    ["yield"] = true,
}

local function hover_params(client, buf, row, col, line)
    local encoding = client.offset_encoding or "utf-16"
    local character = col
    if encoding == "utf-16" then
        character = select(2, vim.str_utfindex(line, col))
    elseif encoding == "utf-32" then
        character = select(1, vim.str_utfindex(line, col))
    end
    return {
        textDocument = vim.lsp.util.make_text_document_params(buf),
        position = { line = row, character = character },
    }
end

local function line_types()
    local buf = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = buf, method = "textDocument/hover" })
    if #clients == 0 then
        vim.notify("当前缓冲区没有语言服务器", vim.log.levels.WARN)
        return
    end
    local client = clients[1]

    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""

    -- 收集本行的标识符，同一个名字只查第一次出现的位置
    local names, seen = {}, {}
    local i = 1
    while true do
        local s, e = line:find("[%a_][%w_]*", i)
        if not s then
            break
        end
        local name = line:sub(s, e)
        if not keywords[name] and not seen[name] then
            seen[name] = true
            names[#names + 1] = { name = name, col = s - 1 }
        end
        i = e + 1
    end

    if #names == 0 then
        vim.notify("本行没有可查的标识符", vim.log.levels.INFO)
        return
    end

    local found = {}
    local pending = #names
    for idx, item in ipairs(names) do
        vim.lsp.buf_request_all(
            buf,
            "textDocument/hover",
            hover_params(client, buf, row, item.col, line),
            function(res)
                for _, r in pairs(res) do
                    if r.result and r.result.contents then
                        local lines =
                            vim.lsp.util.convert_input_to_markdown_lines(r.result.contents)
                        -- 第一行通常是代码块围栏，跳过它再找正文
                        local first
                        for _, l in ipairs(lines) do
                            if l ~= "" and not l:find("^%s*```") then
                                first = l
                                break
                            end
                        end
                        -- 只要变量 / 常量 / 属性 / 参数，函数签名之类的不掺和
                        local kinds =
                            { "^%(variable%)", "^%(constant%)", "^%(property%)", "^%(parameter%)" }
                        local ok = false
                        for _, pattern in ipairs(kinds) do
                            if first and first:find(pattern) then
                                ok = true
                                break
                            end
                        end
                        if ok then
                            found[idx] = vim.trim(first)
                        end
                        break
                    end
                end

                pending = pending - 1
                if pending > 0 then
                    return
                end

                vim.schedule(function()
                    local parts = {}
                    for idx2 = 1, #names do
                        if found[idx2] then
                            parts[#parts + 1] = found[idx2]
                        end
                    end
                    if #parts == 0 then
                        vim.notify("本行没有拿到变量类型", vim.log.levels.INFO)
                    else
                        vim.notify(table.concat(parts, "\n"))
                    end
                end)
            end
        )
    end
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

            map("n", "<leader>it", line_types, opts("查看本行变量类型"))

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
