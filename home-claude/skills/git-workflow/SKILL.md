---
name: git-workflow
description: Git workflow commands — commit with Conventional Commits, create PRs, clean up merged branches. Use when asked to commit, make a PR, or tidy branches
author: subinium
user-invocable: true
disable-model-invocation: true
args: command (commit | pr | branch-cleanup)
---

# Git Workflow

Run the subcommand specified in `$ARGUMENTS`.

## Commands

### `commit` (default if no argument given)

Create a well-formatted conventional commit:

1. Run `git status` and `git diff --staged` to see what's staged
2. If nothing staged, ask the user what to stage
3. Analyze the changes and determine the commit type:
   - `feat:` — new feature
   - `fix:` — bug fix
   - `refactor:` — code restructuring (no behavior change)
   - `docs:` — documentation only
   - `chore:` — build, deps, config
   - `test:` — adding or fixing tests
   - `style:` — formatting (no logic change)
   - `perf:` — performance improvement
4. Draft a commit message:
   - Format: `type(scope): short description`
   - Scope is optional, use when helpful (e.g., `feat(auth): add OAuth login`)
   - Description: imperative mood, lowercase, no period
   - Add body only if the "why" isn't obvious from the description
5. Show the proposed message to the user for approval
6. Create the commit

### `pr`

Create a pull request:

1. Run `git log main..HEAD` (or master) to see all commits on the branch
2. Run `git diff main...HEAD` to see all changes
3. Draft a PR with:
   - Title: short summary (under 70 chars)
   - Body:
     ```
     ## Summary
     - Bullet points of changes

     ## Test plan
     - [ ] How to test these changes
     ```
4. Show the proposed PR to the user for approval
5. Push the branch and create the PR with `gh pr create`

### `branch-cleanup`

Clean up merged branches:

1. Run `git branch --merged main` (or master) to find merged branches
2. Exclude `main`, `master`, `develop`, and the current branch
3. Show the list of branches to delete
4. Ask the user for confirmation
5. Delete confirmed branches with `git branch -d`
6. Optionally run `git remote prune origin` to clean up stale remote refs
