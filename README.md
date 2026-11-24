# aoke26 blog

一个用 Astro 5 写的极简中文静态博客，部署在 [orkestr](https://orkestr.eu)（欧盟托管）。

线上：https://aoke26-blog.orkestr.run

## 本地开发

```bash
npm install
npm run dev      # http://localhost:4321
npm run build    # 产物在 dist/
npm run preview  # 预览构建结果
```

## 写文章

在 `src/content/posts/` 新建 `.md` 文件，frontmatter 支持：

```yaml
---
title: 标题
description: 一句话摘要（用于列表和 RSS）
pubDate: 2026-01-15
tags: ['随笔']
draft: false      # true 时只在 dev 环境显示
---
```

文件名即 URL：`hello-world.md` → `/posts/hello-world/`。

## 改站点信息

标题、简介、作者在 `src/config.ts` 的 `SITE` 里改。

## 结构

```
src/
  config.ts              站点配置 + 日期/阅读时长工具
  content.config.ts      文章集合 schema
  content/posts/*.md     文章
  layouts/Base.astro     全局布局（head、导航、页脚）
  pages/
    index.astro          首页列表
    posts/[slug].astro   文章详情
    about.astro          关于
    404.astro            404
    rss.xml.ts           RSS
  styles/global.css      全部样式（明暗双主题）
Dockerfile               node 构建 -> nginx 提供静态文件
nginx.conf               server 块（干净 URL、gzip、缓存、安全头）
```

## 部署说明

orkestr 自动生成的 Astro 模板假设 SSR（要 `dist/server/entry.mjs`），
本站是 `output: static`，所以自带 Dockerfile：

1. `node:22-slim` 里 `npm ci && npm run build`
2. 把 `dist/` 拷进 `nginxinc/nginx-unprivileged`（orkestr 以非 root 跑容器）
3. 监听 8080

`nginx.conf` 被 include 在 `http{}` 内部，所以只能写 `server{}` 块。
`try_files` 里不要用 `$uri/`——目录内部重定向经边缘代理会 502。
