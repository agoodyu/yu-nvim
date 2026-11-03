-- ============================================================================
-- 底部状态栏
-- 用 VeryLazy 加载，不进启动路径
-- sections 里每一段都是整体替换，写的时候必须写全，否则默认组件会丢
-- ============================================================================
-- 代码类型：图标 + 语言全名
-- lualine 自带的 filetype 组件只显示 filetype 缩写（py、rs），中文环境下不好认
local ft_names = {
    bash = "Bash",
    c = "C",
    cpp = "C++",
    css = "CSS",
    html = "HTML",
    javascript = "JavaScript",
    javascriptreact = "JSX",
    json = "JSON",
    lua = "Lua",
    markdown = "Markdown",
    python = "Python",
    rust = "Rust",
    sh = "Shell",
    toml = "TOML",
    typescript = "TypeScript",
    typescriptreact = "TSX",
    vim = "Vim",
    yaml = "YAML",
    zsh = "Zsh",
}

local function filetype()
    local ft = vim.bo.filetype
    if ft == "" then
        return ""
    end

    local icon = ""
    local ok, devicons = pcall(require, "nvim-web-devicons")
    if ok then
        local i = devicons.get_icon(
            vim.api.nvim_buf_get_name(0),
            vim.fn.expand("%:e"),
            { default = true }
        )
        icon = i and (i .. " ") or ""
    end

    return icon .. (ft_names[ft] or ft)
end

return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons", -- 文件类型图标
    },
    event = "VeryLazy",
    opts = {
        options = {
            theme = "tokyonight", -- 跟随主题，自动带透明变体
            globalstatus = true, -- 配合 laststatus=3，全屏只渲染一条
            component_separators = { left = "", right = "" }, -- 组件间分隔符
            section_separators = { left = "", right = "" }, -- 分段间的三角分隔符
        },
        extensions = { "neo-tree" }, -- 文件树里隐藏重复信息
        sections = {
            lualine_a = { "mode" }, -- 当前模式
            lualine_b = { "branch", "diff", "diagnostics" }, -- git 分支、改动行数、错误数
            lualine_c = { "filename" }, -- 文件名
            lualine_x = { "fileformat", "encoding", filetype }, -- 换行符、编码、代码类型（图标 + 全名）
            lualine_y = { "progress" }, -- 文件滚动百分比
            lualine_z = { "location" }, -- 光标行列
        },
    },
}
