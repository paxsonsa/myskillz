---
allowed-tools: Bash
description: Discover a repo and generate an LLM context guide
---
# Discovery

You are the entrypoint for generate repository context guides.

## Initial Setup

1. **Check Arguments**:
   The user prompt is provided in `<prompt>` below.
   
   - **If `<prompt>` is empty**:
     Respond with:
     ```
     No focus topic provided.
     
     Would you like to:
     1. Generate a **general** repo discovery? (Reply "general")
     2. Run a **focused** discovery? (Reply with the topic, e.g., "auth flow", "deployment")
     ```
     Then Stop and wait for user input.

   - **If `<prompt>` is NOT empty**:
     Proceed to generate the discovery document using the provided topic.

## Execution Steps

When you have a topic (either "general" or specific):

1. **Inject Context**:
   The "Repo Snapshot" below provides the current git state. Read it carefully.

2. **Execute Discovery**:
   You are the **Discovery Worker** (loaded via `agent: discovery-worker`).
   Your task is to produce the discovery document in `.llm/shared/context/`.
   
   Follow your agent instructions (in `discovery-worker.md`) to:
   - Analyze the scope
   - Investigate the codebase (using tools)
   - Synthesize the guide
   - Write it to `.llm/shared/context/`

3. **Report**:
   After writing the file:
   - Print the final path.
   - Provide a short summary of what was covered.
   - List 5-10 key files referenced.

---

## Repo Snapshot (auto-injected)
Repo root:
!`git rev-parse --show-toplevel 2>/dev/null || pwd`

Repo name:
!`basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"`

Branch:
!`git branch --show-current 2>/dev/null || echo "(no-branch)"`

Commit:
!`git rev-parse HEAD 2>/dev/null || echo "(no-git)"`

Status:
!`git status --porcelain 2>/dev/null | head -n 200`

Top-level files/dirs:
!`ls -la | sed -n '1,200p'`

Repo tree (depth 4; ignore big dirs):
!`if command -v tree >/dev/null 2>&1; then tree -a -L 4 -I ".git|.hg|.svn|node_modules|dist|build|target|.venv|venv|__pycache__|.mypy_cache|.pytest_cache|.ruff_cache|.idea|.vscode|.DS_Store" --dirsfirst 2>/dev/null | sed -n '1,400p'; else echo "(tree not installed)"; find . -maxdepth 4 -print | sed 's|^\./||' | sed -n '1,400p'; fi`

Key project files (best-effort):
!`find . -maxdepth 3 -type f \( -name "README*" -o -name "CONTRIBUTING*" -o -name "pyproject.toml" -o -name "Cargo.toml" -o -name "package.json" -o -name "go.mod" -o -name "Makefile" -o -name "justfile" -o -name "Dockerfile" -o -name "docker-compose.yml" -o -name "docker-compose.yaml" -o -name ".gitlab-ci.yml" \) -print | sed 's|^\\./||' | head -n 200`

<prompt>
$ARGUMENTS
</prompt>
