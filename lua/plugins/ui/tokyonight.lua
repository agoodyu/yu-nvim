-- ============================================================================
-- 配色主题
-- tokyonight 的 moon 变体，透明背景
-- ============================================================================
return {
	"folke/tokyonight.nvim",
	opts = {
		style = "moon", -- 变体：night / storm / moon / day
		transparent = true, -- 背景透明，透出终端底色和壁纸
	},
	config = function(_, opts)
		require("tokyonight").setup(opts)
		vim.cmd.colorscheme("tokyonight") -- 立即应用
	end,
}
