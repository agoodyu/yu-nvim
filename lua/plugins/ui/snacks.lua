-- ============================================================================
-- 图片显示
-- 只启用 image 模块，其余模块全部关闭，避免和现有插件冲突
-- 依赖 magick（ImageMagick）和终端支持 Kitty graphics protocol
-- ============================================================================
return {
	"folke/snacks.nvim",
	event = "VeryLazy",
	opts = {
		image = { enabled = true }, -- 在 buffer 内直接渲染图片

		-- ===== 以下模块全部关闭 =====
		bigfile = { enabled = false },
		bufdelete = { enabled = false },
		dashboard = { enabled = false },
		debug = { enabled = false },
		dim = { enabled = false },
		explorer = { enabled = false },
		git = { enabled = false },
		gitbrowse = { enabled = false },
		indent = { enabled = false }, -- 缩进线已用 indent-blankline
		input = { enabled = false },
		layout = { enabled = false },
		lazygit = { enabled = false },
		notifier = { enabled = false }, -- 通知交给原生，避免和 noice 打架
		notify = { enabled = false },
		picker = { enabled = false },
		profiler = { enabled = false },
		quickfile = { enabled = false },
		rename = { enabled = false },
		scope = { enabled = false },
		scratch = { enabled = false },
		scroll = { enabled = false }, -- 滚动效果已用 scrolleof
		statuscolumn = { enabled = false },
		terminal = { enabled = false }, -- 终端已用 core/terminal.lua
		toggle = { enabled = false },
		win = { enabled = false },
		words = { enabled = false },
		zen = { enabled = false },
	},
}
