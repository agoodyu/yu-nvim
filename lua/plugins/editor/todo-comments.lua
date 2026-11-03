-- ============================================================================
-- TODO 高亮
-- 把 TODO / FIXME / HACK / NOTE / WARN 等标记高亮，并支持汇总成列表
-- ============================================================================
return {
	"folke/todo-comments.nvim",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		signs = true, -- 左侧符号列也显示
		highlight = {
			multiline = true, -- 注释里的多行 TODO 也高亮
		},
	},
	keys = {
		{ "<leader>xt", "<cmd>TodoQuickFix<cr>", desc = "TODO 列表" },
	},
}
