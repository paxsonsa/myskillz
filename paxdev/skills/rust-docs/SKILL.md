---
name: rust-docs
description: >
  Look up Rust crate information, versions, dependencies, and documentation from crates.io and docs.rs.
  Use this skill whenever the user asks about a Rust crate, wants to check crate versions, find
  documentation, compare crate features, look up dependencies, or needs help choosing between crates.
  Trigger on: crate names, "cargo add", "what version of X", "docs for X", "how to use X in Rust",
  dependency questions, feature flags, or any Rust ecosystem lookup. Even if the user just mentions
  a crate name in passing and seems unsure about it, use this skill to pull real data.
---

# Rust Crate & Documentation Lookup

You have access to the crates.io REST API and docs.rs URL patterns to look up real-time
information about Rust crates. Use these to give accurate, current answers instead of
relying on training data which may be outdated.

## When to Use This Skill

- User asks about a crate's latest version, features, or dependencies
- User wants to compare crates or find alternatives
- User needs documentation links
- User is adding a dependency and wants the right version string
- User asks "what does crate X do?" — look it up, don't guess
- User is debugging a version conflict or feature flag issue

## API Reference

### crates.io REST API

Base URL: `https://crates.io/api/v1`

All requests MUST include a User-Agent header. Use:
```
User-Agent: claude-rust-docs-skill (https://github.com/apaxson)
```

#### Lookup a specific crate

```bash
curl -s -H "User-Agent: claude-rust-docs-skill" \
  "https://crates.io/api/v1/crates/{crate_name}"
```

Returns:
- `.crate.description` — what it does
- `.crate.max_version` / `.crate.max_stable_version` — latest version
- `.crate.downloads` / `.crate.recent_downloads` — popularity signal
- `.crate.repository` — source code link
- `.crate.documentation` — docs link (if set by author)
- `.crate.homepage` — project homepage
- `.crate.keywords` / `.crate.categories` — classification
- `.versions[]` — array of all published versions with:
  - `.num` — semver string
  - `.features` — feature flags available
  - `.rust_version` — MSRV
  - `.license` — SPDX license
  - `.yanked` — whether this version was yanked
  - `.crate_size` — size in bytes
  - `.created_at` — publish date

#### Search for crates

```bash
curl -s -H "User-Agent: claude-rust-docs-skill" \
  "https://crates.io/api/v1/crates?q={search_term}&per_page=10"
```

Returns `.crates[]` array with same metadata fields, plus:
- `.meta.total` — total result count
- `.meta.next_page` — pagination

#### Get crate dependencies

```bash
curl -s -H "User-Agent: claude-rust-docs-skill" \
  "https://crates.io/api/v1/crates/{crate_name}/{version}/dependencies"
```

Returns `.dependencies[]` with:
- `.crate_id` — dependency name
- `.req` — version requirement string
- `.kind` — "normal", "dev", or "build"
- `.optional` — whether it's behind a feature flag
- `.default_features` — whether default features are enabled
- `.features[]` — which features are activated

#### Get crate owners

```bash
curl -s -H "User-Agent: claude-rust-docs-skill" \
  "https://crates.io/api/v1/crates/{crate_name}/owners"
```

#### Get reverse dependencies (who depends on this crate)

```bash
curl -s -H "User-Agent: claude-rust-docs-skill" \
  "https://crates.io/api/v1/crates/{crate_name}/reverse_dependencies?per_page=10"
```

### docs.rs URL Patterns

docs.rs hosts auto-generated rustdoc for every crate published to crates.io.

| URL Pattern | What it shows |
|---|---|
| `https://docs.rs/{crate}` | Latest version docs |
| `https://docs.rs/{crate}/{version}` | Specific version docs |
| `https://docs.rs/{crate}/latest/{crate}/` | Module root |
| `https://docs.rs/{crate}/latest/{crate}/{module}/` | Submodule |
| `https://docs.rs/{crate}/latest/{crate}/struct.{Name}.html` | Struct docs |
| `https://docs.rs/{crate}/latest/{crate}/trait.{Name}.html` | Trait docs |
| `https://docs.rs/{crate}/latest/{crate}/fn.{Name}.html` | Function docs |
| `https://docs.rs/{crate}/latest/{crate}/enum.{Name}.html` | Enum docs |
| `https://docs.rs/crate/{crate}/latest` | Crate info page (versions, features, etc.) |
| `https://docs.rs/crate/{crate}/latest/source/` | Source browser |

Semver ranges work: `https://docs.rs/{crate}/~1.0` redirects to latest 1.x.

Note: For crates with hyphens in the name, the module path uses underscores.
Example: `https://docs.rs/my-crate/latest/my_crate/` (hyphen in crate name, underscore in module path).

### Rust Standard Library & Cargo Docs

| Resource | URL |
|---|---|
| std library | `https://doc.rust-lang.org/std/` |
| Cargo book | `https://doc.rust-lang.org/cargo/` |
| Rust reference | `https://doc.rust-lang.org/reference/` |
| Rustonomicon | `https://doc.rust-lang.org/nomicon/` |
| Edition guide | `https://doc.rust-lang.org/edition-guide/` |
| Cargo.toml reference | `https://doc.rust-lang.org/cargo/reference/manifest.html` |

## Workflow

### For "what's the latest version of X?"

1. Hit the crate lookup endpoint
2. Report `.crate.max_stable_version` (prefer stable over pre-release)
3. Show the `cargo add` command: `cargo add {crate}@{version}`
4. Link to docs: `https://docs.rs/{crate}/{version}`

### For "what crate should I use for X?"

1. Search crates.io with relevant terms
2. Compare top results by: recent downloads, last updated, description
3. For top 2-3 candidates, fetch full details to compare features
4. Present a short comparison table with recommendation

### For "show me the docs for X"

1. Look up the crate to confirm it exists and get the correct name
2. Provide the docs.rs link
3. If the user wants specific API docs, use the WebFetch tool on the docs.rs URL
   to pull the actual documentation content

### For "what features does X have?"

1. Fetch crate details
2. Look at the latest version's `.features` object
3. Present features with brief descriptions where inferable
4. Note which features are in `default`

### For dependency/version conflict debugging

1. Fetch both crates' dependency trees
2. Look for overlapping transitive dependencies
3. Check version compatibility between requirements
4. Suggest resolution (version bumps, feature flags, etc.)

## Helper Script

For complex lookups, use the helper script at:
```
skills/rust-docs/scripts/crate_lookup.sh
```

Usage:
```bash
# Basic crate info
bash skills/rust-docs/scripts/crate_lookup.sh info serde

# Search
bash skills/rust-docs/scripts/crate_lookup.sh search "http client"

# Dependencies for a specific version
bash skills/rust-docs/scripts/crate_lookup.sh deps tokio 1.35.0

# Latest versions (shows last 10)
bash skills/rust-docs/scripts/crate_lookup.sh versions serde

# Reverse deps (who uses this crate)
bash skills/rust-docs/scripts/crate_lookup.sh rdeps serde
```

## Output Formatting

When presenting crate information, use this structure:

```
**{crate_name}** v{version} — {description}
License: {license} | Downloads: {downloads} | Updated: {date}
Repo: {repository_url}
Docs: https://docs.rs/{crate_name}/{version}
`cargo add {crate_name}`
```

For search results, present as a compact comparison:

```
| Crate | Version | Downloads | Description |
|-------|---------|-----------|-------------|
| ...   | ...     | ...       | ...         |
```

## Rate Limiting

crates.io asks that automated clients limit to 1 request per second.
The helper script includes a small delay between requests. When making
multiple API calls manually, space them out. For most user questions,
1-3 API calls is sufficient.
