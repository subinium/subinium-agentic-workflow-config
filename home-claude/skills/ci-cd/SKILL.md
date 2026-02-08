---
name: ci-cd
description: Generate and manage CI/CD pipelines — GitHub Actions, lint/test/build/deploy automation for npm/pip/pnpm projects. Use when asked to set up CI, create a pipeline, add GitHub Actions, automate tests, or configure continuous deployment
author: subinium
user-invocable: true
disable-model-invocation: true
args: target (github-actions | check | fix)
---

# CI/CD Pipeline

Generate and manage CI/CD pipelines for your project.

## Usage
```
/ci-cd github-actions    # Generate GitHub Actions workflow
/ci-cd check             # Audit existing CI/CD config
/ci-cd fix               # Fix failing CI/CD issues
```

---

## Step 1: Project Detection (Auto)

Before generating anything, detect the project stack:

```bash
# Package manager
ls package.json pnpm-lock.yaml yarn.lock bun.lockb Pipfile pyproject.toml requirements.txt setup.py 2>/dev/null

# Framework
grep -l "next" package.json 2>/dev/null          # Next.js
grep -l "react" package.json 2>/dev/null          # React
grep -l "fastapi\|flask\|django" pyproject.toml requirements.txt 2>/dev/null  # Python web

# Existing CI
ls .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null
ls .gitlab-ci.yml Jenkinsfile .circleci/config.yml 2>/dev/null
```

Detected info:
- **Language**: TypeScript / Python / Both
- **Package Manager**: npm / pnpm / yarn / bun / pip / uv / poetry
- **Framework**: Next.js / React / FastAPI / Django / None
- **Test Runner**: jest / vitest / pytest / none
- **Linter**: eslint / biome / ruff / none
- **Existing CI**: yes / no

---

## Step 2: GitHub Actions (`/ci-cd github-actions`)

### Node.js / TypeScript Template

Generate `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint-and-typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: '{DETECTED_PM}'   # npm | pnpm | yarn
      - run: {INSTALL_CMD}         # npm ci | pnpm install --frozen-lockfile
      - run: {LINT_CMD}            # npm run lint
      - run: npx tsc --noEmit

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: '{DETECTED_PM}'
      - run: {INSTALL_CMD}
      - run: {TEST_CMD}            # npm run test -- --coverage

  build:
    runs-on: ubuntu-latest
    needs: [lint-and-typecheck, test]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: '{DETECTED_PM}'
      - run: {INSTALL_CMD}
      - run: {BUILD_CMD}           # npm run build
```

### Adaptation Rules

- **pnpm**: Add `pnpm/action-setup@v4` step, cache: `pnpm`
- **yarn**: cache: `yarn`, `yarn install --frozen-lockfile`
- **bun**: Use `oven-sh/setup-bun@v2`, `bun install --frozen-lockfile`
- **monorepo (turbo)**: Use `turbo run lint test build --filter=...[origin/main]`
- **Next.js**: Add build cache `~/.next/cache`, use `actions/cache@v4`

### Python Template

Generate `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: pip
      - run: pip install ruff
      - run: ruff check .
      - run: ruff format --check .

  typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: pip
      - run: pip install -e ".[dev]"
      - run: mypy .

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: pip
      - run: pip install -e ".[dev]"
      - run: pytest --cov --cov-report=xml

  build:
    runs-on: ubuntu-latest
    needs: [lint, typecheck, test]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install build
      - run: python -m build
```

### Adaptation Rules

- **uv**: Use `astral-sh/setup-uv@v5`, `uv sync`, `uv run pytest`
- **poetry**: Use `snok/install-poetry@v1`, `poetry install --no-interaction`
- **Django**: Add service container for PostgreSQL, set `DATABASE_URL`
- **FastAPI**: Add health check step after build

---

## Step 3: Optional CD (Deployment)

If the user wants continuous deployment, add a deploy job:

### Vercel (Next.js)
```yaml
  deploy:
    runs-on: ubuntu-latest
    needs: [build]
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

### Docker (any)
```yaml
  deploy:
    runs-on: ubuntu-latest
    needs: [build]
    if: github.ref == 'refs/heads/main'
    permissions:
      packages: write
    steps:
      - uses: actions/checkout@v4
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          push: true
          tags: ghcr.io/${{ github.repository }}:latest
```

### PyPI (Python package)
```yaml
  publish:
    runs-on: ubuntu-latest
    needs: [build]
    if: startsWith(github.ref, 'refs/tags/v')
    permissions:
      id-token: write
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install build
      - run: python -m build
      - uses: pypa/gh-action-pypi-publish@release/v1
```

---

## Step 4: Extras (Ask user if needed)

| Extra | When to Add |
|-------|-------------|
| **Dependabot** | Always recommend → `.github/dependabot.yml` |
| **CodeQL** | If public repo → `.github/workflows/codeql.yml` |
| **Release Please** | If the project uses semver → auto changelog + version bump |
| **Preview Deployments** | If Vercel/Netlify → comment PR with preview URL |
| **Matrix Testing** | If library → test across Node 18/20/22 or Python 3.10/3.11/3.12 |

### Dependabot Template
```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"    # or pip
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      dev-dependencies:
        dependency-type: "development"
```

---

## `/ci-cd check` — Audit Existing CI/CD

Read existing workflow files and check:

- [ ] `concurrency` set (prevents duplicate runs)
- [ ] Lock file used for install (`--frozen-lockfile`, `npm ci`)
- [ ] Cache configured for dependencies
- [ ] Lint + typecheck + test all present
- [ ] Build runs after tests pass (`needs:`)
- [ ] Secrets not hardcoded in workflow
- [ ] `cancel-in-progress: true` for PR workflows
- [ ] Node/Python version pinned (not `latest`)
- [ ] `actions/*` pinned to major version (v4, not `main`)

## `/ci-cd fix` — Fix Failing CI

1. Read the failing workflow run: `gh run view --log-failed`
2. Identify the error category:
   - **Dependency**: lock file mismatch, missing package
   - **Lint**: auto-fix with `npm run lint -- --fix` then commit
   - **Type**: read error, trace to source, fix
   - **Test**: read failure, debug with `/systematic-debugging`
   - **Build**: check env vars, config
3. Fix and push, verify with `gh run watch`

