import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

// Astro 5 的 Content Collections：文章放在 src/content/posts/ 下
const posts = defineCollection({
  loader: glob({
    pattern: '**/*.md',
    base: './src/content/posts',
    // 默认 id 会带上 .md 后缀，这里去掉，URL 才是 /posts/hello-world/
    generateId: ({ entry }) => entry.replace(/\.(md|mdx)$/, ''),
  }),
  schema: z.object({
    title: z.string(),
    description: z.string().default(''),
    pubDate: z.coerce.date(),
    tags: z.array(z.string()).default([]),
    draft: z.boolean().default(false),
  }),
});

export const collections = { posts };
