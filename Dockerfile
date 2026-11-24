# 纯静态 Astro 站：构建后用 nginx 提供 dist/
# 用自建 Dockerfile 而不是 orkestr 自动模板，因为自动模板假设 SSR（dist/server/entry.mjs），
# 而本站 output: static，产物是纯 HTML。

# ---------- 构建 ----------
FROM node:22-slim AS build
WORKDIR /app

# 先只拷贝依赖清单，命中缓存时跳过重复安装
COPY package.json package-lock.json ./
RUN npm ci --no-audit --no-fund

# 再拷贝源码并构建
COPY . .
RUN npm run build

# ---------- 运行时 ----------
FROM nginx:1.27-alpine
# 替换默认站点配置：静态文件 + 干净 URL + 长缓存
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget -qO- http://127.0.0.1/ > /dev/null || exit 1

CMD ["nginx", "-g", "daemon off;"]
