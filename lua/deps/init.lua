-- ============================================================================
-- 外部依赖：清单 + 启动后自检
-- 清单给 :checkhealth deps 用；setup() 负责启动完成后提示缺失项
-- ============================================================================

local M = {}

-- 依赖清单：bin 是要用的可执行文件，pkg 是对应的包名
M.list = {
    { bin = "lua-language-server", pkg = "lua-language-server" },
    { bin = "clangd", pkg = "clang" },
    { bin = "clang-format", pkg = "clang" },
    { bin = "basedpyright-langserver", pkg = "basedpyright-bin (AUR)" },
    { bin = "marksman", pkg = "marksman" },
    { bin = "ruff", pkg = "ruff" },
    { bin = "uv", pkg = "uv" },
    { bin = "stylua", pkg = "stylua" },
    { bin = "prettier", pkg = "prettier" },
    { bin = "vscode-html-language-server", pkg = "vscode-langservers-extracted (AUR)" },
    { bin = "vscode-css-language-server", pkg = "vscode-langservers-extracted (AUR)" },
    { bin = "rust-analyzer", pkg = "rustup component add rust-analyzer" },
    { bin = "rustfmt", pkg = "rustup component add rustfmt" },
    { bin = "tree-sitter", pkg = "tree-sitter-cli" },
    { bin = "node", pkg = "nodejs" },
    { bin = "codelldb", pkg = "codelldb-bin (AUR)" },
}

-- 启动完成后（VeryLazy）异步检查，缺失时提示一次
-- 不阻塞启动：VeryLazy 在启动结束后才触发
function M.setup()
    vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        once = true,
        callback = function()
            vim.schedule(function()
                local missing = {}

                -- 逐个检查清单里声明的可执行文件
                for _, d in ipairs(M.list) do
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
end

return M
