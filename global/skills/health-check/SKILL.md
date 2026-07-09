---
name: health-check
description: >
  Run or propose project health checks — lint, typecheck, unit/integration tests,
  build, formatting, dead code, dependency risk, flaky tests, basic security. Use
  for a quick "is this project in good shape?", before a release, or after
  inheriting a codebase. Runs if possible, else proposes.
---

## Tool contract — READ-ONLY

Investigate and report. Does not modify files. Runs read-only commands only —
does not install packages, deploy, or mutate state.

## How to work

1. **Check for a health script**: If `~/.claude/scripts/health-check.sh` exists,
   run it and use its output as the primary input. Parse results into the output
   format below. The script automatically covers (all tool-gated and
   stack-detected):
   - Lint, typecheck, test, build (Node, Python, Go, Rust)
   - Dependency audit: `npm audit`/`pnpm audit`/`yarn audit` (Node),
     `pip-audit` (Python), `cargo audit` (Rust), `govulncheck` (Go)
   - Format check: `prettier --check` (Node), `black --check` (Python),
     `gofmt -l` (Go), `cargo fmt --check` (Rust)
   - Dead-code: `knip`/`ts-prune` (Node), `vulture` (Python); Go/Rust dead-code
     is skipped-with-note (no standard single-binary tool scripted — model-driven
     only)
   - Secret scan: `gitleaks` or `trufflehog` if installed; skipped-with-install-
     hint otherwise

2. **Detect the stack**: Read `package.json`, `pyproject.toml`, `Cargo.toml`,
   `go.mod`, `.github/workflows/`, or equivalent CI config. Identify what tools
   are configured.

3. **Supplement scripted output with model-driven checks**: After parsing the
   script output, run or propose additional checks not covered by the script:
   - Lint: `eslint`, `ruff`, `clippy`, etc. (if not already run by the script)
   - Dead code for Go/Rust: `staticcheck`, `unused`, `cargo +nightly rustc -- -W dead-code`
   - Flaky test detection: look for `.skip`, `xfail`, commented-out tests
   - CI gap analysis: compare what runs locally vs what runs in CI

4. **If execution is not possible**: Propose the specific commands that should be
   run, based on the detected stack. Do not invent checks that have no basis in
   the project config.

5. **Score 0–10**: 10 = all checks pass with no warnings, CI covers everything,
   no dependency risk. Deduct for each failing category proportionally.

6. **Flag flaky tests**: Look for tests marked `.skip`, `xfail`, `TODO`, or known
   to be commented out.

7. **Flag CI gaps**: Compare what runs locally to what runs in CI. Note anything
   that is checked locally but not in CI, or vice versa.

## Output format

```markdown
# Project Health Check

## Score
X/10 — <one sentence explaining the score>

## Passing checks
- Lint: clean (`eslint src/` — 0 errors)
- ...

## Failing checks
- Typecheck: 3 errors (`tsc --noEmit` — see `src/api/handler.ts:42`)
- ...

## Missing checks
- No dead-code detection configured
- No dependency vulnerability scan in CI
- ...

## Top fixes
1. Fix typecheck errors in `src/api/handler.ts:42` — blocking
2. Add `npm audit` to CI pipeline
3. ...

## Recommended CI additions
- [ ] `npm audit --audit-level=high` on every PR
- [ ] Typecheck as a required status check
- [ ] ...
```
