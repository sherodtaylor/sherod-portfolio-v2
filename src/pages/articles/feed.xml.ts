import type { APIRoute } from 'astro';
import { getCollection } from 'astro:content';
import { loadConfig } from '../../lib/config';

// RSS 2.0 feed for the writing list. Claude, Perplexity, and ChatGPT all
// consume RSS for "what has X written lately" — keeping a feed at a stable
// URL keeps the site discoverable by summarizers.
//
// Hand-rolled instead of pulling @astrojs/rss because the feed is small and
// the extra dep buys us nothing — five lines of XML do the job.

export const GET: APIRoute = async ({ site }) => {
  const config = loadConfig();
  const articles = (await getCollection('articles'))
    .sort((a, b) => b.data.date.valueOf() - a.data.date.valueOf());

  const baseUrl = site?.toString().replace(/\/$/, '') ?? 'https://sherodtaylor.dev';

  const escapeXml = (s: string) =>
    s
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&apos;');

  const items = articles
    .map((a) => {
      const url = `${baseUrl}/articles/${a.slug}`;
      return `
    <item>
      <title>${escapeXml(a.data.title)}</title>
      <link>${url}</link>
      <guid isPermaLink="true">${url}</guid>
      <pubDate>${a.data.date.toUTCString()}</pubDate>
      <description>${escapeXml(a.data.description)}</description>
    </item>`;
    })
    .join('');

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>${escapeXml(config.personal.name)} — Writing</title>
    <link>${baseUrl}</link>
    <atom:link href="${baseUrl}/articles/feed.xml" rel="self" type="application/rss+xml" />
    <description>Engineering writing from ${escapeXml(config.personal.name)}.</description>
    <language>en</language>${items}
  </channel>
</rss>
`;

  return new Response(xml, {
    headers: { 'Content-Type': 'application/rss+xml; charset=utf-8' },
  });
};
