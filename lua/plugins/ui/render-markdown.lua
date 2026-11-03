-- ============================================================================
-- Markdown 渲染
-- 在 buffer 内直接渲染标题、表格、代码块、复选框
-- 文件内容不变，只是显示层替换；光标所在行会临时恢复原文，方便编辑
-- ============================================================================
return {
	"MeanderingProgrammer/render-markdown.nvim",
	ft = "markdown",
	dependencies = {
		"nvim-treesitter/nvim-treesitter", -- 需要 markdown / markdown_inline parser
		"nvim-tree/nvim-web-devicons", -- 代码块图标
	},
	opts = {
		heading = {
			enabled = true,
			position = "overlay", -- 标题图标盖在 # 号上，不额外占位
			width = "block", -- 背景铺满整行，层级一目了然
			left_margin = 0,
			right_margin = 0,
		},
		code = {
			enabled = true,
			style = "full", -- 代码块整块加背景
			left_pad = 1,
			right_pad = 1,
		},
		bullet = { enabled = true }, -- 列表的 - 换成圆点
		checkbox = { enabled = true }, -- [ ] / [x] 换成图标
		table = { enabled = true }, -- 表格竖线对齐
		quote = { enabled = true }, -- 引用块左侧加竖线
		dash = { enabled = true }, -- --- 画成横线
		link = { enabled = true }, -- 链接显示为带下划线的文字
	},
}
