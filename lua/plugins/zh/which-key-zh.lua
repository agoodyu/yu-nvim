-- ============================================================
-- which-key 面板的中文词表
--
-- 原理：which-key 显示的“文字”来自每条映射的 desc / 分组名 group。
--       只写 desc/group、不写执行动作(rhs)，就只改文字，真实快捷键一点都不变；
--       删掉本文件立刻恢复英文。
--
-- 内容：nvim 自带键的中文说法（306 条），按普通 / 可视 / 操作符 / 插入 / 命令行分表。
--       自己配置的键（空格开头的，以及 ui/which-key.lua 里定了分组的那几个）一律跳过，
--       它们的文字由各自的 desc 决定，词表不插手。
--
-- 改词：直接改下面的中文。_g 结尾的表是分组名，其余是具体快捷键。
-- ============================================================

local M = {}

-- ===== 模式 n：具体快捷键 =====
M.cn = {
    ['"'] = "寄存器",
    ["$"] = "行尾",
    ["'"] = "标记",
    ["/"] = "向前搜索",
    ["0"] = "行首",
    ["<C-f>"] = "下翻页",
    ["<Esc>"] = "取消",
    ["<c-w>+"] = "增加高度",
    ["<c-w>-"] = "减少高度",
    ["<c-w><"] = "减少宽度",
    ["<c-w>="] = "等高等宽",
    ["<c-w>>"] = "增加宽度",
    ["<c-w>H"] = "移至最左侧",
    ["<c-w>J"] = "移至最底部",
    ["<c-w>K"] = "移至最顶部",
    ["<c-w>L"] = "移至最右侧",
    ["<c-w>T"] = "拆分到新标签页",
    ["<c-w>_"] = "最大高度",
    ["<c-w>h"] = "移至左侧窗口",
    ["<c-w>j"] = "移至下方窗口",
    ["<c-w>k"] = "移至上方窗口",
    ["<c-w>l"] = "移至右侧窗口",
    ["<c-w>o"] = "关闭其他窗口",
    ["<c-w>q"] = "关闭窗口",
    ["<c-w>s"] = "水平分割",
    ["<c-w>v"] = "垂直分割",
    ["<c-w>w"] = "切换窗口",
    ["<c-w>x"] = "与下一个交换",
    ["<c-w>|"] = "最大宽度",
    ["?"] = "向后搜索",
    ["B"] = "上一个 WORD",
    ["E"] = "下一个 WORD 末尾",
    ["G"] = "最后一行",
    ["H"] = "窗口首行 (顶部)",
    ["L"] = "窗口末行 (底部)",
    ["M"] = "窗口中间行",
    ["N"] = "上一个搜索结果",
    ["S"] = "删除行并插入",
    ["V"] = "可视行模式",
    ["W"] = "下一个 WORD",
    ["Y"] = "复制至行尾",
    ["[%"] = "上一个未匹配组",
    ["[("] = "上一个 (",
    ["[M"] = "上一个方法末尾",
    ["[m"] = "上一个方法开始",
    ["[s"] = "上一个拼写错误",
    ["[{"] = "上一个 {",
    ["]M"] = "下一个方法末尾",
    ["]m"] = "下一个方法开始",
    ["]s"] = "下一个拼写错误",
    ["^"] = "行首 (非空白)",
    ["`"] = "标记位置",
    ["b"] = "上一个单词",
    ["c"] = "修改",
    ["d"] = "删除",
    ["e"] = "下一个单词末尾",
    ["g%"] = "向后循环遍历结果",
    ["g'"] = "标记",
    ["g,"] = "跳转到较新的位置",
    ["g;"] = "跳转到较旧的位置",
    ["gT"] = "上一个标签页",
    ["gU"] = "转为大写",
    ["g`"] = "标记位置",
    ["gf"] = "跳转到光标下的文件",
    ["gg"] = "首行",
    ["gi"] = "跳转到上次插入位置",
    ["gt"] = "下一个标签页",
    ["gu"] = "转为小写",
    ["gv"] = "上次可视选区",
    ["gw"] = "格式化",
    ["g~"] = "切换大小写",
    ["h"] = "向左",
    ["j"] = "向下",
    ["k"] = "向上",
    ["l"] = "向右",
    ["n"] = "下一个搜索结果",
    ["s"] = "删除并插入",
    ["v"] = "可视模式",
    ["w"] = "下一个单词",
    ["y"] = "复制",
    ["z<CR>"] = "当前行置顶",
    ["z="] = "拼写建议",
    ["zA"] = "切换所有折叠",
    ["zC"] = "关闭所有折叠",
    ["zD"] = "删除所有折叠",
    ["zE"] = "删除所有折叠",
    ["zH"] = "向左半屏",
    ["zL"] = "向右半屏",
    ["zM"] = "关闭所有折叠",
    ["zO"] = "打开所有折叠",
    ["zR"] = "打开所有折叠",
    ["za"] = "切换折叠",
    ["zb"] = "当前行置底",
    ["zc"] = "关闭折叠",
    ["zd"] = "删除折叠",
    ["ze"] = "当前行居右",
    ["zf"] = "创建折叠",
    ["zg"] = "添加拼写单词",
    ["zi"] = "切换折叠",
    ["zm"] = "更多折叠",
    ["zo"] = "打开折叠",
    ["zr"] = "更少折叠",
    ["zs"] = "当前行居左",
    ["zt"] = "当前行置顶",
    ["zv"] = "显示光标行",
    ["zx"] = "更新折叠",
    ["zz"] = "当前行居中",
    ["{"] = "上一个空行",
    ["}"] = "下一个空行",
    ["~"] = "切换大小写",
    ['"+'] = "与系统剪贴板同步",
    ["[B"] = "缓冲区前移",
    ["[D"] = "跳到本缓冲区第一个诊断",
    ["[Q"] = "快速修复：最早",
    ["[T"] = "第一个标签页",
    ["[b"] = "上一个缓冲区",
    ["[d"] = "上一个诊断",
    ["[e"] = "上一个错误",
    ["[q"] = "上一个诊断/快速修复项",
    ["[t"] = "上一个 TODO",
    ["[w"] = "上一个警告",
    ["]%"] = "下一个未匹配组",
    ["]B"] = "缓冲区后移",
    ["]D"] = "跳到本缓冲区最后一个诊断",
    ["]Q"] = "快速修复：最后一个",
    ["]T"] = "最后一个标签页",
    ["]b"] = "下一个缓冲区",
    ["]d"] = "下一个诊断",
    ["]e"] = "下一个错误",
    ["]q"] = "下一个诊断/快速修复项",
    ["]t"] = "下一个 TODO",
    ["]w"] = "下一个警告",
    ['`"'] = "上次退出的缓冲区",
    ["gO"] = "文档符号",
    ['g`"'] = "上次退出的缓冲区",
    ["gcO"] = "上方添加注释",
    ["gcc"] = "切换行注释",
    ["gco"] = "下方添加注释",
    ["gra"] = "代码操作",
    ["gri"] = "跳转实现",
    ["grn"] = "重命名",
    ["grr"] = "查找引用",
    ["grt"] = "跳转类型定义",
    ['"%'] = "当前文件名",
    ["K"] = "悬停文档",
    ["gD"] = "跳转声明",
    ["gI"] = "跳转实现",
    ["gy"] = "跳转类型定义",
    ['"%'] = "当前文件名",
    ['"+'] = "系统剪贴板",
    ["[C"] = "上一个类结束",
    ["[["] = "上一个引用",
    ["[c"] = "上一个类开始",
    ["]C"] = "下一个类结束",
    ["]]"] = "下一个引用",
    ["]c"] = "下一个类开始",
    ['`"'] = "上次退出此缓冲区的位置",
    ['g`"'] = "上次退出此缓冲区的位置",
    ["gd"] = "跳转定义",
}

-- ===== 模式 n：分组名 =====
M.cn_g = {
    ["%"] = "匹配 (){}[]",
}

-- ===== 模式 v：具体快捷键 =====
M.cn_v = {
    ['"'] = "寄存器",
    ["$"] = "行尾",
    ["%"] = "匹配 (){}[]",
    [","] = "上一个 f/t/F/T",
    ["0"] = "行首",
    [";"] = "下一个 f/t/F/T",
    ["<c-w>h"] = "移至左侧窗口",
    ["<c-w>j"] = "移至下方窗口",
    ["<c-w>k"] = "移至上方窗口",
    ["<c-w>l"] = "移至右侧窗口",
    ["B"] = "上一个 WORD",
    ["E"] = "下一个 WORD 末尾",
    ["F"] = "移动到前一个字符",
    ["T"] = "移动到前一个字符前",
    ["V"] = "可视行模式",
    ["W"] = "下一个 WORD",
    ["^"] = "行首 (非空白)",
    ['a"'] = '" 字符串',
    ["a'"] = "' 字符串",
    ["a("] = "[(]) 块",
    ["a)"] = "[(]) 块",
    ["aB"] = "[{}] 块",
    ["aW"] = "带空格的 WORD",
    ["ab"] = "[(]) 块",
    ["as"] = "句子",
    ["at"] = "标签块",
    ["aw"] = "带空格的单词",
    ["a{"] = "[{}] 块",
    ["a}"] = "[{}] 块",
    ["b"] = "上一个单词",
    ["c"] = "修改",
    ["d"] = "删除",
    ["e"] = "下一个单词末尾",
    ["f"] = "移动到下一个字符",
    ["gU"] = "转为大写",
    ["gc"] = "注释选中",
    ["gu"] = "转为小写",
    ["g~"] = "切换大小写",
    ["h"] = "向左",
    ['i"'] = '内部 " 字符串',
    ["i("] = "内部 [(])",
    ["i)"] = "内部 [(])",
    ["iB"] = "内部 [{}]",
    ["iW"] = "内部 WORD",
    ["ib"] = "内部 [(])",
    ["it"] = "内部标签块",
    ["iw"] = "内部单词",
    ["i{"] = "内部 [{}]",
    ["i}"] = "内部 [{}]",
    ["j"] = "向下",
    ["k"] = "向上",
    ["l"] = "向右",
    ["p"] = "替换选中",
    ["r"] = "替换字符",
    ["s"] = "删除并插入",
    ["t"] = "移动到下一个字符前",
    ["v"] = "可视模式",
    ["w"] = "下一个单词",
    ["y"] = "复制",
    ["zf"] = "创建折叠",
    ["~"] = "切换大小写",
    ['"+'] = "与系统剪贴板同步",
    ["#"] = "反向搜索光标下单词",
    ["*"] = "搜索光标下单词",
    ["<c-space>"] = "Treesitter 增量选择",
    ["<c-w>H"] = "窗口移到最左",
    ["<c-w>J"] = "窗口移到最下",
    ["<c-w>K"] = "窗口移到最上",
    ["<c-w>L"] = "窗口移到最右",
    ["<esc>"] = "退出并清除搜索高亮",
    ["<s-tab>"] = "片段跳转，否则 <S-Tab>",
    ["<tab>"] = "片段跳转，否则 <Tab>",
    ["Q"] = "可视块（虚拟）",
    ["R"] = "Treesitter 搜索",
    ["S"] = "Flash 跳转（Treesitter）",
    ['al"'] = '" 字符串',
    ['an"'] = '" 字符串',
    ['il"'] = '" 字符串',
    ['in"'] = '" 字符串',
    ['"%'] = "当前文件名",
    ['"%'] = "当前文件名",
    ['"+'] = "系统剪贴板",
}

-- ===== 模式 v：分组名 =====
M.cn_v_g = {
    ["a"] = "环绕",
    ["i"] = "内部",
}

-- ===== 模式 o：具体快捷键 =====
M.cn_o = {
    ["$"] = "行尾",
    ["%"] = "匹配 (){}[]",
    [","] = "上一个 f/t/F/T",
    ["/"] = "向前搜索",
    ["0"] = "行首",
    [";"] = "下一个 f/t/F/T",
    ["?"] = "向后搜索",
    ["B"] = "上一个 WORD",
    ["E"] = "下一个 WORD 末尾",
    ["F"] = "移动到前一个字符",
    ["G"] = "最后一行",
    ["T"] = "移动到前一个字符前",
    ["W"] = "下一个 WORD",
    ["^"] = "行首 (非空白)",
    ['a"'] = '" 字符串',
    ["b"] = "上一个单词",
    ["e"] = "下一个单词末尾",
    ["f"] = "移动到下一个字符",
    ["gg"] = "首行",
    ["h"] = "向左",
    ['i"'] = '内部 " 字符串',
    ["iB"] = "内部 [{}]",
    ["iW"] = "内部 WORD",
    ["ib"] = "内部 [(])",
    ["ip"] = "内部段落",
    ["is"] = "内部句子",
    ["it"] = "内部标签块",
    ["iw"] = "内部单词",
    ["j"] = "向下",
    ["k"] = "向上",
    ["l"] = "向右",
    ["t"] = "移动到下一个字符前",
    ["w"] = "下一个单词",
    ["{"] = "上一个空行",
    ["}"] = "下一个空行",
    ["<c-space>"] = "Treesitter 增量选择",
    ["N"] = "上一个搜索结果",
    ["R"] = "Treesitter 搜索",
    ["S"] = "Flash 跳转（Treesitter）",
    ['al"'] = '" 字符串',
    ['an"'] = '" 字符串',
    ["g["] = "向左移动（环绕）",
    ["gc"] = "注释文本对象",
    ['il"'] = '" 字符串',
    ['in"'] = '" 字符串',
    ["n"] = "下一个搜索结果",
    ["r"] = "远程 Flash",
    ["s"] = "Flash 跳转",
    ["ih"] = "选择代码块",
}

-- ===== 模式 o：分组名 =====
M.cn_o_g = {
    ["a"] = "环绕",
    ["i"] = "内部",
}

-- ===== 模式 i：具体快捷键 =====
M.cn_i = {
    ['"'] = "寄存器",
    ["<c-r>"] = "粘贴寄存器内容",
    ["'"] = "关闭/打开 \"''\" 配对",
    ["("] = '打开 "()" 配对',
    [")"] = '关闭 "()" 配对',
    ["<bs>"] = "自动配对 <BS>",
    ["<c-b>"] = "向上滚动",
    ["<c-f>"] = "向下滚动",
    ["<c-r>+"] = "与系统剪贴板同步",
    ["<c-s>"] = "保存文件",
    ["<c-u>"] = "删除到行首（插入）",
    ["<c-w>"] = "删除前一个单词（插入）",
    ["<cr>"] = "自动配对 <CR>",
    ["<esc>"] = "退出并清除搜索高亮",
    ["<m-j>"] = "下移",
    ["<m-k>"] = "上移",
    ["<s-tab>"] = "片段跳转，否则 <S-Tab>",
    ["<tab>"] = "片段跳转，否则 <Tab>",
    ["["] = '打开 "[]" 配对',
    ["`"] = '关闭/打开 "``" 配对',
    ["pp"] = "连按 pp 退出插入模式",
    ["{"] = '打开 "{}" 配对',
    ["}"] = '关闭 "{}" 配对',
    ["<c-r>%"] = "当前文件名",
    ["<c-k>"] = "签名帮助",
}

-- ===== 模式 i：分组名 =====
M.cn_i_g = {}

-- ===== 模式 c：具体快捷键 =====
M.cn_c = {
    ['"'] = "寄存器",
    ["<c-r>"] = "粘贴寄存器内容",
    ["'"] = "关闭/打开 \"''\" 配对",
    ["("] = '打开 "()" 配对',
    [")"] = '关闭 "()" 配对',
    ["<bs>"] = "自动配对 <BS>",
    ["<c-r>+"] = "与系统剪贴板同步",
    ["<c-s>"] = "切换 Flash 搜索",
    ["<s-cr>"] = "重定向命令行",
    ["["] = '打开 "[]" 配对',
    ["`"] = '关闭/打开 "``" 配对',
    ["{"] = '打开 "{}" 配对',
    ["}"] = '关闭 "{}" 配对',
    ["<c-r>%"] = "当前文件名",
}

-- ===== 模式 c：分组名 =====
M.cn_c_g = {}

-- ============ 以下是把中文压进 which-key ============

local TABLES = {
    { M.cn, "n", false },
    { M.cn_g, "n", true },
    { M.cn_v, "v", false },
    { M.cn_v_g, "v", true },
    { M.cn_v, "x", false },
    { M.cn_v_g, "x", true },
    { M.cn_o, "o", false },
    { M.cn_o_g, "o", true },
    { M.cn_i, "i", false },
    { M.cn_i_g, "i", true },
    { M.cn_c, "c", false },
    { M.cn_c_g, "c", true },
}

-- ============ 抓图标 ============
-- 改中文之前调用：让 which-key 按现在的（英文）描述把图标算出来，存起来
local icon_cache = {} -- "模式|键" -> 图标表 / false(确认没有图标)
local exists = {} -- "模式|键" -> 该键在菜单里是否存在

local function get_mode(mode)
    local ok, Buf = pcall(require, "which-key.buf")
    if not ok then
        return nil
    end
    local okm, m = pcall(Buf.get, { mode = mode, buf = 0 })
    if okm and m and m.tree then
        return m
    end
end

local function capture()
    local ok, Util = pcall(require, "which-key.util")
    local ok2, View = pcall(require, "which-key.view")
    if not (ok and ok2) then
        return 0
    end
    local found = 0
    for _, job in ipairs(TABLES) do
        local mode = job[2]
        local m = get_mode(mode)
        if m then
            for lhs in pairs(job[1]) do
                local id = mode .. "|" .. lhs
                if not exists[id] then
                    local okf, node = pcall(m.tree.find, m.tree, Util.keys(lhs, { norm = true }))
                    if okf and node then
                        exists[id] = true
                        found = found + 1
                        if icon_cache[id] == nil then
                            local oki, ic, hl = pcall(View.icon, node)
                            icon_cache[id] = (oki and ic) and { icon = ic, hl = hl } or false
                        end
                    end
                else
                    found = found + 1
                end
            end
        end
    end
    return found
end

-- ============ 压中文 ============
-- 只让它补 nvim 自带键和插件留下的英文描述，我们自己定了的键一律不覆盖：
--   · 空格开头的键，配置里每条都写了中文 desc
--   · which-key spec 里声明过分组的键（g / gr / gc / z / [ / ] / <c-w> 和空格分组）
-- 键名统一转小写再比：spec 里写的是 <C-w>，词表里写的是 <c-w>，是同一个键
local owned = {}
do
    local ok, spec = pcall(require, "plugins.ui.which-key")
    if ok and spec.opts and spec.opts.spec then
        for _, e in ipairs(spec.opts.spec) do
            owned[(e[1]):lower()] = true
        end
    end
end

local function ours(lhs, mode)
    if vim.startswith(lhs, "<leader>") or vim.startswith(lhs, "<localleader>") then
        return true
    end
    -- owned 里的键在 ui/which-key.lua 里定了分组名，n / x / o 三个模式都算
    return owned[lhs:lower()] == true
end

local function apply()
    if not pcall(require, "which-key") then
        return false
    end
    if capture() == 0 then
        return false -- which-key 还没就绪，等会儿再来
    end
    for _, job in ipairs(TABLES) do
        local tbl, mode, is_group = job[1], job[2], job[3]
        local regs = {}
        for lhs, val in pairs(tbl) do
            local id = mode .. "|" .. lhs
            if exists[id] and not ours(lhs, mode) then -- 只改真实存在且不是我们自己的键
                local text = type(val) == "table" and val[1] or val
                local e = { lhs, mode = mode }
                if is_group then
                    e.group = text
                else
                    e.desc = text
                end
                local ic = icon_cache[id]
                if ic then
                    e.icon = ic -- 抓到的图标
                end
                regs[#regs + 1] = e
            end
        end
        if #regs > 0 then
            require("which-key").add(regs)
        end
    end
    return true
end

-- 还没就绪就等 100ms 再试，最多 20 次
local function apply_when_ready(tries)
    local ok, ret = pcall(apply)
    if (not ok or not ret) and tries < 20 then
        vim.defer_fn(function()
            apply_when_ready(tries + 1)
        end, 100)
    end
end

return {
    "folke/which-key.nvim",
    init = function()
        local group = vim.api.nvim_create_augroup("lazyvim_zh_keymaps", { clear = true })
        local last = 0
        -- 补压：which-key 加载完、有插件被加载、打开/切换文件、空闲下来时，都再压一遍，
        -- 这样“用时才注册”的键（gitsigns 等）也会被翻到；1 秒内最多压一次，避免频繁跑
        local function touch()
            local now = vim.uv.now()
            if now - last < 1000 then
                return
            end
            last = now
            vim.schedule(function()
                apply_when_ready(0)
            end)
        end

        vim.api.nvim_create_autocmd("User", {
            pattern = { "VeryLazy", "LazyLoad", "LazyFile" },
            group = group,
            callback = touch,
        })
        for _, ev in ipairs({ "BufReadPost", "BufEnter", "WinEnter", "CursorHold" }) do
            vim.api.nvim_create_autocmd(ev, {
                group = group,
                callback = function()
                    touch()
                    vim.defer_fn(function()
                        apply_when_ready(0)
                    end, 600)
                end,
            })
        end
    end,
}
