---
description: Autonomous multi-round research loop. Search, fetch, extract, cross-reference, gap-fill, file.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, WebFetch, WebSearch
argument-hint: "<topic>"
---

Read CLAUDE.md for conventions.
Read wiki/meta/program.md for research rules, source preferences, stop conditions.
Read wiki/index.md to understand existing coverage.

Topic: $ARGUMENTS

If no topic was provided, ask the user what to research and stop.

This is a multi-round loop. Stay inside the budget from program.md.

ROUND 1 - SEARCH + SEED:
1. Use WebSearch to find up to 5 candidate sources for the topic, biased toward preferred sources in program.md.
2. For each URL, fetch content using the right tool (WebFetch for general web, `yt-dlp` for YouTube if installed, `scrapling` CLI for complex sites if installed).
3. Save each fetched source to `raw/articles/` or `raw/bookmarks/` with frontmatter (`original_url`, `fetched`, `source_tool`).
4. Create source summary pages in `wiki/sources/` per CLAUDE.md extraction rules. Use type-specific extraction (transcript / paper / article / tweet / reddit).

ROUND 2 - EXTRACT + LINK:
5. Identify concepts and entities mentioned across the round-1 sources.
6. For concepts appearing in 2+ sources: create full concept page. For concepts in 1 source: create stub.
7. Add `[[wikilinks]]` connecting new pages to existing wiki pages. Scan `index.md` to find them. Never link to pages that don't exist.

ROUND 3 - GAP FILL:
8. Review what you have. List remaining open questions or thin sections.
9. Do up to 5 more targeted searches to fill the biggest gaps.
10. Update existing pages with the new info. Append, never rewrite.

STOP EARLY IF:
- Round 2 or 3 produces 0 new concepts or entities.
- You hit the max source budget from program.md.

FINAL STEPS:
11. Add `## Counter-arguments` and `## Data gaps` sections to every new concept/synthesis page. Use `> [!contradiction]` callouts for inline contradictions between sources (per CLAUDE.md bias check).
12. Set `explored: false` and `confidence:` per program.md rules on every new page.
13. Add a synthesis page at `wiki/syntheses/{topic-slug}-research.md` summarizing what was learned across all sources. Cite specific `[[sources]]`.
14. Update `wiki/index.md` with all new pages and their TLDRs.
15. Append a detailed row to `wiki/log.md`: sources fetched, pages created, pages updated.
16. If `qmd` is installed, run `qmd update && qmd embed`.
17. Commit and push per CLAUDE.md. Commit message: `autoresearch: {topic} ({N} sources, {M} pages)`.

REPORT:
Final summary to the user: topic, rounds run, sources fetched, pages created, the synthesis page path, and the 3 biggest open questions remaining.
