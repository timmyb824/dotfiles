#!/usr/bin/env bash
# migrate-npm-globals.sh
# Usage: ./migrate-npm-globals.sh <new-node-version>
# Example: ./migrate-npm-globals.sh 20.11.0

set -euo pipefail

# ── Validate argument ──────────────────────────────────────────────────────────
if [[ $# -ne 1 ]]; then
  echo "Usage: $(basename "$0") <new-node-version>"
  echo "Example: $(basename "$0") 20.11.0"
  exit 1
fi

NEW_VERSION="$1"

# ── Capture global packages from the CURRENT version ──────────────────────────
echo "📦 Reading global packages from current Node version..."

# npm list -g --depth=0 --json gives us a clean machine-readable list
PACKAGES=$(npm list -g --depth=0 --json 2>/dev/null \
  | node -e "
      const data = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
      const deps = data.dependencies || {};
      const pkgs = Object.entries(deps)
        .filter(([name]) => name !== 'npm')   // skip npm itself
        .map(([name, info]) => \`\${name}@\${info.version}\`);
      console.log(pkgs.join(' '));
    ")

if [[ -z "$PACKAGES" ]]; then
  echo "⚠️  No global packages found (besides npm). Nothing to migrate."
else
  echo "✅ Found packages: $PACKAGES"
fi

# ── Switch to the new Node version ────────────────────────────────────────────
echo ""
echo "🔀 Switching to Node $NEW_VERSION via fnm..."
eval "$(fnm env)"           # make sure fnm shims are active in this shell
fnm use "$NEW_VERSION" --install-if-missing

echo "✅ Now using: $(node -v)"

# ── Install packages on the new version ───────────────────────────────────────
if [[ -n "$PACKAGES" ]]; then
  echo ""
  echo "⬇️  Installing packages on Node $NEW_VERSION..."
  # shellcheck disable=SC2086
  npm install -g $PACKAGES
  echo ""
  echo "✅ All done! Global packages migrated to Node $NEW_VERSION."
else
  echo "✅ Switched to Node $NEW_VERSION. No packages to install."
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "──────────────────────────────────"
echo "Node version : $(node -v)"
echo "npm version  : $(npm -v)"
if [[ -n "$PACKAGES" ]]; then
  echo "Packages     : $PACKAGES"
fi
echo "──────────────────────────────────"
