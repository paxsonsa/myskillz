# Paxdev Plugin

A Claude Code plugin for development workflows, including research, planning, and discovery commands. Converted from opencode configuration.

## Directory Structure

```
paxdev/
├── .claude-plugin/ # Plugin metadata
│   └── plugin.json
├── commands/       # Slash commands for Claude Code
├── agents/         # Specialized agents for various tasks
├── skills/         # Skills for domain-specific capabilities
│   └── rust-docs/  # Rust crate & documentation lookup
└── README.md       # This file
```

## Commands

Commands can be invoked with `/command-name` in Claude Code:

- `/research` - Research a codebase by spawning parallel sub-agents
- `/discovery` - Discover a repo and generate an LLM context guide
- `/create_plan` - Create detailed implementation plans
- `/implement_plan` - Implement an approved technical plan
- `/validate_plan` - Validate that a plan was implemented successfully
- `/commit` - Create git commits for changes made in session

## Subagents

Subagents are specialized agents that can be spawned using the Task tool:

### Codebase Research
- `codebase-locator` - Locates files, directories, and components
- `codebase-analyzer` - Analyzes implementation details
- `codebase-pattern-finder` - Finds similar implementations and patterns

### Discovery System
- `discovery-locator` - Find existing discovery docs
- `discovery-analyzer` - Decide if discovery doc is fresh/relevant
- `discovery-worker` - Generate and update discovery context docs

### Thoughts/LLM Directory Research
- `thoughts-locator` - Discovers relevant documents in .llm/ directory
- `thoughts-analyzer` - Deep dive analysis on research topics

### External Research
- `web-search-researcher` - Web research for modern information
- `research` - Primary research agent for synthesizing findings

## Conversion Notes

These files were converted from opencode format by:
1. Removing opencode-specific frontmatter fields (`agent`, `model`, `tools`, `mode`)
2. Keeping the `description` field for Claude Code
3. Preserving `$ARGUMENTS` placeholders in commands (Claude Code supports this)
4. Maintaining all prompt instructions and workflows

## Usage

The commands reference subagents by name. For example, the `/research` command spawns subagents like:
- `codebase-locator` to find relevant files
- `codebase-analyzer` to understand implementations
- `thoughts-locator` to find historical context

These subagents work together to provide comprehensive research and analysis.

## Skills

Skills provide domain-specific knowledge and tools:

- `rust-docs` - Look up Rust crate versions, features, dependencies, and documentation from crates.io and docs.rs. Includes a `crate_lookup.sh` helper script for structured API queries.
