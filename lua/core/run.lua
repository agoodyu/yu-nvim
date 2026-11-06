-- ============================================================================
-- 运行当前文件
-- 各语言的运行键位都注册在这里：<leader>rr 运行，Rust 另有 <leader>rt / <leader>rd
-- 存盘 / 校验 / 交给底部终端这些公共逻辑也在这个文件里
-- 真正语言专属的键（Rust 的悬停菜单、展开宏等）留在 after/ftplugin/rust.lua
-- ============================================================================

local M = {}

-- build(file) 返回要执行的 shell 命令
function M.file(build)
    local buf = vim.api.nvim_get_current_buf()
    local file = vim.api.nvim_buf_get_name(buf)
    if file == "" then
        vim.notify("先保存文件再运行", vim.log.levels.WARN)
        return
    end

    if vim.bo[buf].modified then
        vim.cmd("silent write") -- 跑之前先存盘，否则跑的是旧代码
    end

    require("core.terminal").run(build(file))
end

-- 解释型语言：直接跑文件
local runners = {
    lua = {
        desc = "运行当前文件（lua）",
        build = function(file)
            return ("lua %s"):format(vim.fn.shellescape(file))
        end,
    },
    python = {
        desc = "运行当前文件（python）",
        build = function(file)
            -- uv 会自动用项目里的 pyproject / 虚拟环境
            return ("uv run python %s"):format(vim.fn.shellescape(file))
        end,
    },
}

-- 跑测试：Python 用 pytest（走 uv，测试依赖在项目虚拟环境里）
-- --with pytest 是关键：项目没把 pytest 写成依赖时，uv 会报
-- "Failed to spawn: pytest"，加上它就临时把 pytest 装进这次运行的环境
-- 和 dap-python 用 uv run --with debugpy 是同一个思路
-- 两个入口：t 跑当前文件，p 跑整个项目（当前文件里没有测试函数时用得上）
-- Rust 的测试是 rustaceanvim 的 testables，走 code lens，不在这里
local testers = {
    python = {
        file = {
            desc = "运行当前文件的测试（pytest）",
            build = function(file)
                return ("uv run --with pytest pytest %s"):format(vim.fn.shellescape(file))
            end,
        },
        project = {
            desc = "运行整个项目的测试（pytest）",
            build = function()
                return "uv run --with pytest pytest"
            end,
        },
    },
}

-- C / C++：clang / clang++ 编译到 /tmp 再直接运行，不往源码目录丢产物
-- 两种文件类型只差一个编译器名字，所以不再各写一份 ftplugin
function M.clang()
    local cc = vim.bo.filetype == "cpp" and "clang++" or "clang"
    M.file(function(file)
        local out = "/tmp/nvim-run-" .. vim.fn.fnamemodify(file, ":t:r")
        return ("%s -g -O0 -o %s %s && %s"):format(
            cc,
            vim.fn.shellescape(out),
            vim.fn.shellescape(file),
            vim.fn.shellescape(out)
        )
    end)
end

-- Rust：交给 rustaceanvim 的 code lens
local function rust_action(args)
    return function()
        vim.cmd.RustLsp(args)
    end
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp", "lua", "python", "rust" },
    callback = function(ev)
        local ft = ev.match
        local map = vim.keymap.set

        if ft == "c" or ft == "cpp" then
            local cc = ft == "cpp" and "clang++" or "clang"
            map("n", "<leader>rr", M.clang, {
                buffer = ev.buf,
                silent = true,
                desc = "编译并运行（" .. cc .. "）",
            })
        elseif runners[ft] then
            local runner = runners[ft]
            map("n", "<leader>rr", function()
                M.file(runner.build)
            end, { buffer = ev.buf, silent = true, desc = runner.desc })
            -- 有测试器的语言再挂 空格 r t（当前文件）和 空格 r p（整个项目）
            local tester = testers[ft]
            if tester then
                map("n", "<leader>rt", function()
                    M.file(tester.file.build)
                end, { buffer = ev.buf, silent = true, desc = tester.file.desc })
                map("n", "<leader>rp", function()
                    M.file(tester.project.build)
                end, { buffer = ev.buf, silent = true, desc = tester.project.desc })
            end
        elseif ft == "rust" then
            map(
                "n",
                "<leader>rr",
                rust_action("runnables"),
                { buffer = ev.buf, silent = true, desc = "运行目标" }
            )
            map(
                "n",
                "<leader>rt",
                rust_action("testables"),
                { buffer = ev.buf, silent = true, desc = "运行测试" }
            )
            map(
                "n",
                "<leader>rd",
                rust_action("debuggables"),
                { buffer = ev.buf, silent = true, desc = "调试目标" }
            )
        end
    end,
    desc = "各语言的运行键位",
})

return M
