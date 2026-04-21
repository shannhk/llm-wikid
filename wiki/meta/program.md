---
title: "Autoresearch Program"
tldr: "Configuration for the /autoresearch command. Source preferences, confidence rules, stop conditions. Edit to tune behavior for your domain."
date_created: 2026-04-21
date_modified: 2026-04-21
type: sop
tags: [meta, autoresearch, configuration]
explored: false
confidence: medium
---

# Autoresearch Program

Edit this file to tune how `/autoresearch` behaves. The command reads it at runtime.

Out of the box the program is domain-agnostic. Add your domain specifics under "Per-Domain Overrides" so the default loop stays usable for anyone.

## Preferred Sources

Generic ranking. Override this list for your domain.

1. **Primary sources**: official documentation, original research papers, first-party company blogs, government data.
2. **Authoritative secondary**: established publications with editorial standards, well-known subject-matter experts with track records.
3. **Community**: Stack Overflow, Reddit threads with high-quality discussion, GitHub READMEs.
4. **Skip**: content farms, SEO-spam listicles, paraphrased "top 10" posts with no author credentials.

## Confidence Scoring

Set `confidence:` on every created page:

- `high` - 3+ corroborating sources OR primary source with track record
- `medium` - 1-2 sources, reasonable synthesis
- `low` - speculative, early-stage, thin evidence
- `uncertain` - contradictory sources

## Stop Conditions

Default loop budget:

- **Max rounds**: 3 (search -> extract -> gap-fill -> stop)
- **Max sources fetched per round**: 5
- **Max total sources per run**: 12
- **Stop early if**: the last round produced 0 new concepts/entities

## Per-Domain Overrides

Add your domain-specific rules here. Examples:

- Medical research: prefer PubMed, Cochrane, NEJM. Require 2+ sources for any clinical claim.
- Legal: prefer official court records, bar association publications, statute text. Flag jurisdiction on every claim.
- AI/ML: prefer arXiv, official model cards, author blogs. Check dated the publication carefully (stale fast).
- Product/SaaS: prefer official docs, changelogs, and well-known industry analysts over marketing blogs.
