---
name: ci-watch
description: >
  Check CI status for the current PR, tail failing job logs, and propose (not
  auto-apply) a fix. Use for "check CI", "is the PR green", "CI failing", "fix
  failing CI", "watch the build", "why is CI red". Read-only by default — asks
  before any state-changing action (rerun, push).
---

## Tool contract — READ-ONLY by default

Investigate and report. Does not push code or rerun jobs without explicit
confirmation. Any state-changing action (`gh run rerun`, `git push`) requires
an ask-first gate before execution.

## How to work

### Step 1 — Resolve the PR

Run `gh pr view --json number,headRefName,url` to confirm the current branch has
an open PR. If no PR is found, report that and stop.

### Step 2 — Get per-job status

Run `gh pr checks` to list every CI job and its status (pass / fail / pending /
skipped). If all jobs pass, report green and stop.

### Step 3 — Fetch logs for failing jobs

For each failing job, get its run ID and fetch the failure log:

- `gh run list --branch <branch> --json databaseId,name,status,conclusion` to
  map job names to run IDs.
- `gh run view <run-id> --log-failed` to pull only the failing step output.

Extract the failing step name and the first meaningful error line. Ignore
boilerplate setup output (checkout, cache restore, etc.) — focus on the step
where the actual failure originates.

### Step 4 — Root-cause non-obvious failures

If the error is immediately obvious (e.g., a lint rule naming a file and line,
a test assertion with a clear message, a missing env var), note it directly.

For non-obvious failures — where the log excerpt alone does not indicate a clear
fix — dispatch the `debugger` agent with the log excerpt and context:

> "This CI job failed. Log excerpt: [paste relevant lines]. The repo is
> [language/stack]. Root-cause the failure and propose a fix."

Do not guess when the error is ambiguous. Delegate to `debugger` and surface its
finding.

### Step 5 — Classify and report

Present a concise failure summary. Distinguish between:

- **Flake** — intermittent/network/timing failure with no code-change signal
  (e.g., timeout on external service, race in test setup, GitHub infra blip).
  Proposed action: rerun the job.
- **Real failure** — the log shows a deterministic error caused by code, config,
  or a missing secret. Proposed action: describe the specific fix needed.

### Step 6 — Ask before any state-changing action

This is a hard gate. Never rerun a job or push a fix without an explicit
confirmation from the user.

For a flake, present: "This looks like a flake. Proposed action: rerun job
`<name>` (`gh run rerun <id> --failed`). Confirm?" Then wait.

For a real failure, present the proposed fix (file, change description) and ask
the user to confirm before applying it. After the fix is applied locally, remind
the user to push — do not push automatically.

## Output format

```
## CI status — <branch> / PR #<N>

### Failing jobs
- <job-name>: FAILED
  Step: <step-name>
  Error: <first meaningful error line>
  Classification: flake | real failure
  Proposed fix: <one sentence>

### Passing jobs
- <list of passing job names>

### Proposed actions
- [ ] <specific action with the exact command or change, pending confirmation>
```

If all jobs pass: "CI is green for PR #N — all <X> checks passed."

## What this skill does NOT do

- Does not push code or open PRs.
- Does not auto-rerun jobs.
- Does not modify any file without showing the proposed change and getting
  confirmation first.
- Does not replace `health-check` (local checks) — this skill is for remote CI
  status only.
