---
name: plugin-scaffold
description: Scaffolds a Claude Code plugin with .claude-plugin/marketplace.json + plugin.json + a starter skill/agent/hook + GitHub Actions validator — codifies the vibesubin maintenance pattern. Use when creating a new plugin, publishing to a marketplace, or "플러그인 만들어줘", "claude code plugin scaffold", "마켓플레이스 플러그인".
author: subinium
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Write, Bash, Edit
argument-hint: "<plugin-name> [--with-mcp] [--with-hooks] [--with-agent]"
---

# Plugin Scaffold

Scaffold a new Claude Code plugin in the current directory (or `<plugin-name>/` subdirectory). Follows the schema verified in 2026-04 docs (see `https://code.claude.com/docs/en/plugins`).

## Arguments

- `<plugin-name>` (required, kebab-case, ≤64 chars, NOT containing "claude" or "anthropic")
- `--with-mcp` — also scaffold an MCP server (Python/uvx, stdio transport)
- `--with-hooks` — also scaffold a PostToolUse hook stub (env-opt-in pattern)
- `--with-agent` — also scaffold a sub-agent

## HARD validation rules

These are non-negotiable schema requirements. The scaffold MUST emit a working plugin:

1. `<name>` MUST be kebab-case, ≤64 chars, NOT contain "claude"/"anthropic"
2. `marketplace.json` plugin entry MUST have `name`, `version`, `description`, `author`, `homepage`, `repository`
3. `marketplace.json` MUST use `category` (singular string) and `tags` (array) — NOT `categories` (which is not in the schema)
4. `plugin.json` `version` MUST match `marketplace.json` plugin entry version (drift = release bug)
5. Skill `description` MUST be third-person, ≤1024 chars, contain explicit "Use when..." phrase
6. Hook scripts MUST be executable (`chmod +x`) and reference `${CLAUDE_PLUGIN_ROOT}` for cross-machine portability

## Process

### 1. Validate plugin name
```bash
NAME="<plugin-name>"
[[ "$NAME" =~ ^[a-z][a-z0-9-]{1,63}$ ]] || { echo "Invalid name (kebab-case, ≤64)"; exit 1; }
[[ "$NAME" =~ (claude|anthropic) ]] && { echo "Name must not contain 'claude' or 'anthropic'"; exit 1; }
```

### 2. Create directory structure
```
<plugin-name>/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   └── <plugin-name>/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── skills/
│       │   └── starter/
│       │       └── SKILL.md
│       ├── agents/                 # if --with-agent
│       │   └── starter.md
│       ├── hooks/                  # if --with-hooks
│       │   ├── hooks.json
│       │   └── on-edit.sh
│       └── mcp/                    # if --with-mcp
│           └── server.py
├── .github/
│   └── workflows/
│       ├── validate.yml
│       └── release.yml
├── scripts/
│   └── validate_skills.py
├── tests/
│   └── test_metadata.py
├── README.md
├── LICENSE
├── CHANGELOG.md
├── install.sh
└── uninstall.sh
```

### 3. Generate canonical files

**`.claude-plugin/marketplace.json`** (note: `category` singular, `tags` array):
```json
{
  "name": "<plugin-name>",
  "owner": { "name": "<author>", "email": "<email>" },
  "plugins": [
    {
      "name": "<plugin-name>",
      "source": "./plugins/<plugin-name>",
      "version": "0.1.0",
      "description": "<one-line description>",
      "author": { "name": "<author>", "email": "<email>" },
      "homepage": "https://github.com/<owner>/<plugin-name>",
      "repository": "https://github.com/<owner>/<plugin-name>",
      "license": "MIT",
      "category": "developer-tools",
      "tags": ["claude-code", "<domain>"],
      "keywords": ["<keyword1>", "<keyword2>"]
    }
  ]
}
```

**`plugins/<name>/.claude-plugin/plugin.json`** — same `name` + `version` (must stay in sync, validator enforces).

**`plugins/<name>/skills/starter/SKILL.md`** — minimal valid skill with proper frontmatter.

**If `--with-hooks`**: `hooks/hooks.json` registering `on-edit.sh` to PostToolUse `Edit|Write` matcher; script gates with `[ "${<NAME>_AUTO:-0}" = "1" ] || exit 0` (opt-in pattern).

**If `--with-mcp`**: `mcp/server.py` + `.mcp.json` referencing `${CLAUDE_PLUGIN_ROOT}/mcp/server.py`. Document that Cursor/Cline don't auto-discover (per Track 3 review).

**`scripts/validate_skills.py`** — port from vibesubin: schema validate frontmatter, check version sync between manifests, check description length, check hooks executable.

**`.github/workflows/validate.yml`** — runs validator on push and PR.

**`.github/workflows/release.yml`** — runs on `v*.*.*` tag push: validate + manifest sync check + GH release.

### 4. Initialize git + remote (if not already in a repo)

```bash
[ -d .git ] || git init
git add . && git commit -m "chore: scaffold plugin <name>"
# DO NOT push automatically — leave for user
```

### 5. Print next steps
```
✓ Plugin scaffolded at <path>
Next:
1. cd <plugin-name>
2. Edit plugins/<name>/skills/starter/SKILL.md with real content
3. python3 scripts/validate_skills.py    # should pass
4. gh repo create <plugin-name> --public --source=. --remote=origin
5. git push -u origin main
6. git tag v0.1.0 && git push --tags     # triggers release workflow
```

## Constraints

- Default — DO NOT push to GitHub automatically (HARD: user must explicitly run the push)
- Default — DO NOT add the plugin to the user's `~/.claude/settings.json` `enabledPlugins` (separate manual step after testing)
- DO NOT scaffold over an existing non-empty plugin directory without explicit `--force`
- Korean response per global CLAUDE.md
