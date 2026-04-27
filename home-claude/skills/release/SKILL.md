---
name: release
description: Full release pipeline — version bump across all files, branch + PR, tag, GitHub release with structured notes. Supports dual-stack projects (Node + Rust). Use when asked to release, cut a release, bump version, or publish a new version.
author: subinium
user-invocable: true
disable-model-invocation: true
args: version (e.g. v0.7.0) [--dry-run] [--skip-homebrew] [--with-announcement]
---

# Release

Universal release pipeline. Auto-detects project type and adapts.

## Usage
```
/release v0.7.0                        # Full release pipeline
/release v0.7.0 --dry-run              # Validate only, no git ops
/release v0.7.0 --skip-homebrew        # Skip tap update
/release v0.7.0 --with-announcement    # Also draft announcement posts
```

---

## Step 0: Project Detection (AUTO — do this FIRST)

Detect the project type by checking files at the workspace root:

```bash
ls package.json Cargo.toml pyproject.toml 2>/dev/null
```

### Classification

| Detected Files | Type | Example |
|---|---|---|
| `package.json` + `tui/Cargo.toml` | **hybrid** (Node + Rust) | ddudu |
| `Cargo.toml` only | **rust** | agf |
| `package.json` only | **node** | — |
| `pyproject.toml` only | **python** | — |

### Per-Type: Version Files to Bump

**hybrid** (Node + Rust):
```
package.json                    → "version": "X.Y.Z"
package-lock.json               → "version": "X.Y.Z" (2 locations)
tui/Cargo.toml                  → version = "X.Y.Z"
tui/Cargo.lock                  → ddudu-tui version = "X.Y.Z"
src/tui/native/controller.ts    → PROMPT_VERSION (grep PROMPT_VERSION)
src/mcp/client.ts               → clientInfo.version (grep "version:")
```

**rust**:
```
Cargo.toml                      → version = "X.Y.Z"
Cargo.lock                      → package version = "X.Y.Z"  (MUST be committed)
```
Also check for workspace members (e.g., `crates/*/Cargo.toml`) that depend on the main crate — bump those too.

**node**:
```
package.json                    → "version": "X.Y.Z"
package-lock.json               → "version": "X.Y.Z" (2 locations)
```

### Per-Type: Pre-Gate Commands

**hybrid**:
```bash
node scripts/transpile-runner.cjs          # JS transpile
cargo build --manifest-path tui/Cargo.toml --release  # Rust build
node scripts/run-node-tests.cjs            # JS tests
cargo test --manifest-path tui/Cargo.toml  # Rust tests
```

**rust**:
```bash
cargo check                    # Fast compile check
cargo test                     # All tests
cargo clippy -- -D warnings    # Lint (if clippy available)
```

**node**:
```bash
npm run typecheck               # or: npx tsc --noEmit
npm run lint                    # or: npx biome check src/
npm test                        # Tests
```

### Per-Type: Homebrew Formula Style

**hybrid** (source build — needs Node + Rust at install time):
```ruby
depends_on "node@22"
depends_on "rust" => :build

def install
  system "npm", "install", "--ignore-scripts"
  system "node", "scripts/transpile-runner.cjs"
  system "cargo", "build", "--release", "--manifest-path", "tui/Cargo.toml"
  mkdir_p "dist/tui"
  cp "tui/target/release/ddudu-tui", "dist/tui/ddudu-tui"
  libexec.install Dir["*"]
  (bin/"ddudu").write_env_script libexec/"dist/index.js",
    PATH: "#{Formula["node@22"].opt_bin}:$PATH"
end
```

**rust** (pre-built binary — release assets contain compiled binaries):
```ruby
on_macos do
  if Hardware::CPU.arm?
    url "https://github.com/OWNER/REPO/releases/download/v#{version}/BINARY-aarch64-apple-darwin.tar.gz"
    sha256 "SHA"
  else
    url "https://github.com/OWNER/REPO/releases/download/v#{version}/BINARY-x86_64-apple-darwin.tar.gz"
    sha256 "SHA"
  end
end
on_linux do
  url "https://github.com/OWNER/REPO/releases/download/v#{version}/BINARY-x86_64-unknown-linux-gnu.tar.gz"
  sha256 "SHA"
end

def install
  bin.install "BINARY_NAME"
end
```

---

## Step 1: Pre-Gate (HARD GATE)

Run the per-type pre-gate commands. ALL must pass.

```bash
# Also verify CI green and clean tree
git status --short              # must be empty
git branch --show-current       # must be main
gh run list --branch main --limit 3  # CI should be green
```

### Version Number Rule (CRITICAL)
- **Use EXACTLY the version the user specifies.** Never override based on semver theory.
- If you think a different version is more appropriate, mention it in ONE sentence but proceed with the user's version.
- Example: User says "0.17.1" → use 0.17.1, even if you think it should be 0.18.0.

### Git State Verification
Before any git operations, verify refs are clean:
```bash
# Check for corrupted tag refs
git fsck --no-dangling 2>&1 | head -5
# If errors found, fix before proceeding (e.g., remove bad refs)
```

**If ANY check fails → STOP. Fix first. Never release broken code.**

---

## Step 2: Version Bump

Bump ALL per-type version files. Then verify:

```bash
# Must return ZERO matches for old version
grep -rn "OLD_VERSION" <all version files>

# Must return matches for new version in ALL files
grep -rn "NEW_VERSION" <all version files>
```

---

## Step 3: Branch + PR + CI Gate + Merge

```bash
# Branch
git checkout -b release/vX.Y.Z

# Stage ALL version files INCLUDING Cargo.lock
# CRITICAL: Always run `cargo check` to update Cargo.lock, then stage it
cargo check  # ensures Cargo.lock reflects new version
git add <all version files> Cargo.lock
git commit -m "chore: release vX.Y.Z"
git push -u origin release/vX.Y.Z

# PR — use "Closes #N" syntax for auto-closing issues
gh pr create --title "chore: release vX.Y.Z" --body "$(cat <<'EOF'
## Release vX.Y.Z
### Version files updated
<list of files>
### Changes since last release
$(git log $(git tag --sort=-creatordate | head -1)..HEAD --oneline)

Closes #<issue numbers if applicable>
EOF
)"

# Wait for CI
gh pr checks <PR_NUMBER> --watch
# If CI fails 3x → STOP, escalate

# Merge
gh pr merge <PR_NUMBER> --squash --delete-branch --admin
git checkout main && git pull origin main
```

### Issue Closing
- Squash merge may strip `Closes #N` from the body. After merge, verify:
  ```bash
  gh issue list --state open --limit 10
  ```
- If issues weren't auto-closed, close them manually:
  ```bash
  gh issue close <N> --comment "Resolved in vX.Y.Z"
  ```

---

## Step 4: Tag & GitHub Release

### Pre-Tag Checklist (CRITICAL)
```bash
# 1. Verify working tree is CLEAN (including Cargo.lock)
git status --short  # must be empty — if Cargo.lock is dirty, commit it first

# 2. Verify you are on main with the merged commit
git log --oneline -1  # should show the squash-merge commit

# 3. Check for CI Release workflow BEFORE publishing locally
gh workflow list | grep -i release
# If a Release workflow exists that runs `cargo publish`:
#   → Do NOT run `cargo publish` locally
#   → Let CI handle it after tag push
#   → Only publish locally if CI doesn't have a publish step
```

```bash
git tag vX.Y.Z
git push --tags
```

### Publish Decision (Rust crates)
```bash
# Check if CI publishes automatically on tag push
cat .github/workflows/release.yml | grep -A5 "cargo publish" 2>/dev/null
```
- **CI has `cargo publish`** → Wait for CI. Do NOT run `cargo publish` locally.
  Verify with: `gh run list --workflow=Release --limit 1`
- **CI does NOT publish** → Run `cargo publish` locally after tag push.
- **NEVER both** — double publish causes `crate already exists` errors.

Generate structured release notes:

```bash
PREV_TAG=$(git tag --sort=-creatordate | sed -n '2p')
git log ${PREV_TAG}..HEAD --oneline
```

Group by conventional commit type (feat/fix/perf/docs/test). Skip `chore:`.

```bash
gh release create vX.Y.Z --title "vX.Y.Z" --notes "$(cat <<'EOF'
## vX.Y.Z
### Features
- ...
### Bug Fixes
- ...
EOF
)"
```

### For **rust** projects: upload pre-built binaries as release assets
```bash
# If CI produces binaries (check .github/workflows/ for artifact upload)
# OR build locally:
cargo build --release
gh release upload vX.Y.Z target/release/BINARY_NAME
```

---

## Step 5: Homebrew Tap Update (skip with `--skip-homebrew`)

Tap repo: `subinium/homebrew-tap` (local: `~/Desktop/github/homebrew-tap`)

### For **hybrid** (source build):
```bash
# Get sha256 of source tarball
SHA=$(curl -sL https://github.com/OWNER/REPO/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256 | cut -d' ' -f1)

# Update formula version + sha256 → upload via GitHub API
gh api repos/subinium/homebrew-tap/contents/Formula/FORMULA.rb \
  -X PUT \
  -f message="chore: update FORMULA to vX.Y.Z" \
  -f content="$(base64 < FORMULA_FILE | tr -d '\n')" \
  -f sha="$(gh api repos/subinium/homebrew-tap/contents/Formula/FORMULA.rb --jq '.sha')" \
  -f branch=main
```

### For **rust** (pre-built binary):
```bash
# Get sha256 for EACH platform binary from release assets
SHA_AARCH64=$(curl -sL https://github.com/OWNER/REPO/releases/download/vX.Y.Z/BINARY-aarch64-apple-darwin.tar.gz | shasum -a 256 | cut -d' ' -f1)
SHA_X86=$(curl -sL https://github.com/OWNER/REPO/releases/download/vX.Y.Z/BINARY-x86_64-apple-darwin.tar.gz | shasum -a 256 | cut -d' ' -f1)
SHA_LINUX=$(curl -sL https://github.com/OWNER/REPO/releases/download/vX.Y.Z/BINARY-x86_64-unknown-linux-gnu.tar.gz | shasum -a 256 | cut -d' ' -f1)

# Update formula with all 3 sha256 values + version → upload via gh api
```

**NOTE**: Always use `gh api` to upload formula directly. Avoids git push issues with the tap repo.

---

## Step 6: Post-Release Verification

```bash
gh release view vX.Y.Z
<binary> --version              # should match X.Y.Z

# Verify no stale versions
grep -rn "OLD_VERSION" <all version files>
```

---

## Step 7: Announcement Drafts (with `--with-announcement`)

Draft only — do NOT publish without user confirmation.

### LinkedIn
```
Released <tool> vX.Y.Z.

Key changes:
- [feature 1]
- [feature 2]

Source: https://github.com/OWNER/REPO
```

### Hacker News / GeekNews
```
Show HN: <Tool Name> vX.Y.Z — <one-line description>

<2-3 sentences>

GitHub: https://github.com/OWNER/REPO
```

---

## Failure Handling

| Failure | Action |
|---------|--------|
| Pre-gate fails | Stop. Fix first. |
| CI fails on release PR | Fix on release branch. Max 3 attempts. |
| Missing version file | Add to checklist, fix, amend. |
| CI fails after tag | Hotfix → patch release vX.Y.Z+1 |
| Wrong version in binary | Delete tag, fix, re-tag. |
| Homebrew push fails | Use `gh api` (already default). |
| Unknown project type | Ask user for version files + build commands. |
| `crate already exists` on CI | Local `cargo publish` conflicted with CI Release workflow. Not a real failure — crate is published. |
| Cargo.lock dirty after tag | Commit lockfile BEFORE tagging. Never tag with dirty tree. |
| Squash merge didn't close issues | Close manually with `gh issue close <N>`. |
| Corrupted git refs | Run `git fsck`, remove bad refs from `.git/refs/`. |

---

## Summary Report

| Step | Status | Detail |
|------|--------|--------|
| Detection | — | hybrid / rust / node |
| Pre-gate | ✓/✗ | build, tests, CI |
| Version bump | ✓ | N files |
| PR + CI gate | ✓ | PR URL |
| Merge | ✓ | squash |
| Tag | ✓ | vX.Y.Z |
| GitHub release | ✓ | URL + assets |
| Homebrew tap | ✓/skipped | formula URL |
| Post-release | ✓ | `--version` output |
| Announcements | ready/skipped | |
