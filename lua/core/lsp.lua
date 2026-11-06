-- ============================================================================
-- LSP 通用配置
-- 诊断外观、诊断浮窗、接入缓冲区后的键位
-- hover 浮窗见 core/hover.lua，本行变量类型见 core/linetypes.lua
-- 具体语言服务器的启用在 lua/plugins/lsp/lspconfig.lua
-- ============================================================================

local hover = require("core.hover")
local line_types = require("core.linetypes")

local map = vim.keymap.set

-- ===== 诊断外观 =====
-- 整段推迟到 VeryLazy 再配：碰一下 vim.diagnostic 就要 require 它，实测 1.0ms，
-- 而启动阶段根本不会有诊断到达（LSP 比 VeryLazy 晚得多），所以观感没区别
local function setup_diagnostics()
    -- 等级下限统一卡在 WARN：HINT 级里塞的是 rustc 的 note（"overwritten here before ..."
    -- 这类），一条 clippy 警告会被拆成两条显示。W/E 不受影响，完整内容仍能在浮窗里看。
    local warn_up = { min = vim.diagnostic.severity.WARN }

    -- 行尾文字压成一行再截断：rustc 的备注常常很长，wrap=false 之后会一直拖到屏幕外
    local function one_line(d)
        local msg = d.message:gsub("%s*\n%s*", " ")
        if vim.fn.strchars(msg) > 100 then
            msg = vim.fn.strcharpart(msg, 0, 100) .. "…"
        end
        return msg
    end

    vim.diagnostic.config({
        -- 行尾虚拟文字，圆点开头，离代码 4 格
        virtual_text = { spacing = 4, prefix = "●", severity = warn_up, format = one_line },
        signs = { severity = warn_up }, -- 左侧符号列显示图标
        underline = { severity = warn_up }, -- 出错位置加下划线
        severity_sort = true, -- 同一行多个诊断时按严重程度排序
        update_in_insert = true, -- 插入模式下也刷新诊断
        -- <leader>dd 浮窗：圆角，显示来源，不加等级过滤（note 想看还是能看）
        float = { border = "rounded", source = true },
        -- ]d / [d 跳过 hint，并在跳过去之后弹浮窗
        -- float = true 已标记废弃（0.14 移除），官方给的替代就是 on_jump
        jump = {
            severity = warn_up,
            on_jump = function(d)
                if d then
                    vim.diagnostic.open_float({ scope = "cursor" })
                end
            end,
        },
    })
end

vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = setup_diagnostics,
    desc = "诊断外观（推迟加载 vim.diagnostic）",
})

-- 类型提示的全局开关，LspAttach 和新开的缓冲区都读它
vim.g.inlay_hints = true

local map = vim.keymap.set
-- ===== 诊断浮窗 =====
-- 默认浮窗只看得见、进不去，长诊断没法滚动。这里自己开窗后把焦点切进去，
-- q / Esc 关窗并回到原来的窗口；不这么做的话光标一直在代码上，浮窗只读
-- 注意 focusable 只在这一处传：]d / [d 的 on_jump 浮窗保持不抢焦点
local function diagnostics_float()
    local origin = vim.api.nvim_get_current_win()
    local fb, win = vim.diagnostic.open_float({ focusable = true, focus = false })
    if not win then
        return -- 这一行没有诊断，不开空窗
    end

    local function close()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_win_is_valid(origin) then
            vim.api.nvim_set_current_win(origin)
        end
    end

    -- q 覆盖 open_floating_preview 自带的 bdelete 映射，顺手把焦点还回去
    local opts = { buffer = fb, silent = true, nowait = true }
    map("n", "q", close, opts)
    map("n", "<Esc>", close, opts)

    vim.api.nvim_set_current_win(win)
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
        map("n", "<leader>dd", diagnostics_float, opts("查看诊断（可进入滚动）"))
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
