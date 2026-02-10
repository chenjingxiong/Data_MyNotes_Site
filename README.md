# Data My Notes Site

基于 [VitePress](https://vitepress.dev/) + [VitePress Theme Teek](https://github.com/Kele-Bingtang/vitepress-theme-teek) 的个人笔记网站。

## 特性

- VitePress Theme Teek 主题
- Git Submodule 内容管理
- 自动部署到 GitHub Pages 和 OpenResty

## 快速开始

```bash
# 安装依赖
pnpm install

# 启动开发服务器
pnpm run docs:dev

# 构建
pnpm run docs:build
```

## 部署

- **GitHub Pages**: 推送到 `main` 分支自动部署
- **OpenResty**: 推送到 `main` 分支自动部署

详细配置见 [DEPLOYMENT.md](DEPLOYMENT.md)

## 项目结构

```
.
├── .vitepress/     # VitePress 配置
├── docs/           # 内容 (Submodule)
├── scripts/        # 部署脚本
└── index.md        # 首页
```

## 链接

- [在线预览](https://chenjingxiong.github.io/Data_MyNotes_Site/)
- [内容仓库](https://github.com/chenjingxiong/Data_MyNotes)
