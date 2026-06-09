import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';
import sitemap from '@astrojs/sitemap';

// PR_PREVIEW_BASE is set by .github/workflows/website-preview.yml so per-PR
// builds resolve their assets under /<repo>/pr-preview/pr-<N>/. The umbrella
// "pr-preview" segment is non-negotiable — rossjrw/pr-preview-action publishes
// there and the rendered HTML must match. Trailing slash is normalized off
// because Astro accepts either form.
const base = (process.env.PR_PREVIEW_BASE ?? '/').replace(/\/$/, '') || '/';

export default defineConfig({
  site: 'https://sherodtaylor.dev',
  base,
  trailingSlash: 'never',
  output: 'static',
  integrations: [mdx(), sitemap()],
});
