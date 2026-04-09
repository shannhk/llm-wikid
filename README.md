```
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║   ██╗     ██╗     ███╗   ███╗  ██╗    ██╗██╗██╗  ██╗██╗██████╗         ║
║   ██║     ██║     ████╗ ████║  ██║    ██║██║██║ ██╔╝██║██╔══██╗        ║
║   ██║     ██║     ██╔████╔██║  ██║ █╗ ██║██║█████╔╝ ██║██║  ██║        ║
║   ██║     ██║     ██║╚██╔╝██║  ██║███╗██║██║██╔═██╗ ██║██║  ██║        ║
║   ███████╗███████╗██║ ╚═╝ ██║  ╚███╔███╔╝██║██║  ██╗██║██████╔╝        ║
║   ╚══════╝╚══════╝╚═╝     ╚═╝   ╚══╝╚══╝ ╚═╝╚═╝  ╚═╝╚═╝╚═════╝         ║
║                                                                          ║
║   your AI-maintained knowledge base in obsidian                          ║
║                                                                          ║
║   ┌─────────┐    ┌────────────┐    ┌──────────────────────┐             ║
║   │  raw/   │───>│  CLAUDE.md  │───>│  wiki/               │             ║
║   │ clips   │    │  (schema)   │    │  concepts/ entities/  │             ║
║   │ ideas   │    │             │    │  sources/ outputs/    │             ║
║   │ tweets  │    │  ingest     │    │  index.md log.md      │             ║
║   │ papers  │    │  query      │    │                       │             ║
║   │ urls    │    │  explore    │    │  ──> obsidian graph    │             ║
║   └─────────┘    │  lint       │    └──────────────────────┘             ║
║                  └────────────┘                                          ║
║                                                                          ║
║   clip it, ingest it, query it, watch it compound                        ║
║   works with any agent that reads markdown and runs bash                 ║
║   @shannholmberg                                                         ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
```

# LLM Wikid

An AI-maintained knowledge base that lives in Obsidian. Based on [Karpathy's LLM Wiki pattern](https://x.com/karpathy/status/1890540708772143562).

You dump raw sources into a folder. An AI agent reads them, compiles structured wiki pages with cross-references, runs bias checks, and maintains a master index. Every question you ask gets filed back in. The wiki compounds the more you use it.

Works with any agent that can read markdown and run shell commands: Claude Code, OpenClaw, Hermes, Codex, or your own setup.

## Quick Start

```bash
git clone https://github.com/shannhk/llm-wikid.git my-wiki
cd my-wiki

# open as an Obsidian vault
# File > Open Vault > select the my-wiki folder

# start your agent
claude --dangerously-skip-permissions   # Claude Code
# or open with OpenClaw, Hermes, Codex, etc.
```

The agent reads `CLAUDE.md` and knows everything. That file is the schema that controls the entire system.

## How It Works

This is **not RAG**. RAG re-derives answers every time by chunking documents and running vector search. This system compiles knowledge once into structured wiki pages, keeps them current, and pre-builds cross-references. At ~100 articles / ~400K words, Karpathy found this outperforms RAG for Q&A.

```
                    ┌──────────────────────────────────┐
                    │           CLAUDE.md              │
                    │   the schema that controls       │
                    │   everything the agent does      │
                    └──────────┬───────────────────────┘
                               │
    ┌──────────┐      ┌────────▼────────┐      ┌──────────────┐
    │  raw/    │      │    INGEST       │      │   wiki/      │
    │          │─────>│                 │─────>│              │
    │ clips    │      │ 0. sort clips   │      │ concepts/    │
    │ ideas    │      │ 1. resolve URLs │      │ entities/    │
    │ tweets   │      │ 2. extract media│      │ sources/     │
    │ articles │      │ 3. classify     │      │ index.md     │
    │ papers   │      │ 4. compile pages│      │ log.md       │
    │          │      │ 5. cross-link   │      │              │
    └──────────┘      │ 6. bias check   │      └──────┬───────┘
                      │ 7. update index │             │
                      └─────────────────┘     ┌───────▼───────┐
                                              │   Obsidian    │
    ┌──────────┐      ┌─────────────────┐     │  graph view   │
    │ question │─────>│    QUERY        │     │  + Dataview   │
    │          │      │                 │     └───────────────┘
    │          │      │ scan TLDRs      │
    │          │<─────│ read relevant   │
    │  answer  │      │ synthesize      │
    │  (filed  │      │ file back in    │───> wiki grows
    │   back)  │      └─────────────────┘
    └──────────┘
```

The compound loop: every answer filed back means the next query has more to work with. Your curiosity makes the system smarter.

## The Ingest Pipeline

When you run `/wiki-ingest`, the agent processes everything in `raw/` through these phases:

**Phase 0 - Sort clippings.** Anything in `raw/clippings/` gets moved to the right subfolder based on its URL. Tweet goes to `raw/bookmarks/`, article to `raw/articles/`, PDF to `raw/papers/`. The clippings folder is just an inbox.

**Phase 1 - Resolve.** The agent detects what each file contains and fetches the full content:
- YouTube URL: extracts transcript via `yt-dlp`
- X/Twitter URL: fetches tweet text, thread, metrics via X API
- Web URL / Reddit: scrapes full page via `scrapling`
- PDF: reads directly
- Plain text: already resolved

The resolved content replaces the file in-place. The original URL stays in frontmatter for provenance.

**Phase 1.5 - Media extraction.** Images get downloaded to `raw/assets/images/` and analyzed. Videos get their transcripts pulled. A tweet that says "here's my stack" with an image of the stack is useless without the image.

**Phase 2 - Classify and compile.** Each source gets classified by type (transcript, paper, report, article, tweet, notes) and extracted differently. A transcript gets speaker attribution and action items. A paper gets method and findings. An article gets core thesis and supporting arguments. Generic extraction misses what makes each format valuable.

The agent creates wiki pages, adds `[[wikilinks]]` between them, runs bias checks (counter-arguments and data gaps on every page), and updates the master index.

**Phase 3 - Re-index.** If you have `qmd` installed, the search index gets updated with new content.

## Commands

| Command | What it does |
|---------|-------------|
| `/wiki-ingest` | Process new raw sources into wiki pages |
| `/wiki-query [question]` | Research a question, get a cited answer, file it back |
| `/wiki-explore [topic]` | Actively research and expand a topic using web search and `/last30days` |
| `/wiki-lint` | Health check: contradictions, orphans, broken links, stale content |

## Folder Structure

```
raw/                          # your messy inbox
  clippings/                  # Obsidian Web Clipper landing zone (auto-sorted)
  ideas/                      # notes, brainstorms, half-formed thoughts
  bookmarks/                  # saved tweets, YouTube, Reddit links
  articles/                   # your own published content
  papers/                     # research papers, PDFs
  assets/images/              # downloaded media from sources
  x-archive/                  # X/Twitter account export

wiki/                         # compiled knowledge (AI-maintained)
  index.md                    # master catalog with TLDRs for fast scanning
  log.md                      # append-only changelog of every operation
  dashboard.md                # Dataview queries for Obsidian
  concepts/                   # ideas, frameworks, topics
  entities/                   # people, companies, tools
  sources/                    # one summary per raw source
  syntheses/                  # cross-cutting analysis
  outputs/                    # filed answers to queries
  sops/                       # repeatable processes

templates/                    # starter templates for each page type
.claude/commands/             # slash commands
```

## Quality Controls

The system has safeguards to prevent it from becoming a pile of confident-sounding AI output:

**Bias checks.** Every concept and source page includes a `## Counter-arguments` section (what pushes back) and a `## Data gaps` section (what we don't know). Without these, the wiki just agrees with every source.

**Validation gate.** The agent sets `explored: false` on every page it creates. Only you can mark something as reviewed by setting it to `true`. You always know what's been human-verified and what hasn't.

**Confidence levels.** Pages are tagged `high`, `medium`, `low`, or `uncertain` based on how well-supported the content is. Multiple corroborating sources = high. Single mention with thin evidence = low. The agent has to be honest.

**Source tracing.** Every claim links back to a specific source page. No vague "research shows" without pointing to which research.

**No blind links.** Every `[[wikilink]]` resolves to an actual page. If a concept is mentioned but doesn't have a page yet, the agent creates a stub.

## Curation

This is an idea bank, not a fact database. Some of what goes in will be wrong, half-formed, or just bad. That's fine. The point is capturing your thinking so it compounds over time.

But curation matters. Before clipping something into `raw/`, ask: does this feel 80%+ relevant to what I'm working on or thinking about? If it's noise, skip it. The wiki gets stronger when the inputs are high-signal.

Running `/wiki-lint` regularly catches the drift: contradictions between pages, stale claims, orphan pages nobody links to, concepts mentioned but never defined. The agent fixes what it can and flags what needs your judgment.

## Git Sync

GitHub is the source of truth. Every operation that changes `wiki/` or `raw/` ends with a commit and push. This means:

- Every change is reversible (`git revert`)
- Multiple agents can work on the same wiki (pull before writing, push after)
- You can access the wiki from anywhere that can clone a repo
- Your entire knowledge history is preserved

```bash
# every agent session, every ingest, every query:
git add . && git commit -m "wiki update" && git push
```

### Claude Dispatch (automated ingest)

Set up a scheduled trigger that runs `/wiki-ingest` every morning. You clip things during the day, they get processed overnight.

```bash
# in Claude Code:
/schedule
```

Or configure directly: a cron trigger pointing at your repo, running the ingest prompt daily. The remote agent clones the repo, reads CLAUDE.md, processes new sources, commits, and pushes. You wake up to a richer wiki.

The Dispatch agent runs remotely, so it won't have local tools like X API keys. It can still process web URLs, plain text, and anything already resolved. Tweet resolution happens when you run ingest locally.

## Search (qmd)

For fast search across your wiki, install [qmd](https://github.com/tobi/qmd) by Tobi Lutke. Hybrid BM25/vector search with LLM re-ranking, 100% on-device.

```bash
npm install -g @tobilu/qmd
qmd collection add wiki --name my-wiki
qmd embed
```

Three search modes:
```bash
qmd search "query"        # BM25 keyword search (fast)
qmd vsearch "query"       # vector semantic search
qmd query "query"         # hybrid with LLM re-ranking (best)
```

qmd has a built-in MCP server so your agent can use it as a native tool:
```json
{
  "mcpServers": {
    "qmd": { "command": "qmd", "args": ["mcp"] }
  }
}
```

The `/wiki-explore` command uses qmd automatically when installed.

## Recommended Skills

| Skill | What it adds |
|-------|-------------|
| [last30days](https://github.com/mvanhorn/last30days-skill) | Searches Reddit, HN, X, YouTube, GitHub, Polymarket for recent community signals. Used by `/wiki-explore`. |
| [Obsidian Web Clipper](https://obsidian.md/clipper) | Clip anything from your browser directly to `raw/clippings/` |

## Obsidian Plugins

| Plugin | Purpose |
|--------|---------|
| Dataview | Query frontmatter, build dashboards from wiki data |
| Obsidian Git | Auto-commit on interval, push to remote |
| Templater | Auto-populate dates and fields on new notes |
| Tag Wrangler | Bulk rename and merge tags |

## Scaling

| Wiki Size | Strategy |
|-----------|----------|
| 0-300 pages | File-based, index TLDR scanning + qmd search |
| 300-500 pages | qmd becomes primary search layer |
| 500+ pages | Consider PostgreSQL/Supabase |

## Optional Tools

Installed as needed during ingestion:

| Tool | What it does | Install |
|------|-------------|---------|
| `yt-dlp` | YouTube transcripts | `brew install yt-dlp` |
| `scrapling` | Web scraping | `pipx install scrapling` |
| `summarize` | PDF extraction | `brew install steipete/tap/summarize` |
| X API | Tweet/thread fetching | OAuth keys in `.env` (optional) |

## Credits

- [Andrej Karpathy's LLM Wiki pattern](https://x.com/karpathy/status/1890540708772143562) - the original idea
- [hooeem's LLM Knowledge Base course](https://www.youtube.com/watch?v=IVpOyKCNZYw) - practical walkthrough
- [qmd](https://github.com/tobi/qmd) by Tobi Lutke - local markdown search engine
- [last30days](https://github.com/mvanhorn/last30days-skill) by mvanhorn - multi-platform signal search
- Built by [@shannholmberg](https://x.com/shannholmberg)
