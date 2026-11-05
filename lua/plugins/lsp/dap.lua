-- ============================================================================
-- 调试
-- Rust / C / C++ 使用 codelldb，rustaceanvim 会自动检测到适配器
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
        require("dap-python").setup("uv")

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
    },
}
