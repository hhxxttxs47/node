// 全局站点配置：想改标题、简介、社交链接，只改这一个文件。
export const SITE = {
  title: 'aoke26',
  description: '一个用 Astro 写的极简中文博客，部署在 EU 托管的 orkestr 上。',
  author: 'aoke26',
  lang: 'zh-CN',
};

export type PostMeta = {
  slug: string;
  title: string;
  description: string;
  pubDate: Date;
  tags: string[];
  minutes: number;
};

// 中文按字数、英文按词数粗算，220 字/分钟；没有正文时给个下限
export function readingMinutes(body = ''): number {
  const cjk = (body.match(/[\u4e00-\u9fa5]/g) ?? []).length;
  const words = body.replace(/[\u4e00-\u9fa5]/g, ' ').split(/\s+/).filter(Boolean).length;
  return Math.max(1, Math.round(cjk / 220 + words / 200));
}

export function formatDate(d: Date): string {
  return new Intl.DateTimeFormat('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    timeZone: 'Asia/Shanghai',
  })
    .format(d)
    .replace(/\//g, '-');
}
