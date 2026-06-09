import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';
import sitemap from '@astrojs/sitemap';

// Base path resolution:
//   - PR_PREVIEW_BASE overrides everything (website-preview.yml sets it to
//     /sherod-portfolio-v2/pr-preview/pr-<N>/ on github.io, or
//     /pr-preview/pr-<N>/ after DNS cutover to sherodtaylor.dev).
//   - SITE_BASE is the production fallback (website.yml on main).
//     Defaults to "/sherod-portfolio-v2" while we're served from
//     sherodtaylor.github.io/sherod-portfolio-v2/; flip to "/" when DNS
//     cuts over to sherodtaylor.dev.
//   - Local dev defaults to "/" so `bun run dev` serves cleanly at root.
//
// Trailing slash is normalized off; Astro accepts either form.
const rawBase = process.env.PR_PREVIEW_BASE ?? process.env.SITE_BASE ?? '/';
const base = rawBase.replace(/\/$/, '') || '/';

export default defineConfig({
  site: 'https://sherodtaylor.dev',
  base,
  trailingSlash: 'never',
  output: 'static',
  integrations: [mdx(), sitemap()],
});
