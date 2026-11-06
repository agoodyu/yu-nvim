-- ============================================================================
-- 编辑器选项
-- 只放 vim.opt / vim.g 设置，不涉及插件
-- ============================================================================

local opt = vim.opt
local g = vim.g

-- ===== 界面语言 =====
-- 目标机没有中文 locale 时静默失败，不会中断后面的加载
-- 用闭包包一层：vim.cmd 是带 __call 的 table，直接传给 pcall 类型上不匹配
pcall(function()
    vim.cmd("language zh_CN.UTF-8")
end)

-- ===== 按键超时 =====
-- 组合键等待时间（毫秒），jj、<leader>zz 这类序列映射靠它判断输入是否结束
opt.timeoutlen = 200

-- ===== 数字格式 =====
-- 让 <C-a> / <C-x> 能识别二进制、十六进制和字母
opt.nrformats = "bin,hex,alpha"

-- ===== 文件编码 =====
-- nvim 内部固定 UTF-8（'encoding' 已不可写），只需要管写入文件时的编码
opt.fileencoding = "utf-8"

-- ===== 外部修改 =====
-- 'autoread' 在 nvim 里默认就是开的，不用设

-- ===== 备份与交换文件 =====
opt.backup = false -- 不生成 ~ 结尾的备份文件
opt.writebackup = false -- 覆盖写入前不额外备份
opt.swapfile = false -- 不生成 .swp，避免崩溃后残留

-- ===== 持久化撤销 =====
opt.undofile = true -- 撤销历史写入磁盘
opt.undodir = vim.fn.stdpath("state") .. "/undo" -- 撤销历史存放目录
vim.fn.mkdir(vim.fn.stdpath("state") .. "/undo", "p") -- 目录不存在就创建

-- ===== 剪贴板 =====
-- 留空表示不自动接管系统剪贴板，粘贴走终端自己的快捷键
-- 复制同步由 core/autocmds.lua 的 TextYankPost 处理
opt.clipboard = ""

-- ===== 启动速度 =====
opt.shadafile = "NONE" -- 启动时不读 shada，等第一次进命令行再手动加载

-- ===== 滚动留白 =====
-- 光标始终保持在当前窗口正中
-- 按窗口实际尺寸算，分屏后重新计算，不会占掉半个屏幕
local function center_cursor()
    vim.o.scrolloff = math.floor((vim.fn.winheight(0) - 1) / 2)
    vim.o.sidescrolloff = math.floor((vim.fn.winwidth(0) - 1) / 2)
end

center_cursor()

vim.api.nvim_create_autocmd({ "WinResized", "WinEnter", "VimResized" }, {
    callback = center_cursor,
})

-- ===== 分屏保持视口 =====
-- 开关分屏时屏幕内容不跳动
opt.splitkeep = "screen"

-- ===== 命令行区域 =====
opt.cmdheight = 1 -- 0 = 底部不留空行，命令行交给 noice 浮窗
opt.cmdwinheight = 1 -- q: 打开的命令行窗口高度

-- ===== 分屏方向 =====
opt.splitbelow = true -- 水平分屏时新窗口在下
opt.splitright = true -- 垂直分屏时新窗口在右

-- ===== 行号与光标 =====
opt.number = true -- 显示绝对行号
opt.relativenumber = true -- 显示相对行号，5j / 12k 跳起来更直观
opt.cursorline = true -- 高亮光标所在行
opt.signcolumn = "yes" -- 始终保留符号列，避免 LSP 图标出现时文字左右横跳

-- ===== 缩进 =====
opt.expandtab = true -- Tab 一律转成空格
opt.tabstop = 4 -- 一个 Tab 显示为 4 列
opt.shiftwidth = 0 -- 0 = 缩进宽度自动跟随 tabstop
opt.shiftround = true -- << / >> 缩进对齐到 shiftwidth 的整数倍

-- ===== 光标移动 =====
opt.whichwrap = "<,>,[,]" -- 允许 h/l 在行首行尾跨越到相邻行

-- ===== 换行 =====
vim.wo.wrap = false -- 长行不折行，超出屏幕部分横向滚动

-- ===== 搜索 =====
opt.ignorecase = true -- 搜索默认忽略大小写
opt.smartcase = true -- 输入里有大写字母时自动区分大小写
opt.shortmess = vim.o.shortmess .. "s" -- 搜索命中时不再提示 "search hit BOTTOM"
opt.inccommand = "split" -- :s/old/new/ 时在分屏里实时预览替换效果

-- ===== 响应速度 =====
opt.updatetime = 250 -- CursorHold / 诊断 / 状态栏刷新，默认 1000ms 太迟钝

-- ===== 安全 =====
opt.confirm = true -- :q 有未保存修改时弹确认框，而不是直接报错

-- ===== 块选择 =====
opt.virtualedit = "block" -- 块选择时光标可以移动到行尾之外

-- ===== 鼠标 =====
opt.mouse = "a" -- 所有模式都启用鼠标
opt.mousemodel = "extend" -- 按住拖动时扩展选区而不是重新选择

-- ===== 外观 =====
opt.winborder = "rounded" -- 所有内置浮窗使用圆角边框
opt.termguicolors = true -- 开启 24 位真彩色
opt.pumheight = 16 -- 补全弹窗最多显示 16 个候选
opt.laststatus = 3 -- 全局共用一个状态栏，不随分屏复制
opt.showmode = false -- 隐藏自带的 "-- INSERT --"，交给 lualine 显示
