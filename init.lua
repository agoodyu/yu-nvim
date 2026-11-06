-- ===== 启动优化：跳过用不到的内置插件 =====
-- 每个内置 plugin/ 脚本都要 sourcing，虽然只 0.03–0.12ms，但没必要跑
-- 保留的：matchit（% 跳转）、matchparen（括号高亮）、netrw（打开目录）、
--         shada（配合手动的 rshada）、man、editorconfig、net、osc52
for _, p in ipairs({
    "gzip", -- :e xxx.gz
    "remote_plugins", -- rplugin.vim，只给远程插件用
    "tarPlugin",
    "zipPlugin",
    "spellfile_plugin",
    "tutor_mode_plugin",
}) do
    vim.g["loaded_" .. p] = 1
end

-- 核心模块的加载顺序
require("core.init") -- 基础设置：行号、缩进、搜索、剪贴板
