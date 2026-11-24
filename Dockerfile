# 纯静态 Astro 站：构建后用 nginx 提供 dist/
#
# 两个关键点（都踩过坑）：
# 1. orkestr 自动生成的 Astro 模板假设 SSR（要 dist/server/entry.mjs），
#    本站 output: static，产物是纯 HTML，所以自带 Dockerfile。
# 2. orkestr 以非 root 运行容器，官方 nginx 镜像 chown /var/cache/nginx 会
#    Operation not permitted，所以用 nginxinc/nginx-unprivileged（监听 8080）。

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
FROM nginxinc/nginx-unprivileged:1.27-alpine

# 只放 server{} 块；主配置的 pid / 临时路径镜像已配好
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget -qO- http://127.0.0.1:8080/ > /dev/null || exit 1

CMD ["nginx", "-g", "daemon off;"]
