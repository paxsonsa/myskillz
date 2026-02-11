# myskillz

Claude Code marketplace with custom plugins and skills.

## Install

In Claude Code:

```
/plugin marketplace add https://github.com/paxsonsa/myskillz
/plugin install paxdev@myskillz --scope user
```

## Plugins

### paxdev

Development workflow plugin with research, planning, and discovery commands. See [paxdev/README.md](paxdev/README.md) for details.

**Commands:** `/research`, `/discovery`, `/create_plan`, `/implement_plan`, `/validate_plan`, `/validate_research`, `/commit`

**Agents:** 10 specialized sub-agents for codebase analysis, discovery, and research

**Skills:** `rust-docs` — Rust crate & documentation lookup via crates.io API
