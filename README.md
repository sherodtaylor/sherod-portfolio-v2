# sherod-portfolio-v2

Source for [sherodtaylor.dev](https://sherodtaylor.dev). v2 — full replacement of
[`sherodtaylor/portfolio-and-digital-garden`](https://github.com/sherodtaylor/portfolio-and-digital-garden).

## What this is

Static site (Astro) + shared LaTeX resume pipeline. One content source
(`config.yaml`), two surfaces (website + PDF). Brand DNA in
[`SOUL.md`](SOUL.md); PRD + vision + roadmap in
[`sherodtaylor/homelab/docs/product/personal/`](https://github.com/sherodtaylor/homelab/tree/main/docs/product/personal).

## Dev

```bash
bun install
bun run dev        # http://localhost:4321
bun run build      # dist/
```

Resume PDF:

```bash
make setup         # one-time (PyYAML venv)
make               # public/resume.pdf
```

Requires `xelatex` + FiraCode Nerd Font Mono for the resume build. Site
build only needs Node 20+/Bun.

## Release

[`docs/runbooks/release.md`](docs/runbooks/release.md) — PR → main → tag flow,
first-time Pages setup, troubleshooting.

## Layout

```
.
├── SOUL.md                       # brand DNA (governs everything below)
├── config.yaml                   # content source (website + PDF resume)
├── resume-template.tex           # LaTeX template (SOUL.md-aligned)
├── generate-resume.py            # YAML → LaTeX
├── Makefile                      # resume build pipeline
├── astro.config.mjs              # Astro config (base + integrations)
├── src/
│   ├── content/                  # /now + articles content collections
│   ├── layouts/BaseLayout.astro  # head, theme bootstrap, JSON-LD
│   ├── components/Header,Footer  # SOUL.md-aligned chrome
│   ├── pages/                    # index, now, archive, [slug] articles
│   ├── lib/config.ts             # YAML loader
│   └── styles/tokens.css,global.css
├── public/
│   ├── llms.txt                  # AI-readable summary
│   ├── robots.txt                # AI crawlers welcome
│   └── favicon.svg
├── docs/runbooks/release.md
└── .github/workflows/
    ├── website.yml               # main deploy
    ├── website-preview.yml       # per-PR canary
    └── resume.yml                # PDF build + commit
```
