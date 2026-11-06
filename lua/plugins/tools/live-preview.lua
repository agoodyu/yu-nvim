-- ============================================================================
-- 浏览器实时预览
-- 支持 Markdown / HTML / CSS / SVG
-- 后端纯 Lua 实现，不需要 node、python 或任何构建步骤
--
-- 默认行为是"边打字边刷新"，这里改成"保存才刷新"：
-- 启动后删掉插件注册的 TextChanged / TextChangedI 自动命令，
-- 再用 BufWritePost 手动推送一次更新。
-- 注意：依赖 livepreview 的内部 API（server.connecting_clients / websocket），
-- 插件大版本升级后可能要跟着调整。
-- ============================================================================

-- 把当前 buffer 的内容通过 WebSocket 推给浏览器
local function push_update()
    local ok, server = pcall(require, "livepreview.server")
    if not ok or not server.connecting_clients then
        return
    end

    local websocket = require("livepreview.server.websocket")
    local message = {
        filepath = vim.api.nvim_buf_get_name(0),
        type = "update",
        content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"),
    }

    for _, client in ipairs(server.connecting_clients) do
        pcall(websocket.send_json, client, message)
    end
end

return {
    "brianhuster/live-preview.nvim",
    ft = { "markdown", "html", "css", "svg" }, -- 打开这些类型才加载
    keys = {
        {
            "<leader>mp",
            function()
                vim.cmd("LivePreview start")
                -- 启动后清掉"打字即刷新"的自动命令
                vim.schedule(function()
                    pcall(vim.api.nvim_clear_autocmds, {
                        group = "LivePreview",
                        event = { "TextChanged", "TextChangedI" },
                    })
                end)
            end,
            desc = "浏览器预览",
        },
        { "<leader>mP", "<cmd>LivePreview stop<cr>", desc = "关闭浏览器预览" },
    },
    config = function()
        require("livepreview.config").set({
            -- 固定用内置 vim.ui.select：以后若再加会接管 vim.ui.select 的
            -- picker 类插件，LSP 的选择菜单（含代码操作）不会被换成别家样式，
            -- 那种列表常常只显示 provider 名字，看不出条目内容
            picker = "vim.ui.select",
        })

        -- 保存文件时才推送更新
        vim.api.nvim_create_autocmd("BufWritePost", {
            callback = function()
                local ok, server = pcall(require, "livepreview.server")
                if ok and server.connecting_clients and #server.connecting_clients > 0 then
                    push_update()
                end
            end,
            desc = "保存后更新浏览器预览",
        })
    end,
}
