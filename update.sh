#!/usr/bin/env bash
# groundup update script
# Re-copies skills and hook from the repo into ~/.claude without touching CLAUDE.md

set -euo pipefail

GROUNDUP_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
HOOKS_DIR="$CLAUDE_DIR/hooks"

echo ""
echo "  groundup — updating..."
echo ""

# ── Skills ────────────────────────────────────────────────────────────────────

SKILLS=(
  "using-groundup"
  "architecture"
  "orient"
  "grill"
  "flow-map"
  "pseudocode"
  "systematic-debugging"
  "patterns"
  "read-the-error"
  "growth-review"
  "ask-well"
)

for skill in "${SKILLS[@]}"; do
  src="$GROUNDUP_DIR/skills/$skill/SKILL.md"
  dst="$SKILLS_DIR/$skill/SKILL.md"
  if [[ ! -f "$dst" ]]; then
    echo "  ⚠  $skill not found in $SKILLS_DIR — run install.sh first"
    exit 1
  fi
  cp "$src" "$dst"
  echo "  ✓ $skill"
done

# ── Hook ──────────────────────────────────────────────────────────────────────

HOOK_DST="$HOOKS_DIR/groundup-session-start"
if [[ ! -f "$HOOK_DST" ]]; then
  echo "  ⚠  Hook not found at $HOOK_DST — run install.sh first"
  exit 1
fi
cp "$GROUNDUP_DIR/hooks/session-start" "$HOOK_DST"
chmod +x "$HOOK_DST"
echo "  ✓ session-start hook"

echo ""
echo "  ✓ groundup updated. CLAUDE.md was not changed."
echo "    To update CLAUDE.md, run: bash $GROUNDUP_DIR/install.sh"
echo ""
