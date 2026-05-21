#!/usr/bin/env bash
# groundup install script
# Installs the groundup framework into ~/.claude

set -euo pipefail

GROUNDUP_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo ""
echo "  groundup — senior engineer mentor framework"
echo "  ============================================"
echo ""

# ── 1. Create directories ────────────────────────────────────────────────────

mkdir -p "$SKILLS_DIR" "$HOOKS_DIR"

# ── 2. Install skills ────────────────────────────────────────────────────────

echo "  Installing skills..."

SKILLS=(
  "using-groundup"
  "grill"
  "flow-map"
  "pseudocode"
  "systematic-debugging"
  "patterns"
  "growth-review"
)

for skill in "${SKILLS[@]}"; do
  src="$GROUNDUP_DIR/skills/$skill"
  dst="$SKILLS_DIR/$skill"
  if [[ -d "$dst" ]]; then
    echo "    ↻ $skill (updating)"
  else
    echo "    ✓ $skill"
  fi
  mkdir -p "$dst"
  cp "$src/SKILL.md" "$dst/SKILL.md"
done

# ── 3. Install session-start hook ────────────────────────────────────────────

echo "  Installing session-start hook..."
HOOK_SRC="$GROUNDUP_DIR/hooks/session-start"
HOOK_DST="$HOOKS_DIR/groundup-session-start"

cp "$HOOK_SRC" "$HOOK_DST"
chmod +x "$HOOK_DST"
echo "    ✓ groundup-session-start"

# ── 4. Wire hook into settings.json ─────────────────────────────────────────

echo "  Wiring session-start hook..."

HOOK_ENTRY="{\"type\":\"command\",\"command\":\"$HOOK_DST\"}"

if [[ ! -f "$SETTINGS_FILE" ]]; then
  cat > "$SETTINGS_FILE" <<EOF
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_DST"
          }
        ]
      }
    ]
  }
}
EOF
  echo "    ✓ Created settings.json with hook"
elif grep -q "groundup-session-start" "$SETTINGS_FILE" 2>/dev/null; then
  echo "    ↻ Hook already configured in settings.json"
elif command -v jq &>/dev/null; then
  # Auto-merge using jq: append to SessionStart hooks array if it exists, create it if not
  MERGED=$(jq --argjson entry "$HOOK_ENTRY" '
    if .hooks.SessionStart then
      .hooks.SessionStart[0].hooks += [$entry]
    else
      .hooks.SessionStart = [{"hooks": [$entry]}]
    end
  ' "$SETTINGS_FILE")
  printf '%s\n' "$MERGED" > "$SETTINGS_FILE"
  echo "    ✓ Added hook to existing settings.json"
else
  echo ""
  echo "  ⚠  settings.json already exists and jq is not installed."
  echo "     Add the following to the SessionStart hooks manually:"
  echo ""
  echo '     {'
  echo '       "type": "command",'
  echo "       \"command\": \"$HOOK_DST\""
  echo '     }'
  echo ""
  echo "     See: https://docs.anthropic.com/en/docs/claude-code/hooks"
  echo ""
fi

# ── 5. Append CLAUDE.md block ────────────────────────────────────────────────

echo "  Installing CLAUDE.md..."

CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
GROUNDUP_BLOCK_START="<!-- groundup:start -->"
GROUNDUP_BLOCK_END="<!-- groundup:end -->"

if [[ -f "$CLAUDE_MD" ]] && grep -q "$GROUNDUP_BLOCK_START" "$CLAUDE_MD"; then
  # Update existing block
  echo "    ↻ Updating existing groundup block in CLAUDE.md"
  # Remove old block and append fresh one
  sed -i.bak "/$GROUNDUP_BLOCK_START/,/$GROUNDUP_BLOCK_END/d" "$CLAUDE_MD"
fi

if [[ -f "$CLAUDE_MD" ]]; then
  echo "    ↻ Appending groundup section to existing CLAUDE.md"
  printf '\n%s\n' "$GROUNDUP_BLOCK_START" >> "$CLAUDE_MD"
  cat "$GROUNDUP_DIR/CLAUDE.md" >> "$CLAUDE_MD"
  printf '\n%s\n' "$GROUNDUP_BLOCK_END" >> "$CLAUDE_MD"
else
  echo "    ✓ Creating CLAUDE.md"
  printf '%s\n' "$GROUNDUP_BLOCK_START" > "$CLAUDE_MD"
  cat "$GROUNDUP_DIR/CLAUDE.md" >> "$CLAUDE_MD"
  printf '\n%s\n' "$GROUNDUP_BLOCK_END" >> "$CLAUDE_MD"
fi

# ── 6. Check for GSD (optional) ──────────────────────────────────────────────

if [[ -d "$CLAUDE_DIR/get-shit-done" ]] || [[ -d "$SKILLS_DIR/gsd-ship" ]]; then
  echo ""
  echo "  ✓ GSD detected — groundup integrates with /gsd-ship for final review + PR"
fi

# ── 7. Done ───────────────────────────────────────────────────────────────────

echo ""
echo "  ✓ groundup installed."
echo ""
echo "  First use:"
echo "    Open a project in Claude Code and describe what you want to build."
echo "    Claude will run you through: Grill → Flow Map → Pseudocode → Implement → Review"
echo ""
echo "  Skills available:"
echo "    /grill, /flow-map, /pseudocode, /systematic-debugging, /patterns, /growth-review"
echo ""
echo "  To uninstall, run: bash $GROUNDUP_DIR/uninstall.sh"
echo ""
