-- ============================================================================
-- 核心模块加载顺序
-- 顺序有依赖：选项和键位必须先于 lazy，lazy 必须在插件之前
-- ============================================================================

require("core.options") -- 编辑器选项：行号、缩进、搜索、剪贴板
require("core.autocmds") -- 自动命令：yank 同步、shada、终端
require("core.keymaps") -- 通用键位：leader、折叠、窗口切换
require("core.lsp") -- LSP 诊断外观、hover 浮窗、通用键位
require("core.terminal") -- 底部终端开关
require("core.deps") -- 外部依赖自检（VeryLazy 后执行）
require("core.lazy") -- lazy.nvim 初始化，必须在最后
