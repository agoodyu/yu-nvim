-- ============================================================================
-- 同名词高亮
-- 光标停在某个标识符上时，把同一文件里其他同名位置也标出来
-- ============================================================================
return {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
        delay = 200,             -- 光标停 200ms 才高亮，避免快速移动时闪烁
        large_file_cutoff = 2000, -- 超过 2000 行的文件不启用，防止卡顿
    },
    config = function(_, opts)
        require("illuminate").configure(opts)
    end,
}
