---
description: File the current conversation as a wiki note
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: "[optional-slug]"
---

Read CLAUDE.md for conventions.

You are saving the current conversation as a wiki page. Follow this order.

STEP 1 - CLASSIFY:
Decide the page type by examining the conversation:
- `output` - the user asked a question and you answered it (QUERY-shaped)
- `synthesis` - cross-cutting analysis that ties together multiple topics
- `concept` - the conversation defined or expanded a single concept/framework
- `sop` - the conversation produced a repeatable process

If ambiguous, prefer `synthesis`. Never file as `source` (those come from raw/).

STEP 2 - SLUG:
If the user passed an argument (`$ARGUMENTS`), use that as the slug (kebab-case it).
Otherwise derive a 3-6 word kebab-case slug from the conversation topic.

STEP 3 - WRITE:
Create `wiki/{type-folder}/{slug}.md` (folder is `outputs/`, `syntheses/`, `concepts/`, or `sops/`) with standard frontmatter:

```yaml
---
title: "{Title Case}"
tldr: "One or two sentences describing the content for index scanning."
date_created: {today YYYY-MM-DD}
date_modified: {today YYYY-MM-DD}
type: {classified type}
tags: [{relevant-tags}]
sources: []
explored: false
confidence: {high|medium|low}
---
```

Body structure:
1. Lead paragraph - what this page captures, in your own words (not a transcript).
2. Key sections - the actual substance, synthesized. Use headings.
3. `## Counter-arguments` - per CLAUDE.md bias check.
4. `## Data gaps` - per CLAUDE.md bias check.
5. `## Origin` - one line: "Filed from conversation on {date}."

Add `[[wikilinks]]` for every concept/entity you reference that already exists in the wiki. Scan `wiki/index.md` first to find existing pages. Never link to pages that don't exist.

STEP 4 - UPDATE INDEX:
Add the new page to `wiki/index.md` under the appropriate section with its TLDR.

STEP 5 - UPDATE LOG:
Append a row to `wiki/log.md`:
`| {today} | SAVE | {slug} | Filed conversation as {type}. |`

STEP 6 - QMD (optional):
If `qmd` is installed (`command -v qmd`), run `qmd update && qmd embed` so the new page is searchable. Skip if not installed.

STEP 7 - GIT:
Commit and push per CLAUDE.md rule. Commit message: `save: file {slug} ({type})`.

STEP 8 - REPORT:
Report to the user: path of the new file, page type, and wikilinks added.
