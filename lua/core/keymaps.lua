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
