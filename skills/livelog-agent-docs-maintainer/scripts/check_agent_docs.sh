#!/usr/bin/env bash
set -euo pipefail

repo_path="${1:-$PWD}"
cd "$repo_path"

if ! command -v rg >/dev/null 2>&1; then
  echo "[ERROR] ripgrep (rg) is required"
  exit 1
fi

errors=0

log_ok() { echo "[OK] $*"; }
log_warn() { echo "[WARN] $*"; }
log_error() { echo "[ERROR] $*"; errors=$((errors + 1)); }

required_files=(
  "AGENTS.md"
  "docs/project-map.md"
  "docs/infrastructure-inventory.md"
  "README.md"
)

for file in "${required_files[@]}"; do
  if [[ -f "$file" ]]; then
    log_ok "found $file"
  else
    log_error "missing $file"
  fi
done

if rg -q "AGENTS.md" README.md && rg -q "docs/project-map.md" README.md && rg -q "docs/infrastructure-inventory.md" README.md; then
  log_ok "README links to all AI agent docs"
else
  log_error "README does not link to all AI agent docs"
fi

if rg -q "人手承認|human approval" AGENTS.md docs/infrastructure-inventory.md docs/project-map.md; then
  log_ok "approval policy text exists"
else
  log_error "approval policy text not found"
fi

for cmd in bin/setup bin/dev bin/rails bin/rubocop; do
  if [[ -x "$cmd" ]]; then
    log_ok "command exists: $cmd"
  else
    log_warn "command missing or not executable: $cmd"
  fi
done

code_envs=$(
  {
    rg -Noh "ENV\\[['\"]([A-Z0-9_]+)['\"]\\]" app config lib db spec -g '!app/assets/builds/**' -r '$1' || true
    rg -Noh "ENV\\.fetch\\(['\"]([A-Z0-9_]+)['\"]" app config lib db spec -g '!app/assets/builds/**' -r '$1' || true
  } | sort -u
)

doc_envs=$(
  rg -Noh '`([A-Z0-9_]+)`' docs/infrastructure-inventory.md -r '$1' | sort -u || true
)

missing_in_docs=$(
  comm -23 \
    <(printf "%s\n" "$code_envs" | sed '/^$/d') \
    <(printf "%s\n" "$doc_envs" | sed '/^$/d') || true
)

if [[ -n "$missing_in_docs" ]]; then
  log_warn "environment variables used in code but not listed in docs/infrastructure-inventory.md:"
  printf "%s\n" "$missing_in_docs" | sed 's/^/  - /'
else
  log_ok "environment variable inventory appears synchronized"
fi

if [[ $errors -gt 0 ]]; then
  echo ""
  log_error "consistency check failed with $errors error(s)"
  exit 1
fi

echo ""
log_ok "consistency check passed"
