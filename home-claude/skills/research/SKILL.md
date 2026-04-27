---
name: research
description: Parallel research, comparative audit, or capability transfer analysis on multiple topics, tools, repos, codebases, or frameworks with structured comparison, parity, or feature-harvesting output. Use when asked to research, compare, analyze, audit, extract capabilities, or transfer the best parts of one project into another
author: subinium
user-invocable: true
disable-model-invocation: true
args: Comma-separated list of topics or projects to research
---

# Parallel Research

Research multiple topics or targets and produce a structured comparison.

This skill has three modes:

1. **General comparison mode**: compare tools, products, libraries, companies, or frameworks
2. **Parity / capability extraction mode**: compare codebases, ports, forks, SDKs, or frameworks and extract what is truly implemented, what is only claimed, and what is still missing
3. **Capability transfer / harvesting mode**: identify the strongest ideas, behaviors, patterns, or subsystems in one project and determine what should be copied, adapted, or avoided in another project

## Usage
```
/research Topic A, Topic B, Topic C
/research Svelte, SolidJS, Qwik
/research OMO, OMC, OMX
```

## Instructions

### 1. Parse Topics
Extract the list of research targets from `$ARGUMENTS`. If no arguments given, ask the user for topics (max 1 question).

### 2. Decide Comparison Mode

Use **parity / capability extraction mode** when any of these are true:

- The user asks whether one repo/framework/port has truly implemented another's features
- The user asks what was migrated, ported, or translated from one codebase to another
- The user asks for gaps, missing behavior, or "how complete" an implementation is
- The user wants a rubric, matrix, or diagram showing feature depth instead of a marketing comparison
- The user refers to source code, tests, architecture, or implementation details

Use **capability transfer / harvesting mode** when any of these are true:

- The user wants to bring the best parts of one project into another
- The user asks what should be copied, adapted, borrowed, or ported
- The user wants "good ideas only", "strengths only", or "what is worth transferring"
- The user is designing a successor, rewrite, port, fork, or framework influenced by another system
- The user wants reusable patterns, not just a scorecard

Otherwise use **general comparison mode**.

### 3. Gather Evidence First

Always prefer the strongest evidence available:

1. Local code and tests, if a repo is present
2. Official docs, READMEs, changelogs, and source repositories
3. Maintainer-authored materials
4. Community discussion only as secondary evidence

For codebase comparisons:

- Read source, tests, and architecture docs before summarizing
- Distinguish **implemented behavior** from **README claims**
- Distinguish **surface feature presence** from **behavioral depth**
- Distinguish **tested parity slice** from **full-system parity**
- Quote exact file paths, symbols, routes, and tests where possible

For capability transfer / harvesting work:

- Identify what makes the source capability good, not just that it exists
- Identify the hidden supporting conditions that make it work
- Separate **portable idea** from **source-specific implementation**
- Distinguish what should be **copied**, **adapted**, **reinterpreted**, or **left behind**
- Look for coupling, assumptions, operational constraints, and regression risks

### 4. Use Parallel Agents When It Actually Helps

If the environment supports real sub-agents and the targets are independent, spawn one agent per topic or target.

For each target, ask for:

```
Agent per topic:
- Research: overview, architecture, key features, and evidence-backed strengths/weaknesses
- Find: the most relevant primary sources
- Identify: unique differentiators and important caveats
- Return structured markdown with headers and bullet points
```

For parity / capability extraction mode, ask each agent to return:

```
- Advertised capabilities
- Concrete implementation artifacts
- Test or runtime evidence
- Missing or weaker behavior
- Confidence level per claim
```

For capability transfer / harvesting mode, ask each agent to return:

```
- Source strengths worth preserving
- Why each strength is genuinely valuable
- Concrete implementation anchors
- Dependencies, constraints, and hidden coupling
- Transfer recommendation: copy / adapt / rethink / avoid
- Expected benefits and likely failure modes after transfer
```

**CRITICAL**:

- Every agent must be actually spawned if the tool/runtime supports it
- Never fake or hallucinate agent results
- If agent spawning is unavailable, continue in a single lane and say so implicitly via output quality, not excuses

### 5. Wait for All Agents
Wait for all background agents to complete. Do NOT proceed until all results are in.

### 6. Synthesize Results
Compile findings into a structured comparison:

```markdown
## Research Report: [Topic List]

### Executive Summary
[2-3 sentence overview of the comparison]

### Comparison Table

| Aspect | Topic A | Topic B | Topic C |
|--------|---------|---------|---------|
| Architecture | ... | ... | ... |
| Key Features | ... | ... | ... |
| Community Size | ... | ... | ... |
| Latest Release | ... | ... | ... |
| Strengths | ... | ... | ... |
| Weaknesses | ... | ... | ... |

### Detailed Analysis

#### Topic A
[3-5 bullet points of key findings]

#### Topic B
[3-5 bullet points of key findings]

#### Topic C
[3-5 bullet points of key findings]

### Recommendation
[Which to choose and why, based on findings]

### Sources
[List of URLs referenced]
```

For parity / capability extraction mode, prefer this structure instead:

```markdown
## Comparative Capability Audit: [Target A] vs [Target B]

### Verdict
[Short answer: how complete the implementation/port actually is]

### Capability Matrix

| Capability | Reference Target | Compared Target | Evidence | Status |
|------------|------------------|-----------------|----------|--------|
| Agent loop | ... | ... | file/tests/docs | strong / partial / weak / absent |
| Memory | ... | ... | file/tests/docs | ... |
| Session search | ... | ... | file/tests/docs | ... |
| Delegation | ... | ... | file/tests/docs | ... |
| Compression | ... | ... | file/tests/docs | ... |
| Scheduler | ... | ... | file/tests/docs | ... |
| Runtime backends | ... | ... | file/tests/docs | ... |
| Trajectory / training | ... | ... | file/tests/docs | ... |

### Depth Gaps
- [Where the compared target has a feature name but not the same implementation depth]

### Verified Strengths
- [What is genuinely strong and supported by code/tests]

### Recommended Improvements
1. [Highest-leverage improvement]
2. [Second]
3. [Third]

### Sources
- [file path, test, or URL]
```

For capability transfer / harvesting mode, prefer this structure instead:

```markdown
## Capability Harvest Report: [Source] -> [Target]

### Goal
[What the target project is trying to inherit or improve]

### Harvest Matrix

| Source Capability | Why It Is Good | Implementation Anchors | Hidden Dependencies | Transfer Mode | Recommendation |
|-------------------|----------------|-------------------------|---------------------|---------------|----------------|
| ... | ... | file/tests/docs | ... | copy / adapt / rethink / avoid | ... |

### Best Parts To Preserve
- [High-value behaviors or patterns]

### What Must Be Adapted
- [Things that are good but tightly coupled to the source system]

### What Should Not Be Carried Over
- [Source-specific baggage, debt, or misleading abstractions]

### Transfer Plan
1. [First subsystem to import or reproduce]
2. [Second]
3. [Third]

### Risks
- [Coupling, performance, maintenance, team-fit, runtime-fit, architectural mismatch]

### Sources
- [file path, test, or URL]
```

### 7. Special Rules for Capability Extraction

When comparing repos, frameworks, or ports:

- Build the matrix around **behavioral subsystems**, not marketing bullets
- Prefer axes like:
  - agent loop
  - tool execution
  - memory and recall
  - session search
  - skill/learning loop
  - delegation/subagents
  - context compression
  - scheduler/delivery
  - runtime backends
  - observability
  - security
  - trajectory/training
- For each axis, explicitly classify:
  - **Claimed**
  - **Implemented**
  - **Verified**
  - **Parity depth**
- If tests only cover a narrow parity slice, say so clearly
- Do not over-credit a target for having the same nouns with weaker internals
- When relevant, separate:
  - **feature surface**
  - **implementation depth**
  - **production durability**
  - **migration completeness**

### 8. Special Rules for Capability Transfer / Harvesting

When the goal is to bring strengths from one project into another:

- Evaluate the **reason a capability is good**, not just the capability label
- Capture:
  - the user-visible advantage
  - the implementation mechanism
  - the enabling assumptions
  - the target-side adaptation cost
- Prefer outputs framed as:
  - **copy as-is**
  - **copy with adaptation**
  - **re-implement conceptually**
  - **do not import**
- Ask whether the source strength depends on:
  - runtime model
  - team workflow
  - storage model
  - test discipline
  - tool ecosystem
  - operational scale
- If a source feature is only good because of adjacent infrastructure, say so explicitly
- Do not recommend transferring isolated surface features without their supporting invariants
- Look for "good because of X" and "breaks without Y"

### 9. What to Avoid

- Do not default to stars, contributor count, or community metrics when the user asked about implementation fidelity
- Do not treat README feature lists as ground truth
- Do not collapse "present but simplified" into "fully supported"
- Do not hide uncertainty; mark it as low-confidence when evidence is thin
- Do not confuse inspiration harvesting with 1:1 cloning
- Do not recommend importing a capability without noting its coupling and adaptation cost

## Rules
- Use **real** parallel sub-agents when the environment supports them and the work is independent
- Each agent gets one topic or target when parallelized — no monolithic agent researching everything
- For broad external comparisons: prefer 3-7 parallel agents
- For repo parity audits: use fewer agents if evidence integration is the hard part
- If a topic is ambiguous, make a reasonable assumption and note it
- Do NOT ask the user clarifying questions beyond the initial topic list
- Output must include a comparison table or capability matrix — this is the primary deliverable
- In parity mode, evidence beats breadth
- In parity mode, file paths, tests, and implementation caveats are more important than popularity metrics
- In transfer mode, explain why a capability is worth porting and what conditions make it work
