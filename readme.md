# DUT Aeromodelling Association Drone Development Guide

> 大连理工大学航模协会无人机开发指南文档仓库，基于 [MkDocs](https://www.mkdocs.org/) + [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) 构建。

在线文档：https://drone-dev.qsq.cool

---

## 环境准备

### 1. 安装 Python

确保系统已安装 Python 3.8+，并配置好 pip。

### 2. 安装 MkDocs 及相关依赖

```bash
pip install mkdocs mkdocs-material mkdocs-static-i18n
```

> `mkdocs-static-i18n` 用于多语言支持（中/英）。

---

## 本地预览与构建

| 脚本 | 说明 |
|------|------|
| `preview.bat` | 启动本地开发服务器，默认 http://127.0.0.1:8000，文件修改后自动热更新 |
| `build.bat` | 构建静态站点，输出到 `site/` 目录 |
| `gh-deploy.bat` | 部署到 GitHub Pages |

也可直接使用命令：

```bash
mkdocs serve    # 本地预览
mkdocs build    # 构建
```

---

## mkdocs.yml 配置详解

所有站点行为、外观、导航、插件均由根目录下的 `mkdocs.yml` 控制。以下逐段说明其配置方法与含义。

---

### 1. 站点基本信息

```yaml
site_name: DUT Drone Development Guide       # 站点名称，显示在浏览器标题栏和导航栏
site_url: https://drone-dev.qsq.cool          # 生产环境域名，用于生成 sitemap、canonical URL
site_description: DUT Drone Development Guide # SEO 描述
site_author: DUT Aeromodelling Association - Shengqiao Qu  # 作者元信息
```

**自定义方法**：直接修改对应的字段值即可。

---

### 2. 仓库与编辑链接

```yaml
repo_url: https://github.com/SIANQSQ/Drone_Task_Controller.git  # 文档源码仓库地址
repo_name: GitHub          # 导航栏显示的仓库名称
edit_uri: blob/main/docs/  # 点击页面「编辑」按钮跳转的路径
```

- `edit_uri` 拼接规则：`repo_url` + `/` + `edit_uri` + 当前文件相对 `docs_dir` 的路径。
- 如果不需要显示编辑链接，可删除或留空 `repo_url`。

---

### 3. 主题配置 (Material for MkDocs)

```yaml
theme:
  name: material       # 使用 Material 主题（必须安装 mkdocs-material）
  custom_dir: overrides # 自定义模板覆盖目录，可覆写主题默认 HTML 块
  language: zh          # 界面语言（中文）
```

#### 3.1 颜色方案 (palette)

```yaml
  palette:
    - scheme: slate     # 深色模式（默认）；可选 default（浅色）
      primary: indigo   # 主色调，可选 red/pink/blue/indigo/teal 等
      accent: indigo    # 强调色，用于链接、按钮等
```

如果需要同时支持浅色和深色切换，可以写两个 palette 条目：

```yaml
  palette:
    - scheme: default
      toggle:
        icon: material/weather-sunny
        name: 浅色模式
    - scheme: slate
      toggle:
        icon: material/weather-night
        name: 深色模式
```

#### 3.2 字体设置

```yaml
  font:
    text: Roboto        # 正文字体（Google Font）
    code: Roboto Mono   # 代码字体
```

#### 3.3 界面功能 (features)

```yaml
  features:
    - navigation.tabs           # 顶部导航标签页
    - navigation.tabs.sticky    # 标签栏粘性固定（滚动时始终可见）
    - navigation.expand         # 侧边栏默认展开所有子目录
    - navigation.indexes        # 目录首页（section index page）可点击跳转
    - navigation.top            # 返回顶部按钮
    - search.highlight          # 搜索结果高亮匹配文本
    - search.share              # 分享搜索结果链接
    - search.suggest            # 搜索建议/自动补全
    - header.autohide           # 滚动时自动隐藏顶部导航栏
    - toc.follow                # 侧边栏目录跟随当前滚动位置
    - content.tabs.link         # 内容选项卡（tab）链接化
    - content.code.annotate     # 代码块内注释标注
    - content.code.copy         # 代码块复制按钮
    - content.tooltips          # 缩写/术语提示框
```

> 完整 feature 列表参考：[Material 官方文档 - Features](https://squidfunk.github.io/mkdocs-material/setup/setting-up-navigation/)

#### 3.4 图标与 Logo

```yaml
  icon:
    repo: fontawesome/brands/github  # 仓库图标
  logo: assets/logo.svg              # 导航栏 logo 路径（相对于 docs_dir）
  favicon: favicon.ico               # 网站图标路径（相对于 docs_dir）
```

- `icon.repo` 使用 FontAwesome 图标 ID，格式为 `fontawesome/<style>/<name>`。

---

### 4. 导航结构 (nav)

导航定义了左侧（或顶部）菜单的层级结构，**是维护文档时最常修改的部分**。

```yaml
nav:
  - 首页: index.md
  - 快速开始:
    - 环境部署: quickly_start/environment.md
    - 仿真: quickly_start/simulation.md
  - 硬件配置:
    - 无人机飞控硬件:
      - CUAV X25 EVO: hardware/flight_controller/cuav-x25-evo.md
```

**语法规则**：

| 写法 | 含义 |
|------|------|
| `- 标题: path/to/file.md` | 菜单项，点击跳转到对应 Markdown 文件 |
| `- 标题:`（无文件路径） | 纯分类标题，仅作分组，不可点击 |
| `- 标题: path/index.md` | 子目录索引页（需启用 `navigation.indexes` feature） |

**添加新页面步骤**：
1. 在 `docs/` 下创建 `.md` 文件
2. 在 `nav` 中找到合适的位置，按层级添加菜单条目
3. 重新运行 `mkdocs serve` 预览

**多级嵌套**：通过缩进实现任意层级（建议不超过 3 级，否则影响可读性）。

---

### 5. 插件配置 (plugins)

```yaml
plugins:
  - search:
      lang: zh       # 搜索分词语言（中文分词语义搜索）
  - i18n:
      default_language: zh
      languages:
        zh: 中文
        en: English   # 国际化：支持中/英双语
```

**添加新插件**：
1. `pip install <plugin-name>`
2. 在 `plugins` 下添加条目，部分插件可配置参数：

```yaml
plugins:
  - search
  - blog          # 添加博客功能（需安装 mkdocs-material 内置插件）
  - tags          # 标签功能
```

> 注意：`search` 插件必须放在最前面以保证构建正确。

---

### 6. 静态资源引入

```yaml
extra_css:
  - stylesheets/extra.css   # 自定义全局样式，路径相对于 docs_dir

extra_javascript:
  - javascripts/extra.js    # 自定义全局脚本
```

如果需要引入外部 CDN 资源，直接写完整 URL：

```yaml
extra_javascript:
  - https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js
```

---

### 7. 额外配置 (extra)

```yaml
extra:
  generator: false    # 隐藏页面底部的 "Made with Material for MkDocs" 字样
  social:             # 社交链接（显示在版权区域）
    - icon: fontawesome/brands/github
      link: https://github.com/SIANQSQ/Drone_Task_Controller.git
  copyright: Copyright &copy; 2026 DUT Aeromodelling Association - Shengqiao Qu
  analytics:          # Google Analytics
    provider: google
    property: G-XXXXXXXXXX   # 替换为实际跟踪 ID
```

---

### 8. 构建与预览设置

```yaml
docs_dir: docs              # Markdown 源文件目录
site_dir: site              # 构建产物输出目录
dev_addr: 127.0.0.1:8000    # mkdocs serve 监听地址
strict: false               # 严格模式：如果为 true，构建时任何警告都会导致失败
use_directory_urls: true    # 生成 /path/ 风格 URL，而非 /path.html
```

---

### 9. Markdown 扩展配置

Material 主题默认启用了一组 Markdown 扩展，提供更丰富的写作能力：

```yaml
markdown_extensions:
  - toc:
      permalink: true       # 标题旁生成永久链接锚点
  - tables                  # 表格支持
  - fenced_code             # 代码块（```）
  - footnotes               # 脚注 [^1]
  - attr_list               # 属性列表（为元素添加 class/id）
  - md_in_html              # HTML 内嵌 Markdown
  - def_list                # 定义列表
  - admonition              # 提示框（!!! note / ??? info 等）
  - pymdownx.details        # 可折叠面板
  - pymdownx.superfences:   # 高级代码块（支持嵌套、行号）
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format
  - pymdownx.highlight:     # 代码高亮
      anchor_linenums: true
      line_spans: __span
      pygments_lang_class: true
  - pymdownx.inlinehilite   # 行内代码高亮
  - pymdownx.snippets       # 引用外部文件片段
  - pymdownx.tabbed:        # 内容选项卡（tab）
      alternate_style: true
  - pymdownx.tasklist:      # 任务列表（checkbox）
      custom_checkbox: true
  - pymdownx.emoji:         # Emoji 支持
      emoji_index: !!python/name:material.extensions.emoji.twemoji
      emoji_generator: !!python/name:material.extensions.emoji.to_svg
```

**常用扩展速查**：

| 扩展 | 用法示例 |
|------|----------|
| `admonition` | `!!! note "标题"` 或 `??? info "可折叠"` |
| `pymdownx.tabbed` | `=== "标签1"` / `=== "标签2"` |
| `pymdownx.tasklist` | `- [ ] 未完成` / `- [x] 已完成` |
| `pymdownx.superfences` | ` ```mermaid ` 渲染流程图 |
| `pymdownx.emoji` | `:smile:` `:rocket:` |
| `attr_list` | `{: .custom-class }` 自定义 CSS class |

---

## 部署

### GitHub Pages

运行 `gh-deploy.bat` 或：

```bash
mkdocs gh-deploy
```

该命令会自动构建并推送到 `gh-pages` 分支。

### 自定义服务器

将 `site/` 目录内容部署到任意静态服务（Nginx、Apache、Vercel 等）即可。

---

## 项目结构

```
.
├── mkdocs.yml          # 核心配置文件
├── readme.md           # 本说明文件
├── build.bat           # 构建脚本
├── preview.bat         # 本地预览脚本
├── gh-deploy.bat       # GitHub Pages 部署脚本
├── docs/               # 文档源文件（Markdown）
│   ├── index.md        # 首页
│   ├── start.md
│   ├── quickly_start/  # 快速开始
│   ├── hardware/       # 硬件配置
│   ├── jetson/         # 机载计算机配置
│   ├── software/       # 软件功能包
│   ├── mechanical/     # 机械结构
│   ├── assets/         # 图片等静态资源
│   ├── stylesheets/    # 自定义 CSS
│   └── javascripts/    # 自定义 JS
├── overrides/          # 主题模板覆盖
└── site/               # 构建产物（build 后生成，已 gitignore）
```

---

## 参考链接

- [MkDocs 官方文档](https://www.mkdocs.org/)
- [Material for MkDocs 官方文档](https://squidfunk.github.io/mkdocs-material/)
- [Material 主题配置参考](https://squidfunk.github.io/mkdocs-material/setup/)