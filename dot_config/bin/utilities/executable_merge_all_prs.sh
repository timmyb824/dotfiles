#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  merge-all-prs.sh [--skip 12,34,56] [--skip 78] [--repo OWNER/REPO]

Options:
  --skip   PR numbers to skip (comma-separated). Can be provided multiple times.
  --repo   Optional repo override (e.g. octo-org/octo-repo). If omitted, uses current repo.
  -h|--help Show help.
EOF
}

SKIP_LIST=()
REPO=""

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip)
      [[ $# -ge 2 ]] || { echo "ERROR: --skip requires a value" >&2; exit 2; }
      IFS=',' read -r -a parts <<< "$2"
      for p in "${parts[@]}"; do
        p="${p//[[:space:]]/}"
        [[ -n "$p" ]] && SKIP_LIST+=("$p")
      done
      shift 2
      ;;
    --repo)
      [[ $# -ge 2 ]] || { echo "ERROR: --repo requires a value" >&2; exit 2; }
      REPO="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

# Build a quick lookup map for skips
declare -A SKIP
for n in "${SKIP_LIST[@]}"; do
  SKIP["$n"]=1
done

# Repo flag for gh (optional)
GH_REPO_ARGS=()
if [[ -n "$REPO" ]]; then
  GH_REPO_ARGS+=(--repo "$REPO")
fi

# Fetch PR numbers (open only)
prs_json="$(gh pr list "${GH_REPO_ARGS[@]}" --state open --limit 500 --json number,title,url)"
mapfile -t PR_NUMBERS < <(echo "$prs_json" | jq -r '.[].number')

if [[ ${#PR_NUMBERS[@]} -eq 0 ]]; then
  echo "No open PRs found."
  exit 0
fi

echo "Found ${#PR_NUMBERS[@]} open PR(s)."
if [[ ${#SKIP_LIST[@]} -gt 0 ]]; then
  echo "Skipping: ${SKIP_LIST[*]}"
fi
echo

for pr in "${PR_NUMBERS[@]}"; do
  if [[ -n "${SKIP[$pr]:-}" ]]; then
    echo "⏭️  Skipping PR #$pr"
    continue
  fi

  title="$(echo "$prs_json" | jq -r ".[] | select(.number==$pr) | .title")"
  url="$(echo "$prs_json" | jq -r ".[] | select(.number==$pr) | .url")"

  echo "🔀 Merging PR #$pr: $title"
  echo "   $url"

  # Merge commit + delete branch
  # Add --auto if you want it to enable auto-merge when checks are pending.
  gh pr merge "${GH_REPO_ARGS[@]}" --merge --delete-branch "$pr"

  echo "✅ Done PR #$pr"
  echo
done
