-- ============================================================================
-- suda.nvim：在普通用户身份的 nvim 里，用 sudo 读写受保护的文件
-- 编辑、语法、LSP、格式化全部是你的实例，只有读/写那一下走 sudo
--
-- 为什么不用 sudo nvim / sudo -e nvim：
--   sudo nvim  → nvim 以 root 运行，读 /root 的配置，插件也用 root 身份跑
--   sudoedit   → 只接受单个文件，且会拷到 /var/tmp 临时名，没有语法和 LSP
--
-- 三种情况分流：
--   1. 可读但不可写（/etc 下绝大多数）→ 打开时把缓冲区接管为 acwrite，
--      :w / :wq / :q 选"保存" 时弹密码、sudo tee 写回。
--      缓冲名仍是真实路径，LSP、语法、格式化照常工作
--   2. 存在但读不到（0600 的 root 文件）→ 切 suda:// 缓冲区
--   3. 不存在且父目录不可写 → 切 suda://，保存时写入
-- ============================================================================

local function is_suda(buf)
    return vim.api.nvim_buf_get_name(buf):match("^suda://") ~= nil
end

-- 该路径当前是否可写（文件已有则看文件本身，新建则看父目录）
local function writable(path)
    if vim.fn.filereadable(path) == 1 then
        return vim.uv.fs_access(path, "W") == true
    end
    local parent = vim.fn.fnamemodify(path, ":h")
    return vim.uv.fs_access(parent, "W") == true
end

-- 把"可读但不可写"的缓冲区接管掉：写操作改走 sudo
-- 只把 buftype 改成 acwrite 是不够的：:w 在触发 BufWriteCmd 之前会先做一次
-- 文件权限检查，不可写就直接 E505 拦下，根本轮不到自动命令。
-- 所以把缓冲区名换成 suda://<真实路径>：这个名字在磁盘上不存在，权限检查自然通过，
-- 写入交给插件注册的 BufWriteCmd 处理。这里不走 :edit，不会触发插件的 sudo 读取，
-- 所以打开文件仍然不需要密码，只有真正保存时才弹。
local function hijack(buf)
    local path = vim.api.nvim_buf_get_name(buf)
    local ft = vim.bo[buf].filetype

    if not pcall(vim.api.nvim_buf_set_name, buf, "suda://" .. path) then
        return
    end

    vim.bo[buf].buftype = "acwrite"
    vim.bo[buf].swapfile = false
    vim.bo[buf].undofile = false -- suda:// 名字写不出 undo 文件
    vim.bo[buf].readonly = false
    vim.b[buf].suda_managed = true
    vim.b[buf].suda_realpath = path
    -- 改名后文件类型可能被重新识别成空，用改名前的值补回来
    if ft ~= "" then
        vim.bo[buf].filetype = ft
    end
end

return {
    "gnsfujiwara/suda.nvim",
    lazy = false, -- BufReadPre 之前就必须注册好，晚于打开文件就等于没开
    priority = 900,

    opts = {
        smart_edit = false, -- 由下面的 autocmd 接管，避免只读浏览时也弹密码
        prompt = "sudo 密码：",
        noninteractive = false, -- sudo 配了免密的话可以打开，省掉每次输入
    },

    keys = {
        { "<leader>uW", "<cmd>SudaWrite<cr>", desc = "以 sudo 写入" },
        { "<leader>uR", "<cmd>SudaRead<cr>", desc = "以 sudo 重新打开" },
    },

    config = function(_, opts)
        require("suda").setup(opts)

        local group = vim.api.nvim_create_augroup("UserSuda", { clear = true })

        -- ===== 打不开的文件：只有真的进不去时才切 suda:// =====
        vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
            group = group,
            desc = "读不到的文件自动用 sudo 打开",
            callback = function(ev)
                if ev.file == "" or ev.file:match("^suda://") then
                    return
                end

                local path = vim.fn.fnamemodify(ev.file, ":p")
                local ftype = vim.fn.getftype(path)
                local needs_sudo = false

                if ftype == "file" then
                    -- 存在但读不到（如 0600 的 root 文件）：只能提权才看得见内容
                    needs_sudo = vim.uv.fs_access(path, "R") ~= true
                elseif ftype == "" then
                    -- 不存在：父目录不可写就没法创建，切到 suda:// 才能在保存时写进去
                    needs_sudo = not writable(path)
                end

                if needs_sudo then
                    vim.schedule(function()
                        vim.api.nvim_cmd({ cmd = "edit", args = { "suda://" .. path } }, {})
                    end)
                end
            end,
        })

        -- ===== 能读不能写：接管成 acwrite，:w 时弹密码 sudo 写回 =====
        vim.api.nvim_create_autocmd("BufReadPost", {
            group = group,
            desc = "只读的系统文件接管为 sudo 写入",
            callback = function(ev)
                local buf = ev.buf
                if vim.bo[buf].buftype ~= "" or vim.b[buf].suda_managed then
                    return
                end

                local name = vim.api.nvim_buf_get_name(buf)
                -- 空名、以及 git:// 、term:// 这类特殊协议缓冲区不管
                if name == "" or name:match("^%a[%w+%.%-]*://") then
                    return
                end

                if vim.fn.filereadable(name) == 1 and vim.uv.fs_access(name, "W") ~= true then
                    hijack(buf)
                end
            end,
        })

        -- ===== suda:// 缓冲区：补齐插件没做的两件事 =====
        vim.api.nvim_create_autocmd("BufReadPost", {
            group = group,
            pattern = "suda://*",
            desc = "suda 缓冲区按真实路径识别文件类型",
            callback = function(ev)
                local buf = ev.buf
                local real = vim.b[buf].suda_realpath
                if not real or real == "" then
                    real = vim.api.nvim_buf_get_name(buf):gsub("^suda://", "")
                end

                -- 缓冲区名是 suda://… ，undo 文件按这个名写不出来，直接关掉
                vim.bo[buf].undofile = false

                -- filetype 检测默认按缓冲区名匹配，suda:///etc/hosts 这类
                -- 无扩展名的文件认不出来，这里拿真实路径重新匹配一次
                if vim.bo[buf].filetype ~= "" then
                    return
                end
                local ok, ft = pcall(vim.filetype.match, {
                    filename = real,
                    contents = vim.api.nvim_buf_get_lines(buf, 0, -1, false),
                })
                if ok and ft then
                    vim.bo[buf].filetype = ft
                end
            end,
        })

        -- LSP 客户端拿到的是 suda://… 这种 URI，服务器那边打不开这个路径，
        -- 会报一堆找不到文件的错误，索性不让它挂上去
        vim.api.nvim_create_autocmd("LspAttach", {
            group = group,
            desc = "suda 缓冲区不挂 LSP",
            callback = function(ev)
                if is_suda(ev.buf) then
                    vim.lsp.buf_detach_client(ev.buf, ev.data.client_id)
                end
            end,
        })

        -- ===== 兜底：万一有没被接管的不可写缓冲区 =====
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = group,
            desc = "不可写文件保存前提示改用 sudo",
            callback = function(ev)
                local name = vim.api.nvim_buf_get_name(ev.buf)
                if name == "" or is_suda(ev.buf) or vim.bo[ev.buf].buftype ~= "" then
                    return
                end
                if writable(name) then
                    return
                end
                vim.notify(
                    ("%s 不可写，按 <leader>uW 以 sudo 写入"):format(
                        vim.fn.fnamemodify(name, ":~")
                    ),
                    vim.log.levels.WARN
                )
            end,
        })
    end,
}
