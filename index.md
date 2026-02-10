---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "我的笔记"
  text: "基于 VitePress Theme Teek 的个人笔记网站"
  tagline: "记录学习、分享知识"
  actions:
    - theme: brand
      text: 开始阅读
      link: /notes/
    - theme: alt
      text: GitHub
      link: https://github.com/chenjingxiong/Data_MyNotes

features:
  - title: "VitePress Theme Teek"
    details: "使用轻量、简洁高效的 Teek 主题构建"
  - title: "Git Submodule"
    details: "内容通过 Git Submodule 从独立仓库管理"
  - title: "Markdown 支持"
    details: "原生支持 Markdown 语法和扩展"
  - title: "快速构建"
    details: "基于 Vite 构建，享受极速的开发体验"
---

## 欢迎来到我的笔记网站

这是一个使用 [VitePress](https://vitepress.dev/) 和 [VitePress Theme Teek](https://github.com/Kele-Bingtang/vitepress-theme-teek) 构建的个人笔记网站。

### 主要特性

- **Teek 主题**：轻量、简洁高效、灵活配置、易于扩展
- **Git Submodule**：内容仓库独立管理，便于维护
- **Markdown 原生支持**：使用 Markdown 编写，简单直观
- **搜索功能**：内置全文搜索功能
- **响应式设计**：完美适配各种设备

### 开始使用

1. 克隆本仓库并初始化 submodule：
   ```bash
   git clone --recurse-submodules <repository-url>
   ```

2. 安装依赖：
   ```bash
   npm install
   ```

3. 启动开发服务器：
   ```bash
   npm run docs:dev
   ```

4. 构建生产版本：
   ```bash
   npm run docs:build
   ```

### 项目结构

```
.
├── .vitepress/          # VitePress 配置目录
│   ├── config.mts      # 网站配置文件
│   └── theme/          # 主题目录
│       └── index.ts    # 主题入口文件
├── docs/               # 内容目录（Git Submodule）
├── index.md           # 首页
└── package.json       # 项目配置
```

### 链接

- [VitePress 官方文档](https://vitepress.dev/)
- [Teek 主题文档](https://teek.w3c.cool/)
- [内容仓库](https://github.com/chenjingxiong/Data_MyNotes)
