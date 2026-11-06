-- ============================================================================
-- 核心模块加载顺序
-- 顺序有依赖：选项和键位必须先于 lazy，lazy 必须在插件之前
-- ============================================================================

require("core.options") -- 编辑器选项：行号、缩进、搜索、剪贴板
require("core.autocmds") -- 自动命令：yank 同步、shada、终端、新窗口
require("core.bigfile") -- 大文件 / 超长行降级
require("core.keymaps") -- 通用键位：leader、折叠、窗口切换；必须早于下面两个（它们用 <leader>）
require("core.comment") -- 注释键位：gcc / gcO / gco / gcI / gcA、空格 /
require("core.lsp") -- 诊断外观与浮窗、LspAttach 键位（内部 require hover / linetypes）
require("core.terminal") -- 底部终端开关
require("core.run") -- 各语言的运行键位（空格 r r / r t / r d）
require("deps").setup() -- 外部依赖清单 + 启动后自检
require("core.lazy") -- lazy.nvim 初始化，必须在最后
