-- ============================================================================
-- 注释键位
-- 内置只给了 gcc / gc / gb，缺「上方 / 下方新起一行」和「行首 / 行尾」，这里补齐
-- 注释符一律从 commentstring 现算，每种语言用自己的符号
-- ============================================================================

local map = vim.keymap.set

-- ===== 注释 =====
-- 内置只给了 gcc / gc / gb，缺"上方、下方新起一行注释"和"行首、行尾"，这里补齐
-- 键位沿用上游 0.11 的命名（gcO / gco / gcA / gcI），以后升级也不会打架
-- 注释符一律从 'commentstring' 现算，每种语言用的都是自己的符号

-- commentstring 形如 "// %s"、"-- %s"、"/* %s */"：拆成前后两段
-- 左边统一补一个空格，右边（只有块注释才有）也补空格，拼出来正好是 "/* " 和 " */"
local function markers()
    local left, right = vim.bo.commentstring:match("^(.-)%%s(.*)$")
    if not left then
        return "-- ", "" -- 没有 commentstring 的缓冲区兜底
    end
    right = vim.trim(right)
    return vim.trim(left) .. " ", right ~= "" and (" " .. right) or ""
end

-- 上方 / 下方新起一行注释，光标停在注释符后面
local function new_comment_line(above)
    local left, right = markers()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local at = above and row - 1 or row -- 0 起始的插入位置
    vim.api.nvim_buf_set_lines(0, at, at, false, { left .. right })
    vim.api.nvim_win_set_cursor(0, { at + 1, #left })
    vim.cmd("startinsert")
end

-- 行尾补注释：块注释时把光标停在前后两个符号中间
local function comment_at_end()
    local left, right = markers()
    local line = vim.api.nvim_get_current_line():gsub("%s+$", "")
    local text = (line ~= "" and line .. " " or "") .. left .. right
    vim.api.nvim_set_current_line(text)
    vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], #text - #right })
    vim.cmd("startinsert")
end

-- 行首补注释：跳过缩进插入，缩进不动，注释符不会顶到最左边
local function comment_at_start()
    local left, right = markers()
    local line = vim.api.nvim_get_current_line()
    local indent = line:match("^%s*")
    local text = indent .. left .. line:sub(#indent + 1) .. right
    vim.api.nvim_set_current_line(text)
    vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], #indent + #left })
    vim.cmd("startinsert")
end

map("n", "gco", function()
    new_comment_line(false)
end, { silent = true, desc = "下方新起一行注释" })
map("n", "gcO", function()
    new_comment_line(true)
end, { silent = true, desc = "上方新起一行注释" })
map("n", "gcA", comment_at_end, { silent = true, desc = "行尾插入注释" })
map("n", "gcI", comment_at_start, { silent = true, desc = "行首插入注释" })

-- 快速开关：普通模式整行，可视模式选区，直接借内置的 gcc / gc
map("n", "<leader>/", "gcc", { remap = true, silent = true, desc = "注释/取消注释当前行" })
map("x", "<leader>/", "gc", { remap = true, silent = true, desc = "注释/取消注释选区" })
