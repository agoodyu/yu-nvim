-- Rust 专用快捷键（只在 rust 缓冲区生效）
local buf = vim.api.nvim_get_current_buf()
local map = vim.keymap.set

local function rust(args, desc)
	return function()
		vim.cmd.RustLsp(args)
	end
end

-- K 已被通用 hover 占用，悬停操作菜单换到 <leader>rk
map(
	"n",
	"<leader>rk",
	rust({ "hover", "actions" }),
	{ buffer = buf, silent = true, desc = "悬停操作" }
)

map("n", "<leader>rr", rust("runnables"), { buffer = buf, silent = true, desc = "运行目标" })
map("n", "<leader>rt", rust("testables"), { buffer = buf, silent = true, desc = "运行测试" })
map("n", "<leader>rd", rust("debuggables"), { buffer = buf, silent = true, desc = "调试目标" })
map(
	"n",
	"<leader>re",
	rust("explainError"),
	{ buffer = buf, silent = true, desc = "解释错误码" }
)
map("n", "<leader>rm", rust("expandMacro"), { buffer = buf, silent = true, desc = "展开宏" })
map(
	"n",
	"<leader>rc",
	rust("openCargo"),
	{ buffer = buf, silent = true, desc = "打开 Cargo.toml" }
)
map(
	"n",
	"<leader>rp",
	rust("parentModule"),
	{ buffer = buf, silent = true, desc = "跳转父模块" }
)
map("n", "<leader>rj", rust("joinLines"), { buffer = buf, silent = true, desc = "合并行" })
