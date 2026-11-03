-- ============================================================================
-- Rust 语言支持
-- rustaceanvim 接管 rust-analyzer，不要再用 lspconfig 配 rust_analyzer
-- 插件本身是 filetype 插件，必须 lazy = false
-- ============================================================================
return {
    "mrcjkb/rustaceanvim",
    version = "^9", -- 锁大版本，避免破坏性更新
    lazy = false, -- 插件自己做懒加载，交给 lazy 反而会出问题
    init = function()
        -- 必须在插件加载前设置
        vim.g.rustaceanvim = {
            server = {
                default_settings = {
                    ["rust-analyzer"] = {
                        cargo = { allFeatures = true }, -- 启用所有 feature 做分析
                        check = { command = "clippy" }, -- 保存时用 clippy 检查而不是 cargo check
                        procMacro = { enable = true }, -- 展开过程宏，跳转能进宏内部
                        inlayHints = {
                            typeHints = { enable = true }, -- 变量、字段的推断类型
                            parameterHints = { enable = true }, -- 调用时的形参名
                            chainingHints = { enable = true }, -- 链式调用每一步的中间类型
                            closureReturnTypeHints = { enable = "always" }, -- 显示闭包返回类型
                            maxLength = 25, -- 类型太长就截断，避免把一行撑爆
                        },
                    },
                },
            },
        }
    end,
}
