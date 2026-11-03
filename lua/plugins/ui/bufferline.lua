-- ============================================================================
-- 顶部 buffer 标签栏
-- 每个打开的缓冲区一个标签，支持鼠标点击切换
-- ============================================================================
return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = { "nvim-tree/nvim-web-devicons" }, -- 文件类型图标
	event = "VeryLazy",
	keys = {
		{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "下一个缓冲区" },
		{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "上一个缓冲区" },
		{ "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "按字母选择缓冲区" },
		{ "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "关闭其他缓冲区" },
		{ "<leader>bw", "<cmd>bdelete<cr>", desc = "关闭当前缓冲区" },
	},
	opts = {
		options = {
			mode = "buffers", -- 缓冲模式，不是标签页模式
			numbers = "none", -- 不显示编号
			indicator = { style = "icon", icon = "▎" }, -- 当前缓冲区的左侧指示条
			buffer_close_icon = "", -- 单个缓冲区的关闭图标（隐藏）
			modified_icon = "●", -- 有未保存修改时的标记
			close_icon = "", -- 整体关闭图标（隐藏）
			left_trunc_marker = "", -- 左侧截断提示
			right_trunc_marker = "", -- 右侧截断提示
			max_name_length = 18, -- 文件名最多显示 18 字符
			max_prefix_length = 15, -- 路径前缀最多显示 15 字符
			tab_size = 18, -- 每个标签的最小宽度
			diagnostics = "nvim_lsp", -- 诊断来源：LSP
			-- 诊断图标：只显示有内容的严重级别
			diagnostics_indicator = function(_, _, diag)
				local ret = {}
				if diag.error and diag.error > 0 then
					ret[#ret + 1] = "%#DiagnosticError#"
						.. vim.fn.nr2char(0xf057)
						.. " "
						.. diag.error
						.. "%*"
				end
				if diag.warning and diag.warning > 0 then
					ret[#ret + 1] = "%#DiagnosticWarn#"
						.. vim.fn.nr2char(0xf071)
						.. " "
						.. diag.warning
						.. "%*"
				end
				return table.concat(ret, " ")
			end,
			show_buffer_icons = true, -- 显示文件类型图标
			show_buffer_close_icons = true, -- 显示每个标签的关闭按钮
			show_close_icon = false, -- 右上角不显示总关闭按钮
			separator_style = "slant", -- 斜切分隔符，和 lualine 的 powerline 统一
			always_show_bufferline = true, -- 只有一个缓冲区时也显示
			sort_by = "insert_at_end", -- 新打开的排在最后，不按路径重排
			-- 文件树打开时，标签栏从树右边开始，不盖住树的顶部
			offsets = {
				{
					filetype = "neo-tree",
					text = "File Explorer",
					text_align = "left",
					separator = true,
				},
			},
		},
	},
}
