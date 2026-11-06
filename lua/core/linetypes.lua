-- ============================================================================
-- 按需查光标所在行每个标识符的类型
-- inlay hints 由服务器决定发不发：字面量赋值它认为类型显然，就不发了；
-- 这里自己发 hover 请求，把这一行的类型拼出来
-- ============================================================================

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

return line_types
