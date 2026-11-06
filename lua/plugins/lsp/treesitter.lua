-- ============================================================================
-- 语法高亮 / 折叠 / 缩进
-- Neovim 0.12 自带高亮引擎，本插件只负责下载并编译 parser
-- ============================================================================

-- 需要安装的 parser 列表
local parsers = {
    "rust",
    "c",
    "cpp",
    "python", -- 主要语言
    "html",
    "css",
    "javascript", -- 前端
    "lua",
    "luadoc", -- 写 nvim 配置用
    "comment",
    "toml",
    "json",
    "yaml", -- 配置和注释
    "bash",
    "markdown",
    "markdown_inline", -- 文档和脚本
    "regex", -- noice 高亮搜索正则用
}

-- 这些文件类型额外启用 treesitter 缩进
local indent_ft = { rust = true, c = true, cpp = true }

-- 这些文件类型启用 treesitter 折叠（默认全展开，按 za 才折叠当前块）
local fold_ft = { rust = true, c = true, cpp = true, lua = true, python = true }

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- 0.12 专用的重写分支
    lazy = false, -- 插件本身不支持懒加载
    build = ":TSUpdate", -- 更新插件时同步更新 parser
    config = function()
        -- 安装动作推迟到启动之后，不占启动时间
        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            once = true,
            callback = function()
                require("nvim-treesitter").install(parsers)
            end,
        })

        -- 每个文件类型都尝试启用 treesitter
        vim.api.nvim_create_autocmd("FileType", {
            callback = function(ev)
                -- core/autocmds.lua 已经判定是超大文件 / 超长行：不挂语法高亮
                if vim.b[ev.buf].bigfile then
                    return
                end

                -- 没有对应 parser 就直接走普通高亮
                if not pcall(vim.treesitter.start, ev.buf) then
                    return
                end

                -- 折叠策略
                if fold_ft[ev.match] then
                    vim.wo.foldmethod = "expr"
                    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    vim.wo.foldlevel = 99 -- 默认全部展开
                else
                    vim.wo.foldmethod = "manual" -- 其他文件类型不折叠
                end

                -- 缩进策略
                if indent_ft[ev.match] then
                    vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,
}
