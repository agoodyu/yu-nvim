-- ============================================================================
-- HTML / JSX 标签自动闭合
-- 输入 </ 或者修改开始标签名时，自动同步结束标签
-- ============================================================================
return {
	"windwp/nvim-ts-autotag",
	ft = {
		"html",
		"xml",
		"javascript",
		"typescript",
		"javascriptreact",
		"typescriptreact",
		"vue",
		"svelte",
	},
	opts = {},
}
