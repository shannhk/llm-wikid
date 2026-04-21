# LLM Knowledge Base - Schema

## Overview

Personal knowledge base maintained by an LLM agent.
Raw sources live in `raw/`. The compiled wiki lives in `wiki/`.
You (the AI) maintain all wiki content. The user directs strategy and source
collection; you execute compilation, maintenance, and queries.

This is NOT RAG. Knowledge is pre-compiled into wiki pages. The agent reads
structured pages, not raw chunks. Every query compounds the system.

## Directory Structure

### Wiki

- `wiki/index.md` - Master index linking every page with TLDR for fast scanning
- `wiki/log.md` - Append-only changelog of all operations
- `wiki/concepts/` - Concept pages (ideas, frameworks, topics)
- `wiki/entities/` - Entity pages (people, companies, tools, protocols)
- `wiki/sources/` - Source summary pages (one per raw source)
- `wiki/syntheses/` - Cross-cutting analysis across sources
- `wiki/outputs/` - Filed answers to queries
- `wiki/sops/` - Repeatable processes and workflows
- `templates/` - Starter templates per page type (for Obsidian Templater)

### Raw

- `raw/ideas/` - Idea notes and brainstorms
- `raw/bookmarks/` - Bookmarked tweet and article sources
- `raw/x-archive/` - X archive tweets (exported from X/Twitter)
- `raw/clippings/` - Obsidian Web Clipper inbox. Everything lands here. During INGEST, files get sorted to the correct subfolder and removed from clippings.
- `raw/articles/` - Long-form articles and blog posts (sorted from clippings)
- `raw/papers/` - Research papers and PDFs (sorted from clippings)
- `raw/assets/` - Images, videos, and other media

New wiki pages go in the subfolder matching their `type` frontmatter field. Wikilinks use filename only (Obsidian resolves via shortest-path setting).

## Frontmatter Schema

Every wiki page MUST have YAML frontmatter:

```yaml
---
title: "Page Title"
tldr: "One to two sentence TLDR - used for index scanning to save tokens"
date_created: YYYY-MM-DD
date_modified: YYYY-MM-DD
type: concept | entity | source | project | sop | synthesis | output
tags: [topic-tag, another-tag]
sources: ["[[source-page]]"]
original_url: "https://..." # For source pages - link to the original content
explored: false # Validation gate. Only a human sets this to true. AI always sets false.
confidence: high | medium | low | uncertain # How confident is the content? Be honest.
---
```

### Validation Gate

`explored` defaults to **false** on every AI-created or AI-updated page. Only the user can set it to `true` after reviewing the content. This prevents blind trust in AI-generated knowledge. The agent must never set `explored: true`.

`confidence` signals how well-supported the content is:
- **high** - multiple corroborating sources, well-established topic
- **medium** - single source or limited evidence, reasonable synthesis
- **low** - speculative, early-stage idea, thin evidence
- **uncertain** - contradictory sources or insufficient information

## Page Types

| Type | What it is |
|------|-----------|
| concept | An idea, framework, or topic |
| entity | Person, company, tool, protocol |
| source | Summary of one raw source |
| project | Active project with goals and context |
| sop | Repeatable process or workflow |
| synthesis | Cross-cutting analysis across sources |
| output | Filed answer to a query |

## Source Resolution (Resolve Before Classify)

`raw/` is a messy inbox. Before classification, INGEST must resolve each input to its full content using the right tool.

### Resolution Tool Mapping

| Input Pattern | Tool | What It Extracts |
|--------------|------|-----------------|
| YouTube URL (youtube.com, youtu.be) | `yt-dlp` | Transcript (auto-subs), title, description, metadata |
| X/Twitter URL (x.com, twitter.com) | X API (OAuth) | Tweet text, thread, author, metrics. If video/image attached, also `yt-dlp` for video and download images |
| Web URL / Reddit URL | `scrapling` | Page content, title, author, date |
| PDF file (.pdf) | Read directly / `summarize` CLI | Full text extraction |
| Bookmark dump (list of URLs) | Parse each URL, resolve individually | One resolved file per URL |
| Plain text / notes / ideas | Read as-is | No resolution needed |

### Media Extraction

Every source with attached media MUST have that media downloaded and analyzed:

**Images:**
- Download to `raw/assets/images/` with descriptive kebab-case names
- Analyze the image content (diagrams, screenshots, infographics, memes, charts)
- Include analysis in the source summary: what the image shows, key data points, visual format
- Reference in the raw file frontmatter: `media: ["raw/assets/images/filename.png"]`
- Embed in wiki source pages: `![[raw/assets/images/filename.png]]`

**Videos:**
- Extract transcript via `yt-dlp --write-auto-sub --skip-download`
- Download thumbnail to `raw/assets/images/`
- If short video (under 2 min), describe the visual content in the source summary
- Reference in raw file frontmatter: `media_transcript: "raw/assets/filename-transcript.txt"`

Images often contain the actual information (diagrams, frameworks, data). A tweet saying "here's my framework" with an image of the framework is useless without the image. The wiki must capture the visual knowledge, not just the text.

Resolution updates the file in `raw/` in-place, preserving the original URL in frontmatter:

```markdown
---
original_url: https://example.com/article
fetched: YYYY-MM-DD
source_tool: scrapling
---

[Full fetched content here]
```

### Tool Dependencies

| Tool | Install | Auth |
|------|---------|------|
| `yt-dlp` | `brew install yt-dlp` | None |
| `scrapling` | `pipx install scrapling` | None |
| X API | Official API (OAuth 2.0) | Bearer token + client credentials in `.env` (optional) |
| `summarize` (optional) | `brew install steipete/tap/summarize` | None |

## Source Classification (Classify After Resolution)

After resolution, classify the content and extract accordingly:

| Source Type | Extraction Focus |
|------------|-----------------|
| **Transcript** (YouTube, meeting) | Speaker attribution, decisions made, action items, key quotes |
| **Paper/Research** | Method, findings, limitations, how it connects to existing knowledge |
| **Report** | Executive summary first, key metrics, recommendations |
| **Article/Blog** | Core thesis, supporting arguments, author's perspective |
| **Tweet/Thread** | Core claim, context, engagement signals, author credibility |
| **Reddit thread** | Original post thesis, top arguments for/against, consensus vs outliers |
| **Notes/Ideas** | Key ideas, questions raised, connections to other topics |

Generic extraction misses what makes each format valuable.

## Bias Check

Every concept, synthesis, and source page MUST include:

```markdown
## Counter-arguments
[What pushes back against the claims on this page]

## Data gaps
[What we don't know, what's missing, what needs more sources]
```

**Inline contradictions** (when two sources conflict inside a page body) MUST use Obsidian callout syntax:

```markdown
> [!contradiction] Source A vs Source B
> [[source-a]] claims X, but [[source-b]] claims Y.
> Resolution: {stated position, or "unresolved - flagged for review"}.
```

Use `[!contradiction]` callouts instead of prose like "however, some argue..." - callouts render as visually distinct blocks in Obsidian and are scannable at a glance. This prevents the wiki from becoming an echo chamber and makes conflicts explicit.

## Operations

### INGEST

1. Scan `raw/` for files not yet summarized in `wiki/`
2. **RESOLVE**: For each unprocessed file, detect if it contains a URL or unresolved reference. Fetch full content using the right tool and update the file in-place, preserving the original URL in frontmatter.
3. Classify each source by type (transcript, paper, report, article, tweet, reddit, notes)
4. Create source summary using type-specific extraction
5. Identify concepts, entities, and projects mentioned
6. Create new pages if concept appears in 2+ sources (stub if only 1)
7. Update existing pages - append new info, never rewrite from scratch
8. Add `[[wikilinks]]` to connect new content to existing pages
9. Run bias check: add counter-arguments and data gaps sections
10. Update `wiki/index.md` with new entries and TLDRs
11. Append to `wiki/log.md` with date, operation, pages touched

### QUERY

1. Read `wiki/index.md` - scan TLDRs only
2. Identify relevant pages from TLDRs (skip irrelevant ones to save tokens)
3. Read full content of relevant pages
4. Synthesize an answer with citations to specific `[[wiki pages]]`
5. Save the answer as `wiki/outputs/{question-slug}.md` with `type: output`
6. Update `wiki/index.md` and `wiki/log.md`

### EXPLORE

1. Take a topic or concept name as input
2. Read the existing wiki page for that topic (if it exists)
3. Identify gaps, thin sections, and open questions from the page's Data gaps section
4. Search for additional information using available tools (web search, scraping, etc.)
5. Expand the page with new findings, always citing sources
6. Create new source pages in `wiki/sources/` for any external material found
7. Update related concept and entity pages with cross-references
8. Set `confidence` based on source quality and corroboration
9. Set `explored: false` (always - only the user validates)
10. Update `wiki/index.md` and `wiki/log.md`

### LINT

1. Find contradictions between pages
2. Find orphan pages (no inbound links)
3. Find broken `[[wikilinks]]` pointing to nothing
4. Identify missing frontmatter fields
5. Flag stale content (>6 months, no updates)
6. Suggest new articles for frequently mentioned but unlinked concepts
7. Check for duplicate concepts under different names - merge them
8. Fix automatically where possible
9. Output report to `wiki/outputs/lint-report-{date}.md`

### COMPILE (rebuild indexes)

1. Scan all wiki pages
2. Regenerate `wiki/index.md` with current page list and TLDRs
3. Verify all `[[wikilinks]]` resolve to existing pages
4. Create stubs for any unresolved links

## Page Creation Threshold

- **Full page**: subject appears in 2+ sources
- **Stub page**: single mention (frontmatter + one-line definition + source link)
- **Never** leave a `[[wikilink]]` pointing to nothing

## Quality Standards

- Source summaries: 200-500 words, synthesize - don't copy
- Concept articles: 500-1500 words with clear lead section
- Always trace claims to specific source pages
- Flag contradictions with a warning note, stating both positions
- Prefer recency when sources conflict
- Only make connections explicitly supported by source material
- Use `[[wikilinks]]` for all internal cross-references
- Link only the first occurrence of a concept per section
- Bold key terms on first use in each article
- No em dashes - use regular dashes or commas
- All filenames: kebab-case, lowercase
- Source summaries: `{author-or-source}-{year}-{short-title}.md`

## External Integrations

- **Git**: Version control for the vault. Every change is reversible.
- **Obsidian**: Browse and read the wiki. Graph view for connections. Dataview for queries.
- **Obsidian Web Clipper**: Save location set to `raw/clippings/`. Clip anything - tweets, articles, Reddit, YouTube, GitHub. During INGEST Phase 0, files get sorted to the correct raw/ subfolder based on source URL, then removed from clippings/.

## Session Memory (Hot Cache)

`wiki/hot.md` is a rolling short-term cache of recent sessions. It exists so new conversations don't need a recap.

- **Read it**: auto-injected at SessionStart via hook in `.claude/settings.json`. No action needed.
- **Write it**: auto-regenerated at Stop via `scripts/update-hot-cache.sh` (calls `claude -p` one-shot in the background, 90s timeout, fails silently so it never blocks session shutdown).
- **Scope**: last session + recent decisions + open threads. NOT a replacement for `log.md` (permanent) or `index.md` (structural). If you find yourself writing long-form content into `hot.md`, that belongs in a concept/synthesis page instead.
- **Editing**: You can edit `hot.md` manually to correct the cache or seed context for the next session. The Stop hook preserves edits because the regeneration prompt passes previous hot.md contents as input.

## Scale Plan

| Pages | Strategy |
|-------|----------|
| 0-300 | File-based, `index.md` TLDR scanning. Current approach. |
| 300-500 | Add `qmd` - local markdown search with hybrid BM25/vector + LLM re-ranking. CLI and MCP server. |
| 500+ | Consider structured DB (PostgreSQL/Supabase). |
