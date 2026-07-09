#!/usr/bin/env bash
# health-check.sh
#
# Best-effort project health probe. Auto-detects the toolchain and runs the
# usual checks (lint / typecheck / test / build / dep-audit / format /
# dead-code / secret-scan) without assuming a specific stack. Prints a
# pass/fail line per check; the /health-check skill turns this into a score
# and prioritized fixes.
#
# It does NOT install anything and does NOT modify files. When a tool or
# manifest is absent, it prints a "not applicable / tool absent" SKIP note
# and continues — it never hard-fails on a missing tool.
set -uo pipefail

pass=0; fail=0; skip=0
# per-run temp file (not a fixed /tmp name) to avoid cross-run collisions and symlink clobber
HC_OUT="$(mktemp "${TMPDIR:-/tmp}/healthcheck.XXXXXX")"
trap 'rm -f "$HC_OUT"' EXIT
run() { # run "<label>" "<command...>"
  label="$1"; shift
  if "$@" >"$HC_OUT" 2>&1; then
    echo "PASS  $label"; pass=$((pass+1))
  else
    echo "FAIL  $label  (see output below)"; fail=$((fail+1))
    sed 's/^/      /' "$HC_OUT" | tail -n 15
  fi
}
skipmsg() { echo "SKIP  $1"; skip=$((skip+1)); }

echo "=== PROJECT HEALTH CHECK ==="

# --- Node / JS / TS ---
if [ -f package.json ]; then
  has() { grep -q "\"$1\"" package.json 2>/dev/null; }
  pm="npm"; [ -f pnpm-lock.yaml ] && pm="pnpm"; [ -f yarn.lock ] && pm="yarn"
  has lint      && run "lint"      $pm run lint      || skipmsg "lint (no script)"
  has typecheck && run "typecheck" $pm run typecheck || { has tsc && run "typecheck" npx tsc --noEmit || skipmsg "typecheck (no script)"; }
  has test      && run "test"      $pm test          || skipmsg "test (no script)"
  has build     && run "build"     $pm run build     || skipmsg "build (no script)"
  # dependency audit — yarn uses --level; npm/pnpm use --audit-level
  if [ "$pm" = "yarn" ]; then
    if ! command -v yarn >/dev/null 2>&1; then
      skipmsg "dep-audit (yarn not installed)"
    elif [ -f .yarnrc.yml ] || grep -q '"packageManager": *"yarn@[234]' package.json 2>/dev/null; then
      # Yarn Berry (2+): classic --level flag is gone; use "yarn npm audit"
      run "dep-audit (yarn berry)" yarn npm audit
    else
      run "dep-audit (yarn)" yarn audit --level high
    fi
  else
    command -v "$pm" >/dev/null 2>&1 \
      && run "dep-audit ($pm)" $pm audit --audit-level=high \
      || skipmsg "dep-audit ($pm not installed)"
  fi
  # format check
  command -v prettier >/dev/null 2>&1 \
    && run "format (prettier)" prettier --check . \
    || skipmsg "format (prettier not installed)"
  # dead-code: try knip first, then ts-prune
  if command -v knip >/dev/null 2>&1; then
    run "dead-code (knip)" knip
  elif command -v ts-prune >/dev/null 2>&1; then
    run "dead-code (ts-prune)" ts-prune
  else
    skipmsg "dead-code (knip/ts-prune not installed)"
  fi
fi

# --- Python ---
if [ -f pyproject.toml ] || [ -f setup.py ] || ls ./*.py >/dev/null 2>&1; then
  command -v ruff   >/dev/null 2>&1 && run "ruff"   ruff check .  || skipmsg "ruff (not installed)"
  command -v mypy   >/dev/null 2>&1 && run "mypy"   mypy .        || skipmsg "mypy (not installed)"
  command -v pytest >/dev/null 2>&1 && run "pytest" pytest -q     || skipmsg "pytest (not installed)"
  # dependency audit
  command -v pip-audit >/dev/null 2>&1 \
    && run "dep-audit (pip-audit)" pip-audit \
    || skipmsg "dep-audit (pip-audit not installed)"
  # format check
  command -v black >/dev/null 2>&1 \
    && run "format (black)" black --check . \
    || skipmsg "format (black not installed)"
  # dead-code
  command -v vulture >/dev/null 2>&1 \
    && run "dead-code (vulture)" vulture . \
    || skipmsg "dead-code (vulture not installed)"
fi

# --- Go ---
if [ -f go.mod ]; then
  run "go vet"  go vet ./...
  run "go test" go test ./...
  # dependency audit
  command -v govulncheck >/dev/null 2>&1 \
    && run "dep-audit (govulncheck)" govulncheck ./... \
    || skipmsg "dep-audit (govulncheck not installed)"
  # format check — gofmt exits 0 even when files need formatting; detect via non-empty -l output
  if command -v gofmt >/dev/null 2>&1; then
    run "format (gofmt)" bash -c 'files=$(find . -path ./vendor -prune -o -name "*.go" -print | xargs gofmt -l 2>/dev/null); [ -z "$files" ] && exit 0; echo "$files"; exit 1'
  else
    skipmsg "format (gofmt not found)"
  fi
  # dead-code: no standard single-binary tool scripted; model-driven check only
  skipmsg "dead-code (no standard Go tool scripted; run staticcheck or unused manually)"
fi

# --- Rust ---
if [ -f Cargo.toml ]; then
  run "cargo check" cargo check
  run "cargo test"  cargo test
  # dependency audit — cargo-audit is a separate crate; install: cargo install cargo-audit
  command -v cargo-audit >/dev/null 2>&1 \
    && run "dep-audit (cargo audit)" cargo audit \
    || skipmsg "dep-audit (cargo-audit not installed; run: cargo install cargo-audit)"
  # format check
  command -v rustfmt >/dev/null 2>&1 \
    && run "format (cargo fmt)" cargo fmt --check \
    || skipmsg "format (rustfmt not installed)"
  # dead-code: no standard tool scripted; model-driven check only
  skipmsg "dead-code (no standard Rust tool scripted; use cargo +nightly rustc -- -W dead-code)"
fi

# --- Secret scan ---
# gitleaks or trufflehog; neither is required — absence is a skip, not a failure
if ! git rev-parse HEAD >/dev/null 2>&1; then
  skipmsg "secret-scan (no commits yet)"
elif command -v gitleaks >/dev/null 2>&1; then
  run "secret-scan (gitleaks)" gitleaks detect
elif command -v trufflehog >/dev/null 2>&1; then
  run "secret-scan (trufflehog)" trufflehog git file://.
else
  skipmsg "secret-scan (neither gitleaks nor trufflehog installed; to install: brew install gitleaks)"
fi

echo
echo "=== SUMMARY ==="
echo "pass=$pass fail=$fail skip=$skip"
[ "$fail" -eq 0 ]
