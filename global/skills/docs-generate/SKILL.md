---
name: docs-generate
description: >
  Generate or update documentation from actual code — tutorial, how-to, API
  reference, or conceptual explanation for a module, function, or feature. Infers
  the Diataxis type from context, or asks if ambiguous. MAY write doc files when
  explicitly asked; warns before persisting sensitive content.
argument-hint: "[path | function | feature] [tutorial|how-to|reference|explanation]"
---

## Tool contract

This skill MAY write documentation files, but only when the user explicitly asks
to save or update a file. Prefer minimal, accurate output over lengthy prose.
Before writing any file:
- State the target path.
- Confirm the content contains no secrets, internal hostnames, credentials, PII,
  or proprietary identifiers. If any are detected, redact or warn the user first.

## Diataxis types

Ask which type is needed, or infer from the request:
- **Tutorial** — teach by doing; reader learns by following steps; outcome is
  completing a task they've never done. ("Getting started with X")
- **How-to** — solve a specific task; assumes prior knowledge; goal-oriented.
  ("How to configure X for Y")
- **Reference** — describe facts about an API or interface; no narrative; complete
  and accurate. ("API reference for X")
- **Explanation** — build understanding; answer "why"; discuss design decisions,
  tradeoffs, architecture. ("How X works")

## How to work

1. **Read the actual code**: Open the relevant files. Read function signatures,
   types, comments, and tests. Do not document behavior you have not verified.

2. **Identify the type**: If not specified, pick the type that best matches the
   request and state your choice.

3. **Check for existing docs**: If a doc file already exists, read it and update
   rather than replace — preserve accurate content.

4. **Write grounded content**: Every claim must trace to actual code. If something
   is unclear from the code, say so rather than guessing.

5. **Warn before persisting**: If asked to write a file, state the path and flag
   any sensitive content before writing.

6. Cross-reference [[onboarding-map]] if a broader codebase orientation is needed.

## Output format

```markdown
# Docs: <title> (<diataxis-type>)

(Generated documentation content follows, appropriate to the chosen type.)

---
<!-- For tutorials -->
## Prerequisites
## Steps
### Step 1: ...
## What you built

<!-- For how-to -->
## Problem
## Solution
## Steps
## Troubleshooting

<!-- For reference -->
## <FunctionName / ModuleName>
**Signature:** `fn(args) → ReturnType`
**Parameters:** ...
**Returns:** ...
**Throws:** ...
**Example:** ...

<!-- For explanation -->
## Overview
## Why it works this way
## Tradeoffs
## Related concepts
```

(Before writing any file, state the target path and confirm no sensitive content.)
