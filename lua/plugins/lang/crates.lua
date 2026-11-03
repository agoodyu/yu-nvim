-- ============================================================================
-- Cargo.toml 增强
-- 依赖版本提示、跳转 crates.io 文档、补全 crate 名
-- ============================================================================
return {
	"saecki/crates.nvim",
	event = { "BufRead Cargo.toml" }, -- 只在打开 Cargo.toml 时加载
	tag = "stable", -- 用稳定版，unstable 分支 API 会变
	opts = {
		lsp = {
			enabled = true, -- 启用内置的文件类型服务
			actions = true, -- 提供升级/降级等操作
			completion = true, -- 补全 crate 名
			hover = true, -- 悬浮显示 crate 信息
		},
	},
}
