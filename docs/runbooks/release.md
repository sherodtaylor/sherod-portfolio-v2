# Runbook: Release the portfolio + resume

This site (sherodtaylor.dev) is fully governed by:

- **Brand DNA**: [`SOUL.md`](../../SOUL.md) at repo root. Source of truth for voice, visual, structure.
- **PRD**: [`sherodtaylor/homelab` `docs/product/personal/prds/2026-06-09-sherodtaylor-dev-v2.md`](https://github.com/sherodtaylor/homelab/tree/main/docs/product/personal/prds).
- **Vision + roadmap**: [`sherodtaylor/homelab` `docs/product/personal/`](https://github.com/sherodtaylor/homelab/tree/main/docs/product/personal).

If a change drifts from `SOUL.md`, the change is wrong; either fix the change or open a SOUL.md edit PR first with Sherod's ✅.

## What counts as "any change"

If a PR touches **any** of these files, CI regenerates the resume PDF and (on
main) commits the updated artifact back:

- `config.yaml` — source of truth for content (shared with the website).
- `generate-resume.py` — the YAML → LaTeX renderer.
- `resume-template.tex` — the LaTeX template the renderer fills.
- `Makefile` — the build pipeline (xelatex, font checks).
- `.github/workflows/resume.yml` — the CI definition itself.

Site-source-only changes (`src/**`, `astro.config.mjs`, etc.) trigger the
website deploy (`website.yml`) without rebuilding the PDF.

## Standard flow — PR to main

1. **Branch off main**: `git checkout -b feat/<slug>` or `fix/<slug>`.
2. **Edit `config.yaml`** (or component files). One concern per PR.
3. **(Optional) regenerate locally** to preview:
   ```bash
   make             # generate-resume.py → xelatex → public/resume.pdf
   bun run dev      # site preview at http://localhost:4321
   ```
   `make` requires `xelatex` and FiraCode Nerd Font Mono. If you don't have
   them, skip — CI builds the PDF for you.
4. **Open the PR**. Three workflows trigger:
   - `website-preview.yml` — publishes a per-PR canary at
     `https://sherodtaylor.dev/pr-preview/pr-<N>/`. Includes a 5-minute
     reachability check that fails the job if Pages doesn't serve.
   - `resume.yml` (if you touched resume sources) — builds the PDF and
     uploads it as a workflow artifact.
   - Lighthouse / type-check (added later if needed).
5. **Review** — pull the preview URL; verify SOUL.md alignment (no images,
   no motion, no decoration creep).
6. **Merge to main**. `website.yml` deploys the site; `resume.yml`
   auto-commits the regenerated PDF if `config.yaml` changed.
7. **Production check**: hit `https://sherodtaylor.dev/?cb=$(date +%s)` to
   confirm the new content is live. The end-of-deploy reachability check
   in CI already gates this, so if the workflow goes green the URL is live.

## First-time Pages setup

The deploy workflows use `peaceiris/actions-gh-pages` writing to a
`gh-pages` branch. **Repo Settings → Pages must read from that branch** or
deploys silently no-op:

- **Source = Deploy from a branch**
- **Branch = `gh-pages` / `/` (root)**

If the live URL doesn't update after a successful workflow run, check
`gh api repos/sherodtaylor/sherod-portfolio-v2/pages` — if `build_type` is
`workflow`, the config is wrong. Fix via API:

```bash
curl -X PUT \
  -H "Authorization: token $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/sherodtaylor/sherod-portfolio-v2/pages \
  -d '{"build_type":"legacy","source":{"branch":"gh-pages","path":"/"}}'
curl -X POST \
  -H "Authorization: token $GH_TOKEN" \
  https://api.github.com/repos/sherodtaylor/sherod-portfolio-v2/pages/builds
```

This is the same Pages-mode trap that hit `sherodtaylor/agent-smith` — see
that repo's `docs/runbooks/website-deploy.md` for the lesson.

## Manual rebuild

```bash
make setup      # one-time: PyYAML venv
make            # public/resume.pdf
bun install
bun run build   # dist/
```

LaTeX install: macOS via MacTeX (`brew install --cask mactex-no-gui`); Linux
via `apt-get install texlive-xetex texlive-fonts-extra texlive-latex-extra`.
FiraCode Nerd Font Mono from
[ryanoasis/nerd-fonts](https://github.com/ryanoasis/nerd-fonts/releases),
then `fc-cache -f`.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Deploy workflow green but live URL stale | Pages source not set to `gh-pages` branch | API recipe above. |
| `Could not resolve ../../data/X.json` during build | A content file is gitignored but imported | Add a refresh step before build, or remove the import. |
| Preview ships unstyled | `PR_PREVIEW_BASE` doesn't include the `pr-preview/` umbrella prefix | Already handled in `website-preview.yml`; if the workflow is edited, preserve the umbrella prefix or every asset 404s. |
| PR's lighthouse step (if added later) fails LCP | New asset blew the budget | Trim before tightening; don't ratchet the budget silently. |
| Live URL renders but no styles | A CSS import broke, or the Astro `base` is misconfigured | Check `astro.config.mjs` `base` against the Pages serve path. |
| `xelatex` complains about missing font | FiraCode Nerd Font Mono not installed | Install from Nerd Fonts releases + `fc-cache -fv`. |
