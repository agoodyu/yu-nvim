-- ============================================================================
-- 左侧文件树
-- h/l 沿用 yazi 习惯：h 退一级，l 未展开则展开、已展开则设为新根
-- ============================================================================
return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim", -- 异步文件操作
		"MunifTanjim/nui.nvim", -- UI 组件
		"nvim-tree/nvim-web-devicons", -- 文件类型图标
	},
	cmd = "Neotree", -- 用命令触发加载，不进启动路径
	keys = {
		{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "文件树开关" },
		{ "<leader>E", "<cmd>Neotree reveal<cr>", desc = "在树中定位当前文件" },
	},
	opts = {
		filesystem = {
			follow_current_file = { enabled = true }, -- 切换 buffer 时自动展开定位
			filtered_items = { hide_dotfiles = false }, -- 显示 .config 这类点文件
		},
		window = {
			width = 32, -- 侧边栏宽度
			mappings = {
				-- o 和 Enter 一样打开；nowait 避免去等 oc/od 这些排序子键
				["o"] = { "open", nowait = true },

				-- yazi 风格
				["h"] = "navigate_up", -- 回上一级
				["l"] = function(state)
					local node = state.tree:get_node()
					if not node or node.type ~= "directory" then
						return -- 文件上按 l 不做事
					end

					local cmds = require("neo-tree.sources.filesystem.commands")
					if node:is_expanded() then
						cmds.set_root(state) -- 已展开：设为新根
					else
						cmds.toggle_node(state) -- 未展开：展开
					end
				end,
				["L"] = "focus_preview", -- 原来的 l（聚焦预览窗口）

				-- 排序菜单从 o 挪到 O（o 被打开操作占了）
				["O"] = {
					"show_help",
					nowait = false,
					config = { title = "Order by", prefix_key = "O" },
				},
				["Oc"] = "order_by_created", -- 按创建时间
				["Od"] = "order_by_diagnostics", -- 按诊断数量
				["Og"] = "order_by_git_status", -- 按 git 状态
				["Om"] = "order_by_modified", -- 按修改时间
				["On"] = "order_by_name", -- 按名称
				["Os"] = "order_by_size", -- 按大小
				["Ot"] = "order_by_type", -- 按类型
			},
		},
	},
	config = function(_, opts)
		require("neo-tree").setup(opts)

		-- 删掉 o 前缀的排序子键（oc/od/og/om/on/os/ot）
		-- 只要它们存在，按 o 就必须等 timeoutlen 才能确定要按哪个，表现就是"有延迟"
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "neo-tree",
			callback = function(ev)
				vim.schedule(function()
					for _, key in ipairs({ "oc", "od", "og", "om", "on", "os", "ot" }) do
						pcall(vim.api.nvim_buf_del_keymap, ev.buf, "n", key)
					end
				end)
			end,
		})

		-- 和 tokyonight 的 transparent 一致：只去掉底色，保留前景色
		local function set_transparent()
			for _, name in ipairs({ "NeoTreeNormal", "NeoTreeNormalNC" }) do
				local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
				-- 只回填前景色，背景不设即为透明
				-- （get_hl 返回的是只读的 keyset.get，不能整个传给 set_hl）
				vim.api.nvim_set_hl(0, name, { fg = hl.fg, bg = "none" })
			end
		end

		set_transparent()
		vim.api.nvim_create_autocmd("ColorScheme", { callback = set_transparent })
	end,
}
