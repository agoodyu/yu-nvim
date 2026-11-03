-- ============================================================================
-- 自动命令
-- 全局行为调整，按触发事件分组
-- ============================================================================

-- ===== 复制同步到系统剪贴板 =====
-- clipboard 选项留空，所以每次 yank 手动写一次 + 寄存器
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		local e = vim.v.event
		if e.operator ~= "y" or e.regname == "_" then
			return -- 不是 yank，或者写进了黑洞寄存器，直接跳过
		end
		if vim.fn.has("clipboard") == 0 then
			return -- 编译时没带 clipboard 支持，跳过
		end
		-- pcall 兜底：目标机没有 wl-copy / xclip 时不报错
		pcall(vim.fn.setreg, "+", vim.fn.getreg('"'), vim.fn.getregtype('"'))
	end,
	desc = "复制同步到系统剪贴板",
})

-- ===== 延迟加载 shada =====
-- 启动时 shadafile = "NONE" 提速，第一次进命令行时才读回来
vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdwinEnter" }, {
	once = true, -- 只执行一次
	callback = function()
		local shada = vim.fs.joinpath(vim.fn.stdpath("state"), "shada/main.shada")
		vim.o.shadafile = shada
		vim.cmd("rshada! " .. shada) -- 把历史读进当前会话
	end,
})

-- ===== 终端窗口 =====
-- 终端里不需要行号，隐藏掉
vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		vim.wo.number = false
		vim.wo.relativenumber = false
	end,
})

-- ===== 命令行窗口 (q:) =====
-- 打开后直接进插入模式，顺便隐藏行号
vim.api.nvim_create_autocmd("CmdwinEnter", {
	callback = function()
		vim.cmd("startinsert")
		vim.wo.number = false
		vim.wo.relativenumber = false
	end,
})

-- ===== 新窗口不折行 =====
-- options.lua 里的 wrap=false 只作用于启动时的窗口，新开的要单独设
vim.api.nvim_create_autocmd("WinNew", {
	callback = function()
		vim.wo.wrap = false
	end,
})
