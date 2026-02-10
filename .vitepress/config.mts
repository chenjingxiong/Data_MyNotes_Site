// .vitepress/config.mts
import { defineConfig } from "vitepress";
import { defineTeekConfig } from "vitepress-theme-teek/config";

// Teek 主题配置
const teekConfig = defineTeekConfig({
  // 网站基本信息
  title: "我的笔记",
  description: "基于 VitePress Theme Teek 的个人笔记网站",

  // 作者信息
  author: {
    name: "Your Name",
    avatar: "/avatar.jpg",
    link: "https://github.com/chenjingxiong"
  },

  // 导航栏配置
  nav: [
    { text: "首页", link: "/" },
    { text: "笔记", link: "/notes/" },
    { text: "归档", link: "/archive/" },
  ],

  // 侧边栏配置
  sidebar: {
    "/notes/": [
      {
        text: "笔记目录",
        items: [
          { text: "介绍", link: "/notes/index.md" },
        ]
      }
    ]
  },

  // 社交链接
  social: [
    { icon: "github", link: "https://github.com/chenjingxiong" }
  ],

  // 其他配置
  footer: {
    message: "Powered by VitePress & Teek",
    copyright: "Copyright © 2025"
  }
});

// VitePress 配置
export default defineConfig({
  extends: teekConfig,

  // 网站标题
  title: "我的笔记",
  description: "基于 VitePress Theme Teek 的个人笔记网站",

  // 语言
  lang: "zh-CN",

  // 主题配置
  themeConfig: {
    // 最后更新时间
    lastUpdated: true,
    // 贡献者
    contributors: true,
  },

  // Markdown 配置
  markdown: {
    // 行号
    lineNumbers: true,
  },

  // 构建配置
  vite: {
    // 别名配置
    resolve: {
      alias: {
        "@": "/docs"
      }
    }
  }
});
