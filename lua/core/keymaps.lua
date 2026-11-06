-- ============================================================================
-- 通用键位
-- 插件自己的按键写在各插件文件里，这里只放全局生效的
-- ============================================================================

local map = vim.keymap.set

-- ===== leader 键 =====
vim.g.mapleader = " " -- 空格作为主 leader
vim.g.maplocalleader = "," -- 逗号作为局部 leader

-- ===== 插入模式 =====
map("i", "jj", "<Esc>", { silent = true, desc = "退出插入模式" })

-- ===== 普通模式杂项 =====
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { silent = true, desc = "清除搜索高亮" })
map("n", "Y", "y$", { silent = true, desc = "复制到行尾" })
map("n", "<leader>q", "<cmd>q<cr>", { silent = true, desc = "退出当前窗口" })
-- 键位总览：列出空格开头的所有键
-- 三个坑叠在一起，缺一个就"闪一下什么都没发生"：
--   1. 要等这一拍按键处理完（vim.schedule），同步调用会被触发链收尾时关掉
--   2. 要先把按空格时开着的菜单关掉（state.stop），两套状态叠着会互相顶
--   3. 插件还没初始化（VeryLazy 之前）时 show() 会静默失败，先拉起来再试
local function which_key_overview(tries)
    local ok, cfg = pcall(require, "which-key.config")
    if ok and cfg.loaded then
        pcall(function()
            require("which-key.state").stop()
        end)
        pcall(function()
            require("which-key").show({ keys = "<leader>", mode = "n" })
        end)
        return
    end
    if tries > 0 then
        pcall(vim.cmd, "Lazy load which-key")
        vim.defer_fn(function()
            which_key_overview(tries - 1)
        end, 200)
        return
    end
    pcall(vim.cmd, "WhichKey")
end

map("n", "<leader>?", function()
    vim.schedule(function()
        which_key_overview(3)
    end)
end, { silent = true, desc = "键位总览（空格开头的键）" })

-- ===== 折叠 =====
-- 原生 za / zR / zM 加空格前缀，避免和 z 开头的其他命令混淆
map("n", "<leader>za", "za", { silent = true, desc = "折叠/展开当前块" })
map("n", "<leader>zr", "zR", { silent = true, desc = "展开全部" })
map("n", "<leader>zm", "zM", { silent = true, desc = "折叠全部" })

-- ===== 窗口间移动 =====
-- 方向与 niri / tmux 一致：Ctrl + h/j/k/l
map("n", "<C-h>", "<C-w>h", { silent = true, desc = "切换到左侧窗口" })
map("n", "<C-j>", "<C-w>j", { silent = true, desc = "切换到下方窗口" })
map("n", "<C-k>", "<C-w>k", { silent = true, desc = "切换到上方窗口" })
map("n", "<C-l>", "<C-w>l", { silent = true, desc = "切换到右侧窗口" })

-- ===== 分屏 =====
-- v = vertical 左右分，s = split 上下分
map("n", "<leader>wv", "<C-w>v", { silent = true, desc = "垂直分屏（左右）" })
map("n", "<leader>ws", "<C-w>s", { silent = true, desc = "水平分屏（上下）" })
map("n", "<leader>wc", "<C-w>c", { silent = true, desc = "关闭当前分屏" })
map("n", "<leader>wo", "<C-w>o", { silent = true, desc = "只保留当前分屏" })

-- ===== 分屏尺寸 =====
-- 用 Ctrl + 方向键调整宽高，比 :resize 快
map("n", "<C-Left>", "<C-w><", { silent = true, desc = "减小宽度" })
map("n", "<C-Right>", "<C-w>>", { silent = true, desc = "增加宽度" })
map("n", "<C-Up>", "<C-w>+", { silent = true, desc = "增加高度" })
map("n", "<C-Down>", "<C-w>-", { silent = true, desc = "减小高度" })

-- ===== 行移动 =====
-- Alt + j/k 上下移动当前行，可视模式下移动整段选区并保持选中
-- 用 :move 而不是 dd/p，剪切板和缩进都不会被破坏（:move 的地址是"移动到该行之后"）
local function move_line(delta)
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    if (delta > 0 and lnum == vim.api.nvim_buf_line_count(0)) or (delta < 0 and lnum == 1) then
        return
    end
    vim.cmd(delta > 0 and "move .+1" or "move .-2")
end

map("n", "<A-j>", function()
    move_line(1)
end, { silent = true, desc = "当前行下移" })
map("n", "<A-k>", function()
    move_line(-1)
end, { silent = true, desc = "当前行上移" })
-- 可视模式用 :move 的选区地址，gv 重新选中，便于连续按
map("x", "<A-j>", ":move '>+1<CR>gv", { silent = true, desc = "选区下移" })
map("x", "<A-k>", ":move '<-2<CR>gv", { silent = true, desc = "选区上移" })
