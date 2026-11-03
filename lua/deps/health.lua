-- :checkhealth deps
local deps = require("deps")

local M = {}

function M.check()
	vim.health.start("nvim 外部依赖")

	local missing = 0
	for _, d in ipairs(deps) do
		if vim.fn.executable(d.bin) == 1 then
			vim.health.ok(("%s  →  %s"):format(d.bin, d.pkg))
		else
			vim.health.error(("%s 未找到，安装：%s"):format(d.bin, d.pkg))
			missing = missing + 1
		end
	end

	if missing == 0 then
		vim.health.info("全部就绪")
	else
		vim.health.warn(
			("缺 %d 项，可运行 ~/.config/nvim/scripts/bootstrap.fish"):format(missing)
		)
	end
end

return M
