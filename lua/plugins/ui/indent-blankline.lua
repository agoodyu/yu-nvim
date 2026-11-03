-- ============================================================================
-- 缩进参考线
-- 按 treesitter 语法块绘制竖线，当前作用域用亮色高亮
-- ============================================================================
return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufReadPost", "BufNewFile" }, -- 打开文件时才加载
	main = "ibl", -- 模块名和仓库名不同，必须指定
	opts = {
		indent = { char = "│" }, -- 缩进线字符
		scope = {
			enabled = true, -- 高亮光标所在的作用域
			show_start = false, -- 不画作用域顶部横线
			show_end = false, -- 不画作用域底部横线
		},
		exclude = {
			filetypes = { "help", "alpha", "dashboard", "lazy", "mason", "neo-tree" },
		},
	},
}
