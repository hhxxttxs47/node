# 纯静态 Astro 站：构建后用 nginx 提供 dist/
# 用自建 Dockerfile 而不是 orkestr 自动模板，因为自动模板假设 SSR（dist/server/entry.mjs），
# 而本站 output: static，产物是纯 HTML。
#
# 注意：orkestr 以非 root 用户运行容器，nginx 官方镜像默认要 chown /var/cache/nginx，
# 会报 "Operation not permitted"。这里改用 nginxinc/nginx-unprivileged（默认 101 端口、
# 非 root 启动），并把所有临时路径指到 /tmp。

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

# 非 root 用户需要自己写临时目录
USER root
RUN mkdir -p /tmp/nginx-client /tmp/nginx-proxy /tmp/nginx-fastcgi \
            /tmp/nginx-uwsgi /tmp/nginx-scgi \
 && chown -R 101:101 /tmp/nginx-* /usr/share/nginx/html

# 替换默认站点配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY --from=build /app/dist /usr/share/nginx/html

USER 101

# 非 root 镜像默认监听 8080
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget -qO- http://127.0.0.1:8080/ > /dev/null || exit 1

CMD ["nginx", "-g", "daemon off;"]
