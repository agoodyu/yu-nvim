-- ============================================================================
-- 调试
-- Rust 走 rustaceanvim 自带的 rt_lldb 适配器（检测到 codelldb 就用 codelldb）
-- Python 走 dap-python（uv 拉起 debugpy），C / C++ 这里补一个 codelldb 适配器
-- 打开文件时才加载，不占启动时间
-- ============================================================================
return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui", -- 调试面板（变量、调用栈、断点）
        "nvim-neotest/nvim-nio", -- dap-ui 的异步依赖
        "mfussenegger/nvim-dap-python", -- Python 适配器（debugpy）
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        dapui.setup()

        -- Python：适配器用 "uv" 启动（uv run --with debugpy，不用往项目里装 debugpy）
        -- 被调试进程的解释器由 dap-python 自己找：VIRTUAL_ENV → 项目 .venv
        local dap_python = require("dap-python")
        dap_python.setup("uv")
        -- 测试器固定用 pytest（默认是探测 pytest.ini / manage.py / pyproject.toml，猜不中）
        dap_python.test_runner = "pytest"

        -- C / C++：codelldb 自带调试器，直接当适配器用
        dap.adapters.codelldb = {
            type = "server",
            port = "${port}",
            executable = {
                command = "codelldb",
                args = { "--port", "${port}" },
                detached = { vim.fn.has("win32") == 1 and "CreateProcess" or "spawn" },
            },
        }

        -- program 给编译好的可执行文件或源码都行；工作目录用文件所在目录，不依赖 LSP 的 workspace
        for _, ft in ipairs({ "c", "cpp" }) do
            dap.configurations[ft] = {
                {
                    type = "codelldb",
                    request = "launch",
                    name = "codelldb",
                    program = "${file}",
                    cwd = "${fileDirname}",
                    stopOnEntry = false,
                    args = {},
                },
            }
        end

        -- 启动/附加时自动打开面板，结束/退出时自动关闭
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
    end,
    keys = {
        -- ===== 空格 d 分组：调试 =====
        {
            "<leader>df",
            function()
                require("dap").continue()
            end,
            desc = "调试: 开始/继续",
        },
        {
            "<leader>ds",
            function()
                require("dap").step_over()
            end,
            desc = "调试: 单步跳过",
        },
        {
            "<leader>dn",
            function()
                require("dap").step_into()
            end,
            desc = "调试: 单步进入",
        },
        {
            "<leader>do",
            function()
                require("dap").step_out()
            end,
            desc = "调试: 单步跳出",
        },
        {
            "<leader>db",
            function()
                require("dap").toggle_breakpoint()
            end,
            desc = "调试: 断点",
        },
        {
            "<leader>du",
            function()
                require("dapui").toggle()
            end,
            desc = "调试: 界面",
        },

        -- ===== 功能键：同一套动作的快捷方式 =====
        {
            "<F5>",
            function()
                require("dap").continue()
            end,
            desc = "调试: 开始/继续",
        },
        {
            "<F10>",
            function()
                require("dap").step_over()
            end,
            desc = "调试: 单步跳过",
        },
        {
            "<F11>",
            function()
                require("dap").step_into()
            end,
            desc = "调试: 单步进入",
        },
        {
            "<F12>",
            function()
                require("dap").step_out()
            end,
            desc = "调试: 单步跳出",
        },
    },
}
