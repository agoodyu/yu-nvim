-- ============================================================================
-- 底部状态栏
-- 用 VeryLazy 加载，不进启动路径
-- sections 里每一段都是整体替换，写的时候必须写全，否则默认组件会丢
-- ============================================================================
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
			lualine_x = { "fileformat", "encoding", "filetype" }, -- 换行符、编码、文件类型
			lualine_y = { "progress" }, -- 文件滚动百分比
			lualine_z = { "location" }, -- 光标行列
		},
	},
}
