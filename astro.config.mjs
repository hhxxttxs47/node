// @ts-check
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

// 站点部署在 orkestr 上：https://node.orkestr.run
// 如果之后绑定自定义域名，改这里的 site 即可（sitemap / RSS 会跟着变）。
export default defineConfig({
  site: 'https://node.orkestr.run',
  integrations: [sitemap()],
  markdown: {
    // 中文排版：代码块、引用块都保持默认即可，这里只开语法高亮主题
    shikiConfig: {
      theme: 'github-dark',
      wrap: true,
    },
  },
});
