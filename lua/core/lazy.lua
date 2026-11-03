-- ============================================================================
-- lazy.nvim 引导
-- 负责首次下载 lazy.nvim 并初始化插件系统
-- ============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" -- lazy.nvim 的安装位置

-- 首次启动时自动克隆
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local repo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none", -- 只拉最新提交，不下载全部历史
        "--branch=stable",
        repo,
        lazypath,
    })

    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "无法克隆 lazy.nvim：\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\n按任意键退出..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath) -- 把 lazy.nvim 加进 runtimepath

-- ===== 插件加载 =====
-- import 不会递归子目录，每个分类都要单独声明
require("lazy").setup({
    spec = {
        { import = "plugins.ui" },     -- 界面：主题、状态栏、标签栏、命令行
        { import = "plugins.editor" }, -- 编辑：文件树、跳转、配对、包围
        { import = "plugins.lsp" },    -- LSP：服务器、补全、格式化、语法、调试
        { import = "plugins.lang" },   -- 语言：Rust、Cargo
        { import = "plugins.tools" },  -- 工具：翻译
    },
    checker = { enabled = false }, -- 关闭自动检查更新，避免启动后 fork git 造成 IO 抖动
})
