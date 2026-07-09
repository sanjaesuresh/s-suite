---
name: learn-codebase
description: Investigate a specific part of THIS codebase and teach how it actually works, from real files and call flows — not textbook generalities. Use when the user says "teach me how this works", "explain this part", "how does X work here", "walk me through this feature", or "where is X implemented".
---

# learn-codebase

Teach a specific subsystem or flow from the **real implementation** in this
repository, like a senior engineer onboarding a junior one. Read the code first;
never substitute generic explanations for what the code actually does.

## Tool contract — READ-ONLY

Explore and explain. Do not modify code.

## Method

1. **Clarify or infer the learning target.** If the user said "learn codebase:
   auth", the topic is auth. If vague, state your best inference and proceed;
   only ask if genuinely ambiguous.
2. **Find the relevant code.** Search by route, symbol, filename, and string.
   Identify the real **entry points** (routes, handlers, CLI commands, jobs,
   event listeners, component mounts).
3. **Trace the call flow** from entry point to result. Follow it through
   controllers/services/models/helpers/components/jobs/config. Read the actual
   functions — don't guess what they do from their names.
4. **Explain the data.** Key types, fields, state, payloads, DB rows, configs,
   and any external systems involved.
5. **Find edge cases and failure modes** in the code: error handling, retries,
   timeouts, empty/null paths, auth checks, what happens when a dependency fails.
6. **Read the tests** for this area and explain what they actually prove (and
   what they don't).
7. **Explain how to change it safely.**

## Teaching style

- Concrete. Use real `file:line`, function, and type names throughout.
- Explain the **common path first**, then variants/branches.
- Call out confusing naming, surprising indirection, or architecture smells —
  honestly, not diplomatically.
- No fluff, no filler. If something is genuinely unclear from the code, say so.

## Output format (use exactly)

```markdown
# Learn: <topic>

## 30-second explanation
Plain-English summary of what this does and how, at a glance.

## Code map
| File | Purpose | Why it matters |
|---|---|---|

## Main flow
Step-by-step from entry point to result, with file:line references.

## Important types / data
Key objects, fields, state, DB rows, API payloads, or models — and what they hold.

## Edge cases and failure modes
What happens when things go wrong: errors, empties, timeouts, auth failures, retries.

## Tests and validation
Which tests cover this, what they prove, and obvious gaps.

## How to safely change this
Practical guidance: where to edit, what not to break, what to test after.

## Questions to check your understanding
3–5 questions the reader should be able to answer after this.
```

## What not to do

- No textbook explanations of general concepts. Teach *this* code.
- Don't claim behavior you didn't read. If you infer, label it an inference.
- Don't dump whole files — quote the lines that matter.

## Related

- Subagent `codebase-teacher` for an isolated deep read.
- `/onboarding-map` for a whole-repo orientation rather than one subsystem.
