# Neovim 配置

基于 Neovim 0.12 + lazy.nvim 的手写配置，支持 Rust / C / C++ / Python / HTML / CSS / Markdown / Lua。
启动约 12ms，34 个插件里只有 2 个在启动路径上。

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
│   ├── bootstrap.fish             新机器一键安装外部依赖
│   └── push.sh                    日常一键格式化 + 提交 + 推送
├── after/ftplugin/
│   └── rust.lua                   Rust 专用键位，只在 rust 缓冲区生效
└── lua/
    ├── core/                      基础配置，不依赖任何插件
    │   ├── init.lua               加载顺序（顺序有依赖，不要随意调整）
    │   ├── options.lua            编辑器选项：行号、缩进、搜索、撤销、编码
    │   ├── autocmds.lua           自动命令：yank 同步、shada 延迟加载、终端
    │   ├── keymaps.lua            通用键位：leader、折叠、窗口、分屏
    │   ├── lsp.lua                LSP 诊断外观、hover 浮窗、接入后的键位
    │   ├── terminal.lua           底部终端开关，工作目录跟随当前文件
    │   ├── deps.lua               启动后异步检查外部依赖
    │   └── lazy.lua               lazy.nvim 引导与插件分类导入
    │
    ├── deps/                      外部依赖的声明与体检
    │   ├── init.lua               依赖清单（二进制名 + 对应的包名）
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
        │   ├── render-markdown.lua Markdown 实时渲染
        │   └── snacks.lua          图片显示（只开 image 模块）
        │
        ├── editor/                编辑增强
        │   ├── hop.lua            定点跳转
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
        └── tools/
            ├── translator.lua     翻译（bing 引擎）
            └── live-preview.lua  浏览器预览（保存时刷新）
```

### 为什么这样分层

- **`core/` 不依赖插件**：删掉任何插件，core 依然能跑，编辑器不会变成残废。
- **`plugins/` 按用途分目录**：找东西时按"它属于哪一类"想，而不是记文件名。
- **一个文件一个插件**：改某个插件只动一个文件，不会牵连其他配置。

---

## 键位

`<leader>` 是**空格**，`<localleader>` 是**逗号**。

### 基础

| 键                         | 作用                             |
| -------------------------- | -------------------------------- |
| `jj`                       | 退出插入模式（终端里也可用）     |
| `Esc`                      | 清除搜索高亮                     |
| `Y`                        | 复制到行尾                       |
| `空格 q`                   | 退出当前窗口                     |
| `空格 z a` / `z r` / `z m` | 折叠当前块 / 展开全部 / 折叠全部 |
| `Alt-j` / `Alt-k`          | 当前行下移 / 上移                |
| `Alt-j` / `Alt-k`（可视）  | 整段选区下移 / 上移              |

### 窗口与分屏

| 键                                  | 作用                    |
| ----------------------------------- | ----------------------- |
| `Ctrl-h` `Ctrl-j` `Ctrl-k` `Ctrl-l` | 切换到左/下/上/右侧窗口 |
| `空格 w v`                          | 垂直分屏（左右）        |
| `空格 w s`                          | 水平分屏（上下）        |
| `空格 w c`                          | 关闭当前分屏            |
| `空格 w o`                          | 只保留当前分屏          |
| `Ctrl-方向键`                       | 调整分屏宽高            |

### 文件与缓冲区

| 键                    | 作用                  |
| --------------------- | --------------------- |
| `空格 e`              | 文件树开关            |
| `空格 E`              | 在树中定位当前文件    |
| `Shift-l` / `Shift-h` | 下一个 / 上一个缓冲区 |
| `空格 b p`            | 按字母选择缓冲区      |
| `空格 b o`            | 关闭其他缓冲区        |
| `空格 b w`            | 关闭当前缓冲区        |

### 文件树内

| 键                  | 作用                                                                              |
| ------------------- | --------------------------------------------------------------------------------- |
| `o` / `Enter`       | 打开文件、展开目录                                                                |
| `h`                 | 回到上一级目录                                                                    |
| `l`                 | 未展开则展开；已展开则设为新根                                                    |
| `L`                 | 聚焦预览窗口                                                                      |
| `O` + 字母          | 排序（`c` 创建 / `d` 诊断 / `g` git / `m` 修改 / `n` 名称 / `s` 大小 / `t` 类型） |
| `a` `d` `r` `c` `m` | 新建 / 删除 / 重命名 / 复制 / 移动                                                |
| `H` / `R`           | 切换隐藏文件 / 刷新                                                               |

### LSP

| 键                  | 作用                                                   |
| ------------------- | ------------------------------------------------------ |
| `K`                 | 悬停文档（浮窗会获得焦点，`j/k` 滚动，`q`/`Esc` 关闭） |
| `gd` `gD` `gI` `gy` | 定义 / 声明 / 实现 / 类型定义                          |
| `空格 r n`          | 重命名符号                                             |
| `空格 c a`          | 代码操作                                               |
| `空格 d d`          | 查看诊断浮窗                                           |
| `[d` / `]d`         | 上一个 / 下一个诊断                                    |
| `[e` / `]e`         | 上一个 / 下一个错误（跳过警告）                        |

### 代码与工具

| 键         | 作用                                   |
| ---------- | -------------------------------------- |
| `空格 f`   | 格式化当前文件（保存时也会自动格式化） |
| `空格 h p` | 定点跳转（HopWord）                    |
| `空格 T`   | 终端开关                               |
| `空格 t w` | 翻译光标下的词                         |
| `空格 t v` | 翻译选中文本（可视模式）               |
| `空格 m p` | 浏览器预览（保存时刷新）               |
| `空格 m P` | 关闭浏览器预览                         |
| `空格 x t` | TODO 列表                              |

### 注释

Neovim 0.11 起的内置注释命令，由 treesitter 驱动，能按语法树判断注释范围（Python 的 `#` 在字符串里不会被误判）。

| 键                | 作用                             |
| ----------------- | -------------------------------- |
| `gcc`             | 注释 / 取消当前行                |
| `gc` + motion     | 注释 motion 覆盖的行             |
| `gciw`            | 注释当前单词                     |
| `gcap`            | 注释当前段落                     |
| 可视模式选中后 `gc` | 注释选区                       |
| `gbc`             | 注释整个文件                     |
| `gcgc`            | 取消整个注释块                   |

各语言实际使用的注释符：

| 语言              | 注释符       |
| ----------------- | ------------ |
| Rust / C / C++    | `//`         |
| Python / Shell    | `#`          |
| Lua               | `--`         |
| HTML / Markdown   | `<!-- -->`   |
| CSS               | `/* */`      |

### Git（仅在仓库内生效）

| 键          | 作用                |
| ----------- | ------------------- |
| `]h` / `[h` | 下一个 / 上一个改动 |
| `空格 g p`  | 预览改动            |
| `空格 g s`  | 暂存改动            |
| `空格 g r`  | 撤销改动            |
| `空格 g b`  | 查看行历史          |

### Rust

| 键                 | 作用                     |
| ------------------ | ------------------------ |
| `空格 r k`         | 悬停操作菜单（展开宏等） |
| `空格 r r` / `r t` | 运行目标 / 运行测试      |
| `空格 r d`         | 调试目标                 |
| `空格 r e`         | 解释错误码               |
| `空格 r m`         | 展开宏                   |
| `空格 r c`         | 打开 Cargo.toml          |
| `空格 r p` / `r j` | 跳转父模块 / 合并行      |

### 调试

| 键                 | 作用                   |
| ------------------ | ---------------------- |
| `F5`               | 开始 / 继续            |
| `F10` `F11` `F12`  | 单步跳过 / 进入 / 跳出 |
| `空格 d b` / `d u` | 断点 / 调试面板        |

### 补全（插入模式）

| 键                  | 作用                             |
| ------------------- | -------------------------------- |
| `Tab`               | 接受选中；片段内跳到下一个占位符 |
| `Shift-Tab`         | 片段回退一个占位符               |
| `Ctrl-j` / `Ctrl-k` | 下一个 / 上一个候选              |
| `Enter`             | 接受选中                         |
| `Ctrl-e`            | 取消补全                         |

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
| editor | neo-tree         | cmd `Neotree`              |
| editor | hop              | keys                       |
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
| lang   | rustaceanvim     | 启动时（不支持懒加载）     |
| lang   | crates           | BufRead Cargo.toml         |
| tools  | vim-translator   | cmd / keys                 |
| tools  | live-preview     | ft（markdown / html）      |
| tools  | render-markdown  | ft（markdown）             |
| ui     | snacks（image）  | VeryLazy                   |

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

- pacman：`git curl tar gcc make unzip nodejs tree-sitter-cli clang marksman lua-language-server stylua prettier ruff`
- AUR：`basedpyright-bin vscode-langservers-extracted codelldb-bin`
- rustup：`rust-analyzer` / `rustfmt` / `clippy`

**Rust 工具链必须用 rustup，不能用 pacman 或 mason。** rust-analyzer 要和编译器版本对齐，版本错位会导致过程宏展开失败，而且是静默失败。

---

## 注意事项

### 启动耗时

约 12ms（`nvim --startuptime` 实测）。只有三个插件在启动路径上：

- `tokyonight`：配色必须在启动时应用
- `rustaceanvim`：官方要求 `lazy = false`，改成懒加载会破坏 filetype 初始化
- `nvim-treesitter`：官方要求 `lazy = false`，但真正的 parser 安装推迟到了 `VeryLazy` 之后

其余 31 个插件全部懒加载，不影响启动。

### 首次启动很慢

新机器第一次打开会：克隆 34 个插件、编译 17 个 treesitter parser。屏幕可能卡几分钟，这是正常的。之后每次 12ms。

### `cmdheight = 0`

底部不保留命令行行，命令行交给 noice 浮窗。代价是：如果有消息没被 noice 接管（比如某些插件直接 `nvim_echo`），Neovim 会临时撑开一行，看到界面轻微跳动。

### 没有 LSP 进度浮窗

noice 默认把 LSP 的进度渲染成右下角的 `mini` 浮窗（就是 `basedpyright` 那两行，一条进行中、一条 100ms 内残留的"完成"）。配置里把 `lsp.progress.enabled` 关了，代价只是看不到进度，LSP 客户端、诊断、补全、格式化都不受影响。

想恢复就把 `plugins/ui/noice.lua` 里的 `enabled` 改回 `true`；不想占用右下角可以改成 `view = "split"`（底部）或 `view = "popup"`（居中浮窗），再加 `format_done = ""` 就只去掉"完成"那条残留。

### `jj` 有 500ms 延迟

`jj` 映射到 `Esc`，因此单独按 `j` 时 Vim 要等 `timeoutlen`（500ms）确认你是不是要按第二个 `j`。如果打字觉得顿，把 `core/options.lua` 里的 `timeoutlen` 调小。

### 终端关闭会杀进程

`空格 T` 关闭终端时用的是 `nvim_buf_delete(force = true)`，终端里如果有后台任务（`cargo watch`、`npm run dev`）会被直接终止。

### 翻译依赖 bing

`vim-translator` 只保留了 `bing` 引擎。google 在国内不可达，保留它会白白等 10 秒超时。如果 bing 也连不上，会提示"翻译超时或失败"，换网络再试。

### 主题与桌面无关

配色固定用 tokyonight，不接 matugen 动态取色。这样配置复制到任何机器都能直接显示，不依赖桌面的主题系统。`shorindms init` 不会碰 `~/.config/nvim`。

### 文件树 `o` 键的取舍

`o` 被映射为打开文件，占用了原本的排序前缀（`oc`/`od`/...）。排序功能整体挪到了 `O` + 字母。树打开时会自动删掉 `o` 前缀的子映射，否则每次按 `o` 都要等 `timeoutlen` 才能确定意图。

### 浏览器预览

live-preview 默认边打字边刷新。配置里删掉了它的 `TextChanged` 自动命令，改成 `BufWritePost` 手动推送，所以**只有保存才会更新浏览器**。

必须用 `空格 m p` 启动——直接在命令行敲 `:LivePreview start` 不会执行清理逻辑，仍然是打字即刷新。

live-preview 没提供这个配置项，只能自己实现，因此依赖 `livepreview.server.connecting_clients` 和 `websocket.send_json` 这两个内部 API，插件大版本升级后可能需要跟着调整。相关调用都包了 `pcall`，真失效只会静默跳过，不会报错。

### 代码格式由 stylua 统一

`.stylua.toml` 定义了全部 Lua 代码的格式：4 空格缩进、单行不超过 100 列、字符串优先双引号。

这份配置同时作用于两个地方——命令行 `stylua .` 和编辑器里的 `conform.nvim`（保存 `.lua` 文件时自动调用 stylua），所以两边不会打架。

改完配置后编辑器里可能会提示"文件已更改"（磁盘上已是新格式，buffer 里还是旧的），执行 `:checktime` 或 `:e!` 重新加载一次即可。

### lazy 的 luarocks 提示可以忽略

`:checkhealth lazy` 会提示没装 luarocks、无法安装需要 luarocks 的插件。当前配置没有这类插件（图片显示用的是 snacks 的 image 模块，只依赖 `magick`），所以不影响任何功能。

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

第三步第一次会卡 2~4 分钟——要克隆 34 个插件、编译 17 个 treesitter parser。这是正常的，之后每次启动 12ms。

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

### 桌面环境互不干扰

配置不依赖任何桌面主题系统，配色固定用 tokyonight。`shorindms init` / `shorindms update` 不会碰 `~/.config/nvim`，两边可以共存。

### 改完配置后

```bash
cd ~/.config/nvim
git add -A && git commit -m "..." && git push
```

`lazy-lock.json` 要一起提交，它锁定了 34 个插件的具体版本。

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
