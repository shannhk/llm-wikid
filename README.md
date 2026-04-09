```
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║   ██╗     ██╗     ███╗   ███╗   ██╗    ██╗██╗██╗  ██╗██╗        ║
║   ██║     ██║     ████╗ ████║   ██║    ██║██║██║ ██╔╝██║        ║
║   ██║     ██║     ██╔████╔██║   ██║ █╗ ██║██║█████╔╝ ██║        ║
║   ██║     ██║     ██║╚██╔╝██║   ██║███╗██║██║██╔═██╗ ██║        ║
║   ███████╗███████╗██║ ╚═╝ ██║   ╚███╔███╔╝██║██║  ██╗██║        ║
║   ╚══════╝╚══════╝╚═╝     ╚═╝    ╚══╝╚══╝ ╚═╝╚═╝  ╚═╝╚═╝        ║
║                                                                   ║
║   build a personal AI knowledge base in obsidian                  ║
║                                                                   ║
║   raw sources ──> AI agent ──> structured wiki                    ║
║                                                                   ║
║   ┌─────────┐    ┌───────────┐    ┌─────────────────────┐        ║
║   │  raw/   │───>│  CLAUDE.md │───>│  wiki/              │        ║
║   │ clips   │    │  (schema)  │    │  concepts/          │        ║
║   │ ideas   │    │            │    │  entities/           │        ║
║   │ tweets  │    │  ingest    │    │  sources/            │        ║
║   │ papers  │    │  query     │    │  index.md            │        ║
║   │ urls    │    │  explore   │    │  ──> obsidian graph  │        ║
║   └─────────┘    └───────────┘    └─────────────────────┘        ║
║                                                                   ║
║   works with any AI agent that can read markdown and run bash     ║
║   @shannholmberg                                                  ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

# LLM Wiki

A template for building a personal knowledge base maintained by an AI agent, based on [Andrej Karpathy's LLM Wiki pattern](https://x.com/karpathy/status/1890540708772143562). You clip stuff into a raw folder, the agent compiles it into structured wiki pages with cross-references, bias checks, and a master index.

Works with any agent that can read markdown and run shell commands: Claude Code, OpenClaw, Hermes, Codex, or your own setup.

## What You Need

- [Obsidian](https://obsidian.md/) (free) - to browse and read the wiki
- An AI agent (Claude Code, OpenClaw, Hermes, etc.)
- Git - version control for the vault

### Optional Tools

These get installed as needed during ingestion:

| Tool | What it does | Install |
|------|-------------|---------|
| `yt-dlp` | Extracts YouTube transcripts | `brew install yt-dlp` |
| `scrapling` | Scrapes web pages | `pipx install scrapling` |
| `summarize` | Extracts text from PDFs | `brew install steipete/tap/summarize` |
| X API | Fetches tweets/threads | OAuth keys in `.env` (optional) |

## Setup

```bash
# Clone the template
git clone https://github.com/shannhk/llm-wiki.git my-wiki
cd my-wiki

# Open in Obsidian
# File > Open Vault > select the my-wiki folder

# Start your agent in the folder
claude --dangerously-skip-permissions   # Claude Code
# or open with OpenClaw, Hermes, Codex, etc.
```

That's it. The CLAUDE.md file tells the agent how everything works. Any agent that can read markdown and run bash commands will pick it up.

## How to Use

### Clip stuff

Drop files into `raw/`. URLs, notes, PDFs, bookmarks, ideas - anything goes. Use [Obsidian Web Clipper](https://obsidian.md/clipper) to save articles and tweets directly to `raw/clippings/`.

### Process sources

```
/wiki-ingest
```

The agent resolves URLs (fetches full content), classifies each source, creates wiki pages, links everything together, and updates the index.

### Ask questions

```
/wiki-query what are the main arguments for X?
```

Scans the wiki index, reads relevant pages, synthesizes an answer with citations, and saves it as an output page.

### Explore a topic

```
/wiki-explore distributed systems
```

Researches a topic using web search, expands the wiki page with new findings, creates source pages for anything it finds.

### Health check

```
/wiki-lint
```

Finds broken links, orphan pages, contradictions, missing frontmatter, stale content, and duplicate concepts. Fixes what it can automatically.

## Folder Structure

```
raw/                          # Messy inbox - drop anything here
  clippings/                  # Obsidian Web Clipper landing zone
  ideas/                      # Notes and brainstorms
  bookmarks/                  # Saved URLs (tweets, YouTube, Reddit)
  articles/                   # Long-form articles and blog posts
  papers/                     # Research papers and PDFs
  assets/images/              # Downloaded media
  x-archive/                  # X/Twitter archive export

wiki/                         # Compiled knowledge base (AI-maintained)
  index.md                    # Master index with TLDRs
  log.md                      # Append-only changelog
  dashboard.md                # Dataview dashboard (Obsidian)
  concepts/                   # Ideas, frameworks, topics
  entities/                   # People, companies, tools
  sources/                    # One page per raw source
  syntheses/                  # Cross-cutting analysis
  outputs/                    # Filed answers to queries
  sops/                       # Repeatable processes

templates/                    # Obsidian Templater templates
.claude/commands/             # Slash commands for Claude Code
```

## How It Works

This is **not** RAG. Knowledge is pre-compiled into structured wiki pages. When you query the wiki, the agent reads the index TLDRs to find relevant pages, then reads only those pages in full. Every query compounds the system - answers get saved as output pages that future queries can reference.

Key principles:
- **Bias checks** - every concept and source page includes counter-arguments and data gaps
- **Validation gate** - AI sets `explored: false` on every page it creates. Only you mark pages as reviewed.
- **Confidence levels** - pages are tagged high/medium/low/uncertain based on source quality
- **No blind links** - every `[[wikilink]]` resolves to an actual page (stubs get created automatically)
- **Source tracing** - every claim traces back to a specific source page

## Scaling

| Wiki Size | Strategy |
|-----------|----------|
| 0-300 pages | File-based, index TLDR scanning (this template) |
| 300-500 pages | Add [qmd](https://github.com/reidbarber/qmd) for local markdown search |
| 500+ pages | Consider a structured database |

## Credits

- [Andrej Karpathy's LLM Wiki pattern](https://x.com/karpathy/status/1890540708772143562) - the original idea
- [hooeem's LLM Knowledge Base course](https://www.youtube.com/watch?v=IVpOyKCNZYw) - detailed tutorial on the pattern
- Built by [@shannholmberg](https://x.com/shannholmberg)

## Search (qmd)

For faster search across your wiki, install [qmd](https://github.com/tobi/qmd) by Tobi Lutke. It runs 100% locally with hybrid BM25/vector search and LLM re-ranking.

```bash
npm install -g @tobilu/qmd
qmd collection add wiki --name my-wiki
qmd embed
```

Search your wiki:
```bash
qmd search "query"        # Fast keyword search
qmd query "query"         # Hybrid search with LLM re-ranking
```

qmd also has an MCP server so your agent can use it as a native tool:
```json
{
  "mcpServers": {
    "qmd": { "command": "qmd", "args": ["mcp"] }
  }
}
```
