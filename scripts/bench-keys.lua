-- ============================================================================
-- 按键延迟测量
-- 在要测的文件里执行 :luafile scripts/bench-keys.lua
-- 逐层测一遍，直接看出是谁在拖慢 j / 10j
-- 次数：let g:bench_count = 500
-- ============================================================================

local times = vim.g.bench_count or 200

-- 按显示宽度补空格，中英混排也能对齐
local function pad(s, width)
    local w = vim.fn.strdisplaywidth(s)
    return s .. string.rep(" ", math.max(0, width - w))
end

local function measure(keys, n)
    local samples = {}
    vim.cmd("normal! gg")
    for _ = 1, n do
        local t0 = vim.uv.hrtime()
        vim.cmd("normal! " .. keys)
        vim.cmd("redraw")
        samples[#samples + 1] = (vim.uv.hrtime() - t0) / 1e6
    end
    table.sort(samples)
    local sum = 0
    for _, v in ipairs(samples) do
        sum = sum + v
    end
    local function pct(p)
        return samples[math.min(#samples, math.max(1, math.floor(#samples * p)))]
    end
    return sum / #samples, pct(0.9), pct(0.99), samples[#samples]
end

-- 每层：setup 改状态，teardown 还原
-- 语法高亮放最后：关掉它会退回 regex 高亮，可能比 treesitter 还慢，仅供参考
local layers = {
    { name = "当前配置" },
    {
        name = "关光标行",
        setup = function()
            vim.wo.cursorline = false
        end,
        teardown = function()
            vim.wo.cursorline = true
        end,
    },
    {
        name = "scrolloff=0",
        setup = function()
            vim.opt.scrolloff = 0
        end,
        teardown = function()
            vim.opt.scrolloff = math.floor((vim.fn.winheight(0) - 1) / 2)
        end,
    },
    {
        name = "折行显示",
        setup = function()
            vim.wo.wrap = true
        end,
        teardown = function()
            vim.wo.wrap = false
        end,
    },
    {
        name = "关符号列",
        setup = function()
            vim.wo.signcolumn = "no"
        end,
        teardown = function()
            vim.wo.signcolumn = "yes"
        end,
    },
}

local lines = {
    ("%s   每层 %d 次按键，单位 ms"):format(vim.fn.expand("%:t"), times),
    pad("层级", 16) .. pad("均值", 8) .. pad("p90", 8) .. pad("p99", 8) .. "最大",
}

for _, layer in ipairs(layers) do
    if layer.setup then
        layer.setup()
    end
    local avg, p90, p99, max = measure("j", times)
    if layer.teardown then
        layer.teardown()
    end
    lines[#lines + 1] = pad(layer.name, 16)
        .. pad(("%.2f"):format(avg), 8)
        .. pad(("%.2f"):format(p90), 8)
        .. pad(("%.2f"):format(p99), 8)
        .. ("%.2f"):format(max)
end

local avg, p90, p99, max = measure("10j", math.max(20, math.floor(times / 5)))
lines[#lines + 1] = pad("10j（滚动）", 16)
    .. pad(("%.2f"):format(avg), 8)
    .. pad(("%.2f"):format(p90), 8)
    .. pad(("%.2f"):format(p99), 8)
    .. ("%.2f"):format(max)

vim.treesitter.stop(0)
local ts = measure("j", times)
lines[#lines + 1] = pad("关语法高亮", 16)
    .. pad(("%.2f"):format(ts), 8)
    .. "（退回 regex 高亮，可能更慢）"
pcall(vim.treesitter.start, 0)

vim.cmd("normal! gg")
vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
