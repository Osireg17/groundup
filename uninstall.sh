#!/usr/bin/env bash
# groundup uninstall script

set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"

echo ""
echo "  groundup — uninstalling"
echo ""

SKILLS=(using-groundup grill flow-map pseudocode systematic-debugging patterns growth-review)

for skill in "${SKILLS[@]}"; do
  if [[ -d "$SKILLS_DIR/$skill" ]]; then
    rm -rf "$SKILLS_DIR/$skill"
    echo "  ✓ removed skill: $skill"
  fi
done

if [[ -f "$CLAUDE_DIR/hooks/groundup-session-start" ]]; then
  rm "$CLAUDE_DIR/hooks/groundup-session-start"
  echo "  ✓ removed hook"
fi

if [[ -f "$CLAUDE_MD" ]]; then
  sed -i.bak '/<!-- groundup:start -->/,/<!-- groundup:end -->/d' "$CLAUDE_MD"
  echo "  ✓ removed groundup block from CLAUDE.md"
fi

echo ""
echo "  groundup uninstalled."
echo ""
