-- ============================================================================
-- 外部依赖自检
-- 启动完成后（VeryLazy）异步检查，缺失时提示一次
-- 不阻塞启动：VeryLazy 在启动结束后才触发
-- ============================================================================

vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	once = true,
	callback = function()
		vim.schedule(function()
			local missing = {}

			-- 逐个检查依赖表里声明的可执行文件
			for _, d in ipairs(require("deps")) do
				if vim.fn.executable(d.bin) == 0 then
					table.insert(missing, d.bin)
				end
			end

			-- 有缺失就提示一次，指向 :checkhealth deps
			if #missing > 0 then
				vim.notify(
					("缺少外部依赖：%s\n运行 :checkhealth deps 查看安装方法"):format(
						table.concat(missing, ", ")
					),
					vim.log.levels.WARN
				)
			end
		end)
	end,
})
