# Neovim 配置

基于 Neovim 0.12 + lazy.nvim 的手写配置，支持 Rust / C / C++ / Python / HTML / CSS / Markdown / Lua。
启动约 12ms，35 个插件里只有 2 个在启动路径上。

---

## 目录结构

```
~/.config/nvim/
├── init.lua                       入口，只 require core.init
├── lazy-lock.json                 插件版本锁定，跨机器复制时必须一起带上
├── README.md                      本文件
├── .stylua.toml                   Lua 格式化规则（stylua 和编辑器共用）
├── .gitignore
├── scripts/
│   ├── bench-keys.lua             移动延迟测量，逐层对比找瓶颈
│   ├── bootstrap.fish             新机器一键安装外部依赖
│   └── push.sh                    日常一键格式化 + 提交 + 推送
├── after/ftplugin/
│   └── rust.lua                   Rust 专属键位（悬停菜单 / 展开宏 / 解释错误码…）
└── lua/
    ├── core/                      基础配置，不依赖任何插件
    │   ├── init.lua               加载顺序（顺序有依赖，不要随意调整）
    │   ├── options.lua            编辑器选项：行号、缩进、搜索、撤销、编码
    │   ├── autocmds.lua           自动命令：yank 同步、shada、终端窗口、命令行窗口
    │   ├── bigfile.lua            大文件 / 超长行降级
    │   ├── keymaps.lua            通用键位：leader、折叠、窗口、分屏、行移动
    │   ├── comment.lua            注释键位：gcc / gcO / gco / gcI / gcA、空格 /
    │   ├── lsp.lua                诊断外观与浮窗、接入缓冲区后的键位
    │   ├── hover.lua              hover 浮窗（自己发请求、自己开窗）
    │   ├── linetypes.lua          按需查本行所有变量的类型（空格 i t）
    │   ├── terminal.lua           底部终端开关，工作目录跟随当前文件
    │   ├── run.lua                各语言的运行键位（空格 r r / r t / r d）
    │   └── lazy.lua               lazy.nvim 引导与插件分类导入
    │
    ├── deps/                      外部依赖：清单 + 体检
    │   ├── init.lua               依赖清单（bin + 对应包名）与启动后自检
    │   └── health.lua             :checkhealth deps 的实现
    │
    └── plugins/                   插件，一个文件一个插件，按用途分类
        ├── ui/                    界面
        │   ├── tokyonight.lua     配色主题（moon + 透明）
        │   ├── lualine.lua        底部状态栏
        │   ├── bufferline.lua     顶部缓冲区标签栏
        │   ├── noice.lua          命令行浮窗
        │   ├── which-key.lua      按键提示
        │   ├── indent-blankline.lua 缩进参考线
        │   ├── scrolleof.lua      文件末尾滚动余量
        │   └── render-markdown.lua Markdown 实时渲染
        │
        ├── editor/                编辑增强
        │   ├── flash.lua          标签跳转（空格 j s / j S / j R）
        │   ├── neo-tree.lua       左侧文件树
        │   ├── gitsigns.lua       git 增删改标记
        │   ├── todo-comments.lua  TODO / FIXME 高亮
        │   ├── illuminate.lua     同名词高亮
        │   ├── nvim-ts-autotag.lua HTML / JSX 标签自动闭合
        │   ├── nvim-autopairs.lua 自动配对括号
        │   └── nvim-surround.lua  增删改包围符号
        │
        ├── lsp/                   LSP 与代码智能
        │   ├── lspconfig.lua      语言服务器的启用与参数
        │   ├── blink.lua          补全引擎
        │   ├── lazydev.lua        写 nvim 配置时的插件 API 补全
        │   ├── conform.lua        保存时格式化
        │   ├── treesitter.lua     语法高亮、折叠、缩进
        │   └── dap.lua            调试（codelldb）
        │
        ├── lang/                  语言专属
        │   ├── rust.lua           rustaceanvim
        │   └── crates.lua         Cargo.toml 增强
        │
        ├── zh/                    面板中文化
        │   └── which-key-zh.lua   which-key 中文词表（只补 nvim 自带键）
        │
        └── tools/
            ├── translator.lua     翻译（bing 引擎）
            ├── suda.lua           sudo 读写文件
            └── live-preview.lua  浏览器预览（保存时刷新）
```

### 为什么这样分层

- **`core/` 不依赖插件**：删掉任何插件，core 依然能跑，编辑器不会变成残废。
- **`plugins/` 按用途分目录**：找东西时按"它属于哪一类"想，而不是记文件名。
- **一个文件一个插件**：改某个插件只动一个文件，不会牵连其他配置。

---

## 键位

`<leader>` 是**空格**，`<localleader>` 是**逗号**。忘了键位就按 `空格 ?`，会直接列出所有以空格开头的键（每组可以再往里展开）。

下面的分类和 which-key 面板里的分组一一对应。

### 基础

| 键                         | 作用                             |
| -------------------------- | -------------------------------- |
| `jj`                       | 退出插入模式（终端里也可用）     |
| `Esc`                      | 清除搜索高亮                     |
| `Y`                        | 复制到行尾                       |
| `空格 q`                   | 退出当前窗口                     |
| `空格 ?`                   | 键位总览（空格开头的所有键）     |
| `空格 z a` / `z r` / `z m` | 折叠当前块 / 展开全部 / 折叠全部 |
| `Alt-j` / `Alt-k`          | 当前行下移 / 上移                |
| `Alt-j` / `Alt-k`（可视）  | 整段选区下移 / 上移              |

### 窗口与分屏

| 键                                  | 作用                          |
| ----------------------------------- | ----------------------------- |
| `Ctrl-h` `Ctrl-j` `Ctrl-k` `Ctrl-l` | 切换到左 / 下 / 上 / 右侧窗口 |
| `空格 w v`                          | 垂直分屏（左右）              |
| `空格 w s`                          | 水平分屏（上下）              |
| `空格 w c`                          | 关闭当前分屏                  |
| `空格 w o`                          | 只保留当前分屏                |
| `Ctrl-方向键`                       | 调整分屏宽高                  |

### 缓冲区

| 键                    | 作用                  |
| --------------------- | --------------------- |
| `Shift-l` / `Shift-h` | 下一个 / 上一个缓冲区 |
| `空格 b p`            | 按字母选择缓冲区      |
| `空格 b o`            | 关闭其他缓冲区        |
| `空格 b w`            | 关闭当前缓冲区        |

### 文件树

| 键       | 作用               |
| -------- | ------------------ |
| `空格 e` | 文件树开关         |
| `空格 E` | 在树中定位当前文件 |

树里自己的按键：

| 键                  | 作用                                                                              |
| ------------------- | --------------------------------------------------------------------------------- |
| `o` / `Enter`       | 打开文件、展开目录                                                                |
| `h`                 | 回到上一级目录                                                                    |
| `l`                 | 未展开则展开；已展开则设为新根                                                    |
| `L`                 | 聚焦预览窗口                                                                      |
| `O` + 字母          | 排序（`c` 创建 / `d` 诊断 / `g` git / `m` 修改 / `n` 名称 / `s` 大小 / `t` 类型） |
| `a` `d` `r` `c` `m` | 新建 / 删除 / 重命名 / 复制 / 移动                                                |
| `H` / `R`           | 切换隐藏文件 / 刷新                                                               |

### 跳转与 LSP

| 键                      | 作用                                                             |
| ----------------------- | ---------------------------------------------------------------- |
| `K`                     | 悬停文档（浮窗会获得焦点，`j/k` 滚动，`q`/`Esc` 关闭）           |
| `gd` `gD` `gI` `gy`     | 定义 / 声明 / 实现 / 类型定义                                    |
| `gO`                    | 当前文件的符号列表                                               |
| `空格 r n` 或 `grn`     | 重命名符号                                                       |
| `空格 c a` 或 `gra`     | 代码操作                                                         |
| `grr` / `gri` / `grt`   | 引用 / 实现 / 类型定义（nvim 0.11 起自带）                       |
| `gx`                    | 用系统程序打开光标下的路径或链接                                 |
| `空格 j s`              | 标签跳转：输入几个字符，按标签跳过去（可视 / 操作符后也能用）    |
| `空格 j S`              | 选中语法节点：外层代码块直接按标签选，treesitter 驱动            |
| `空格 j R`              | 语法树搜索：可视模式或操作符后按，选中 treesitter 节点范围       |
| `空格 i h`              | 类型提示开关（变量 / 参数的推断类型，默认开启）                  |
| `空格 i t`              | 查看本行所有变量的类型（`a: Literal['a']` 这种）                 |

### 诊断与调试

| 键                | 作用                                       |
| ----------------- | ------------------------------------------ |
| `空格 d d`        | 查看诊断浮窗（可进入滚动，`q`/`Esc` 关闭） |
| `[d` / `]d`       | 上一个 / 下一个诊断（跳过 HINT）           |
| `[e` / `]e`       | 上一个 / 下一个错误（跳过警告）            |
| `空格 d f`        | 开始 / 继续                                |
| `空格 d s`        | 单步跳过                                   |
| `空格 d n`        | 单步进入                                   |
| `空格 d o`        | 单步跳出                                   |
| `空格 d b`        | 断点                                       |
| `空格 d u`        | 调试面板                                   |
| `F5`              | 开始 / 继续（`空格 d f` 的别名）           |
| `F10` `F11` `F12` | 单步跳过 / 进入 / 跳出（同上）              |

各语言的调试适配器：

| 语言 | 适配器 | 说明 |
| --- | --- | --- |
| Rust | `rt_lldb` | rustaceanvim 自带，检测到 codelldb 就用 codelldb |
| Python | `dap-python` | `uv run --with debugpy` 启动，不用往项目里装 debugpy |
| C / C++ | `codelldb` | `lua/plugins/lsp/dap.lua` 里注册的适配器，程序和工作目录取当前文件 |

被调试进程的解释器由 dap-python 依次查找 `VIRTUAL_ENV`、`CONDA_PREFIX`、项目下的 `venv` / `.venv` / `env` / `.env`。

### 代码与工具

| 键                 | 作用                                   |
| ------------------ | -------------------------------------- |
| `空格 f`           | 格式化当前文件（保存时也会自动格式化） |
| `空格 T`           | 终端开关                               |
| `空格 t w`         | 翻译光标下的词（普通 / 可视模式都行） |
| `空格 t v`         | 翻译选中文本（可视模式）               |
| `空格 m p`         | 浏览器预览（保存时刷新）               |
| `空格 m P`         | 关闭浏览器预览                         |
| `空格 x t`         | TODO 列表                              |
| `空格 u W` / `u R` | 以 sudo 写入 / 重新打开当前文件        |

### 注释

Neovim 0.11 起的内置注释命令，由 treesitter 驱动，能按语法树判断注释范围（Python 的 `#` 在字符串里不会被误判）。

内置只有 `gc` / `gcc` / `gb`，表里 `gcO` / `gco` / `gcI` / `gcA` 和 `空格 /` 这几条是 `core/keymaps.lua` 里补的。注释符现读 `'commentstring'`，所以块注释语言（CSS / HTML / Markdown）会自己补上 `*/` 或 `-->`；`gcI` 跳过行首缩进插入，`gcA` 在块注释时把光标停在前后两个符号中间。

| 键                  | 作用                                  |
| ------------------- | ------------------------------------- |
| `gcc`               | 注释 / 取消当前行                     |
| `空格 /`            | 注释 / 取消当前行，可视模式作用于选区 |
| `gcO` / `gco`       | 上方 / 下方新起一行注释，进插入模式   |
| `gcI` / `gcA`       | 行首 / 行尾插入注释，进插入模式       |
| `gc` + motion       | 注释 motion 覆盖的行                  |
| `gciw`              | 注释当前单词                          |
| `gcap`              | 注释当前段落                          |
| 可视模式选中后 `gc` | 注释选区                              |
| `gbc`               | 注释整个文件                          |
| `gcgc`              | 取消整个注释块                        |

各语言实际使用的注释符：

| 语言            | 注释符     |
| --------------- | ---------- |
| Rust / C / C++  | `//`       |
| Python / Shell  | `#`        |
| Lua             | `--`       |
| HTML / Markdown | `<!-- -->` |
| CSS             | `/* */`    |

### Git（仅在仓库内生效）

| 键          | 作用                |
| ----------- | ------------------- |
| `]h` / `[h` | 下一个 / 上一个改动 |
| `空格 g p`  | 预览改动            |
| `空格 g s`  | 暂存改动            |
| `空格 g r`  | 撤销改动            |
| `空格 g b`  | 查看行历史          |

### 运行：Rust

| 键                 | 作用                     |
| ------------------ | ------------------------ |
| `空格 r r` / `r t` | 运行目标 / 运行测试      |
| `空格 r d`         | 调试目标                 |

### 运行：Rust 专属操作

`空格 r k` 悬停操作菜单、`空格 r e` 解释错误码、`空格 r m` 展开宏、`空格 r c` 打开 Cargo.toml、`空格 r p` / `r j` 跳转父模块 / 合并行——这些是 rustaceanvim 独有的，放在 `after/ftplugin/rust.lua`。

### 运行：Python / Lua / C / C++

| 键         | 作用                             |
| ---------- | -------------------------------- |
| `空格 r r` | 运行当前文件（命令按语言自动选） |
| `空格 r t` | 跑当前文件的测试（仅 Python）    |
| `空格 r p` | 跑整个项目的测试（仅 Python）    |

各语言实际执行的命令：Python 是 `uv run python <文件>`，会自动使用项目里的 pyproject / 虚拟环境；Lua 是 `lua <文件>`；C / C++ 用 `clang` / `clang++` 编译到 `/tmp/nvim-run-<文件名>` 再直接执行，不往源码目录丢产物。Python 的测试是 `uv run --with pytest pytest <文件>`——`--with pytest` 是关键，项目没把 pytest 写成依赖时 uv 会直接报 `Failed to spawn: pytest`，加上它就临时把 pytest 装进这次运行的环境（和 dap-python 用 `uv run --with debugpy` 同一个思路）。

`空格 r t` 只跑当前文件；文件里没有测试函数时 pytest 会显示 `collected 0 items` 并以退出码 5 结束，这时用 `空格 r p` 跑整个项目。

Rust 的测试走 `空格 r t`，但那是 rustaceanvim 的 testables（从 code lens 上取测试目标），和这里的 pytest 不是一回事。

各语言实际执行的命令：Python 是 `uv run python <文件>`，会自动使用项目里的 pyproject / 虚拟环境；Lua 是 `lua <文件>`；C / C++ 用 `clang` / `clang++` 编译到 `/tmp/nvim-run-<文件名>` 再直接执行，不往源码目录丢产物。

运行前如果缓冲区有改动会先保存，输出在底部终端里（和 `空格 T` 用的是同一个窗口）。

### 补全（插入模式）

| 键                  | 作用                             |
| ------------------- | -------------------------------- |
| `Tab`               | 接受选中；片段内跳到下一个占位符 |
| `Shift-Tab`         | 片段回退一个占位符               |
| `Ctrl-j` / `Ctrl-k` | 下一个 / 上一个候选              |
| `Enter`             | 接受选中                         |
| `Ctrl-e`            | 取消补全                         |
| `Ctrl-s`            | 函数签名帮助                     |

---

## 插件清单

| 分类   | 插件             | 加载方式                   |
| ------ | ---------------- | -------------------------- |
| ui     | tokyonight       | 启动时（配色）             |
| ui     | lualine          | VeryLazy                   |
| ui     | bufferline       | VeryLazy                   |
| ui     | noice            | VeryLazy                   |
| ui     | which-key        | VeryLazy                   |
| ui     | indent-blankline | BufReadPost                |
| ui     | scrolleof        | CursorMoved                |
| editor | flash            | keys（按需加载）           |
| editor | neo-tree         | cmd `Neotree`              |
| editor | gitsigns         | BufReadPre                 |
| editor | todo-comments    | BufReadPost                |
| editor | illuminate       | BufReadPost                |
| editor | nvim-ts-autotag  | ft（html / jsx）           |
| editor | nvim-autopairs   | InsertEnter                |
| editor | nvim-surround    | VeryLazy                   |
| lsp    | nvim-lspconfig   | BufReadPre                 |
| lsp    | blink.cmp        | InsertEnter / CmdlineEnter |
| lsp    | lazydev          | ft（lua）                  |
| lsp    | conform          | BufWritePre                |
| lsp    | nvim-treesitter  | 启动时（不支持懒加载）     |
| lsp    | nvim-dap         | BufReadPre                 |
| lsp    | nvim-dap-python  | 随 nvim-dap（依赖）        |
| lang   | rustaceanvim     | 启动时（不支持懒加载）     |
| lang   | crates           | BufRead Cargo.toml         |
| tools  | vim-translator   | cmd / keys                 |
| tools  | live-preview     | ft（markdown / html）      |
| tools  | render-markdown  | ft（markdown）             |

---

## 外部依赖

配置本身只是 Lua，LSP、格式化、语法解析都依赖外部二进制。

### 检查

```vim
:checkhealth deps
```

会逐项列出每个二进制、是否找到、对应哪个包。全绿说明环境完整。

启动后如果缺东西，右上角会弹一次提示。

### 一键安装（Arch / CachyOS）

```fish
~/.config/nvim/scripts/bootstrap.fish
```

脚本是幂等的，重复执行只会补缺失的包。内容包括：

- pacman：`git curl tar gcc make unzip nodejs tree-sitter-cli clang marksman lua-language-server stylua prettier uv ruff`
- AUR：`basedpyright-bin vscode-langservers-extracted codelldb-bin`
- rustup：`rust-analyzer` / `rustfmt` / `clippy`

**Rust 工具链必须用 rustup，不能用 pacman 或 mason。** rust-analyzer 要和编译器版本对齐，版本错位会导致过程宏展开失败，而且是静默失败。

---

## 注意事项

### 启动耗时

约 **12.6ms**（`nvim --startuptime` 实测，三次取样 12.5 / 12.5 / 13.7）。只有四个插件在启动路径上：

- `tokyonight`：配色必须在启动时应用，否则会闪一下默认配色
- `rustaceanvim`：官方要求 `lazy = false`，改成懒加载会破坏 filetype 初始化
- `nvim-treesitter`：官方要求 `lazy = false`，但真正的 parser 安装推迟到了 `VeryLazy` 之后
- `suda`：必须在第一个 `BufReadPre` 之前注册好，晚于打开文件就等于没开

其余 31 个插件全部懒加载，不影响启动。

两处额外的启动优化：

- **诊断外观推迟到 `VeryLazy`**：碰一下 `vim.diagnostic` 就要 require 整个模块（实测 1.0ms）。现在 `core/lsp.lua` 只注册一个 `User VeryLazy` 回调，`require('core.lsp')` 从 1.21ms 降到 0.19ms。实测 VeryLazy 之后配置正常生效（`prefix = ●`、`update_in_insert = true`、诊断照常画行尾文字），而且 LSP 比它晚得多，看不到差别
- **跳过六个用不到的内置插件**（`gzip` / `rplugin` / `tarPlugin` / `zipPlugin` / `spellfile` / `tutor`）：在 `init.lua` 里设 `vim.g.loaded_*`，它们的脚本仍会被 sourcing 但立刻返回（gzip 从 0.123ms 降到 0.010ms）。`matchit`、`matchparen`、`netrw`、`shada`、`man`、`editorconfig` 都保留

### 首次启动很慢

新机器第一次打开会：克隆 35 个插件、编译 17 个 treesitter parser。屏幕可能卡几分钟，这是正常的。之后每次 12ms。

### 面板中文词表不覆盖自己的键

`plugins/zh/which-key-zh.lua` 是一份按 LazyVim 默认键位写的中文词表，跟这套配置的布局并不一致——LazyVim 里 `<leader>d` 是「调试」、`<leader>x` 是「诊断」，这里是「诊断与调试」和「TODO」。不加限制的话它会在每次 `CursorHold` 之后把面板文字又改回去。

现在它只补两类：nvim 自带键（`<c-w>h` → 移至左侧窗口、`!` → 运行程序）和插件留下的英文描述。词表本身也从 820 条精简到 **306 条常用键**（文件 1069 行 → 555 行），treesitter 文本对象那类几百个 `a"` / `il(` 组合全部去掉。空格开头的键、以及 `ui/which-key.lua` 里声明过分组的键（`g` / `gr` / `gc` / `z` / `[` / `]` / `<c-w>`）在 `ours()` 里跳过——那几组在 `ui/which-key.lua` 里写了 `mode = { "n", "x", "o" }`，普通 / 可视 / 操作符三个模式都用我们自己的名字。

想改自己的键位文字，去改映射的 `desc` 或 which-key 的分组名，别指望词表。

### 移动卡顿：先量再改

`j/k/h/l` 发粘时先跑一次测量，别凭感觉调参数：

```
:luafile scripts/bench-keys.lua
```

它会在当前文件上逐层测 `j`（当前配置 / 关光标行 / scrolloff=0 / 折行 / 关符号列 / 10j 滚动 / 关语法高亮），输出均值、p90、p99、最大值，顺便标出最慢的那几次。

实测（80×24 伪终端，kitty 里绝对值会更高，比例是对的）：

| 场景 | 单次 `j` |
|---|---|
| lua 配置文件（378 行） | 0.88ms |
| 同上，关掉光标行 | 0.69ms |
| 同上，关掉语法高亮 | 0.15ms |
| 每行 2800 字符的文件 | 4.4ms |
| 同上，降级后（关高亮 + 折行） | 2.5ms |
| 24000 行的文件 | 0.18ms → 降级后 0.03ms |

结论是 treesitter 重画占了大头（普通文件里 83%），lualine、bufferline、gitsigns、indent-blankline、illuminate、scrollEOF 加一起不到 0.05ms。真正会卡住手的是**超长行**和**超大文件**——一行 2800 字符比正常文件慢 7 倍，而默认的 `wrap = false` 让 nvim 每次都要算整行。

所以 `core/autocmds.lua` 加了自动降级：超过 2000 行、400KB，或单行超过 1000 字符时，关掉语法高亮（退回 regex 高亮，颜色还在）、光标行、相对行号和 treesitter 折叠缩进；长行的再开折行。日常文件碰不到这些阈值——README 538 行、最长 274 字符，lua 配置最长 99 字符。

降级时右下角会提示原因，想撤销就把 `heavy` 表里的阈值调大，或者 `:e` 重新打开前先调。

嫌普通文件还慢的话，按上面表里的两个旋钮：`cursorline = false`（省 20%）、`scrolloff` 调小（省 20%），代价是光标行高亮和居中滚动没了。

### `cmdheight = 0`

底部不保留命令行行，命令行交给 noice 浮窗。代价是：如果有消息没被 noice 接管（比如某些插件直接 `nvim_echo`），Neovim 会临时撑开一行，看到界面轻微跳动。

### 没有 LSP 进度浮窗

noice 默认把 LSP 的进度渲染成右下角的 `mini` 浮窗（就是 `basedpyright` 那两行，一条进行中、一条 100ms 内残留的"完成"）。配置里把 `lsp.progress.enabled` 关了，代价只是看不到进度，LSP 客户端、诊断、补全、格式化都不受影响。

想恢复就把 `plugins/ui/noice.lua` 里的 `enabled` 改回 `true`；不想占用右下角可以改成 `view = "split"`（底部）或 `view = "popup"`（居中浮窗），再加 `format_done = ""` 就只去掉"完成"那条残留。

### 类型提示

inlay hints 默认开启：变量、参数后面直接显示推断出来的类型，不用悬停。Python 由 basedpyright 的 `analysis.inlayHints` 三项控制（变量类型 / 实参名 / 返回类型），Rust 由 rust-analyzer 的 `inlayHints` 控制（类型、参数、链式调用、闭包返回，并用 `maxLength = 25` 截断过长的类型），C/C++、Lua、Markdown 由各自服务器提供。

两处细节：进入插入模式时提示会自动隐藏，离开后恢复——每敲一个字符服务器都要重算一遍，边打边刷既卡又跳；`空格 i h` 是全局开关，切换后所有缓冲区一起生效，关掉之后新打开的文件也不会自动打开。服务器对字面量赋值（`a = 'a'`）不发 inlay hint，要看这类类型按 `空格 i t`——它按需对光标所在行的每个标识符发一次 hover 请求，把类型拼成一列弹出来。

### 诊断只显示 WARN 及以上

`core/lsp.lua` 给 `virtual_text`、`signs`、`underline`、`jump` 都加了 `severity = { min = WARN }`。原因是 rustc/clippy 会把一条警告拆成"警告 + note"两条推过来，note 属于 HINT 级；不过滤的话一个 `unused_assignments` 会在屏幕上变成两行。

过滤后 HINT 不画行尾文字、不占符号列、`]d` 也不会停在它上面。`空格 d d` 的浮窗不做过滤，note 想看随时能看。

行尾文字另外做了压缩：多行消息折成一行，超过 100 字截断加 `…`。rustc 的备注经常几百字，`wrap=false` 之后会一直拖到屏幕外。

状态栏和标签栏的数字也跟着对齐了：`ui/lualine.lua` 把诊断组件换成自定义 `sources`（只返回 error / warn），`ui/bufferline.lua` 在 `setup` 之后包了一层 `bufferline.diagnostics.get`，把 info / hint 从计数和标签染色里去掉。所以只有提示的缓冲区现在既不显示标记，也不在状态栏和标签上出现数字。

bufferline 那层是改第三方模块的方法，升级插件大版本时留意 `diagnostics.get` 的返回结构有没有变（`{count, level, errors}`）。

`空格 d d` 打开浮窗后光标会直接进到窗口里，`j/k`、`<C-d>`/`<C-u>` 可以滚动，`q` 或 `Esc` 关闭并回到原来的窗口。`]d`/`[d` 跳转时弹出的那个浮窗故意不抢焦点——连按 `]d` 不会被窗口切换打断。

### `jj` 有 500ms 延迟

`jj` 映射到 `Esc`，因此单独按 `j` 时 Vim 要等 `timeoutlen`（120ms）确认你是不是要按第二个 `j`。`timeoutlen` 已从 200 调到 120——实测 200ms 时单个 `j` 要到 t≈224ms 才落盘，打字节奏里键间隔常有 100–300ms，每个含 `j` 的词都会撞上。如果还觉得顿，删掉 `jj` 映射是唯一零代价方案（vim 没有按映射单独设超时的机制）。

### 终端关闭会杀进程

`空格 T` 关闭终端时用的是 `nvim_buf_delete(force = true)`，终端里如果有后台任务（`cargo watch`、`npm run dev`）会被直接终止。

### 翻译依赖 bing

`vim-translator` 只保留了 `bing` 引擎。google 在国内不可达，保留它会白白等 10 秒超时。如果 bing 也连不上，会提示"翻译超时或失败"，换网络再试。

两个键在插件里的实现不同，值得记一下：`空格 t w` 走**不带范围**的 `:TranslateW`，插件会取光标下的词（`expand('<cword>')`）；`空格 t v` 走**带范围**的 `:'<,'>TranslateW`，插件按 `'<` `'>` 标记取选中的文本。注意 `TranslateWV` 只是插件的 `<Plug>` 映射名，不是命令，当命令用会报 `E492: 不是编辑器的命令`。

### 主题与桌面无关

配色固定用 tokyonight，不接 matugen 动态取色。这样配置复制到任何机器都能直接显示，不依赖桌面的主题系统。`shorindms init` 不会碰 `~/.config/nvim`。

### 文件树 `o` 键的取舍

`o` 被映射为打开文件，占用了原本的排序前缀（`oc`/`od`/...）。排序功能整体挪到了 `O` + 字母。树打开时会自动删掉 `o` 前缀的子映射，否则每次按 `o` 都要等 `timeoutlen` 才能确定意图。

### 浏览器预览

live-preview 默认边打字边刷新。配置里删掉了它的 `TextChanged` 自动命令，改成 `BufWritePost` 手动推送，所以**只有保存才会更新浏览器**。

必须用 `空格 m p` 启动——直接在命令行敲 `:LivePreview start` 不会执行清理逻辑，仍然是打字即刷新。

live-preview 没提供这个配置项，只能自己实现，因此依赖 `livepreview.server.connecting_clients` 和 `websocket.send_json` 这两个内部 API，插件大版本升级后可能需要跟着调整。相关调用都包了 `pcall`，真失效只会静默跳过，不会报错。

### Python 保存时自动修 lint

保存 `.py` 走 conform 的三步：`ruff check --fix`（只做安全修复，比如删掉没用到的 import）→ `ruff check --select I --fix`（整理 import 顺序）→ `ruff format`。规则来自项目里的 `pyproject.toml` / `ruff.toml`，没有就用 ruff 默认值。不想让保存自动改代码，把 `plugins/lsp/conform.lua` 里 python 那行的 `ruff_fix` 去掉即可。

basedpyright 另外开了 `strictListInference` / `strictDictionaryInference` / `strictSetInference`，容器字面量按元素逐项推断，inlay hints 里的 `list[int]`、`dict[str, int]` 更准。

### 代码格式由 stylua 统一

`.stylua.toml` 定义了全部 Lua 代码的格式：4 空格缩进、单行不超过 100 列、字符串优先双引号。

这份配置同时作用于两个地方——命令行 `stylua .` 和编辑器里的 `conform.nvim`（保存 `.lua` 文件时自动调用 stylua），所以两边不会打架。

改完配置后编辑器里可能会提示"文件已更改"（磁盘上已是新格式，buffer 里还是旧的），执行 `:checktime` 或 `:e!` 重新加载一次即可。

### lazy 的 luarocks 提示可以忽略

当前配置没有这类插件，所以不影响任何功能。

### 需要 Neovim ≥ 0.12

`nvim-treesitter` 用的是 `main` 分支，这是为 0.12 重写的不兼容版本。装在 0.11 或更老的版本上无法工作。

---

## 迁移到新机器

仓库地址：<https://github.com/agoodyu/yu-nvim>

### 三步

```fish
# 1. 克隆配置（含 lazy-lock.json，保证插件版本一致）
git clone https://github.com/agoodyu/yu-nvim.git ~/.config/nvim

# 2. 装外部依赖（幂等，重复执行只补缺失的包）
~/.config/nvim/scripts/bootstrap.fish

# 3. 首次启动，等插件克隆和 parser 编译完成
nvim
```

第三步第一次会卡 2~4 分钟——要克隆 35 个插件、编译 17 个 treesitter parser。这是正常的，之后每次启动 12ms。

### 脚本会装什么

| 来源 | 包 |
| --- | --- |
| pacman | `git curl tar gcc make unzip nodejs tree-sitter-cli clang marksman lua-language-server stylua prettier ruff` |
| AUR | `basedpyright-bin vscode-langservers-extracted codelldb-bin` |
| rustup | `rust-analyzer` `rustfmt` `clippy` |

### 验证

```vim
:checkhealth deps
```

15 项外部依赖全绿就说明环境完整。启动后如果缺东西，右上角会弹一次提示。

### Rust 必须走 rustup

`rust-analyzer` 要和编译器版本对齐，版本错位会导致过程宏展开**静默失败**（不报错，但跳转进不去宏内部）。所以不能用 pacman 或 mason 的版本，`bootstrap.fish` 已经处理好了：

```fish
rustup component add rust-analyzer rustfmt clippy
```

### Rust 检查只覆盖当前 crate

`check.workspace = false`：保存时 clippy 只检查当前 crate，多 crate 工作区里其它成员不会跟着检查，换来的是保存不卡。同时关掉了 `diagnostics.experimental`（实验性诊断慢且爱误报），并把 `typing.autoClosingBrackets` 设为 `never`，括号交给 nvim-autopairs，避免补两次。另外 rustfmt 的 `default_edition` 设成 2024，跟当前工具链一致——没有 Cargo.toml 的单文件也会按 2024 解析。

### 桌面环境互不干扰

配置不依赖任何桌面主题系统，配色固定用 tokyonight。`shorindms init` / `shorindms update` 不会碰 `~/.config/nvim`，两边可以共存。

### 改完配置后

```bash
cd ~/.config/nvim
git add -A && git commit -m "..." && git push
```

`lazy-lock.json` 要一起提交，它锁定了 35 个插件的具体版本。

---

## 版本管理

配置用 git tag 标记版本，GitHub 上可以看到每个版本的变更说明。

### 日常更新：一键脚本

改完配置后跑一条命令就行：

```fish
~/.config/nvim/scripts/push.sh "提交说明"
```

它会自动：按 `.stylua.toml` 格式化 → 列出改动 → 提交 → 推送。

带版本号参数则额外打标签并创建 Release：

```fish
~/.config/nvim/scripts/push.sh "加了个新插件" v1.1.0
```

`push.sh` 的版本号是可选的附赠动作：没有改动且**不传**版本号时会退出（退出前先比对上游，若上次是「提交成功、推送失败」，会接着把提交补推上去）；传了版本号则跳过提交，直接在已有提交上打标签并建 Release。标签会在提交前先校验（格式、本地/远端重名），重复时立刻失败，不会留下「提交了但没打上标签」的半截状态。

### 手动流程

脚本做的事，手动来就是这三步：

```bash
cd ~/.config/nvim
stylua .                                    # 统一格式
git add -A && git commit -m "..." && git push
```

### 打一个新版本

```bash
cd ~/.config/nvim

# 1. 先把改动提交推送
git add -A && git commit -m "..." && git push

# 2. 打标签
git tag -a v1.1.0 -m "v1.1.0 说明"
git push origin v1.1.0

# 3. 创建 Release，--generate-notes 根据提交记录自动生成更新日志
gh release create v1.1.0 --title "v1.1.0" --generate-notes
```

需要 `gh` 命令行工具并完成登录：

```fish
sudo pacman -S github-cli
gh auth login
gh auth setup-git
```

### 当前版本

| 版本 | 说明 |
| --- | --- |
| [v1.0.0](https://github.com/agoodyu/yu-nvim/releases/tag/v1.0.0) | 初始版本 |

### 用指定版本部署

```bash
git clone --branch v1.0.0 https://github.com/agoodyu/yu-nvim.git ~/.config/nvim
```

### 语义化版本约定

| 改动类型 | 版本号 | 说明 |
| --- | --- | --- |
| 破坏性改动 | `v2.0.0` | 键位重排、配置结构调整，别人升级会不适应 |
| 新增功能 | `v1.1.0` | 加插件、加键位，不影响现有使用 |
| 修复 bug | `v1.0.1` | 只改行为，不加新东西 |
