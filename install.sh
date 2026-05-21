#!/usr/bin/env bash
# groundup install script
# Installs groundup as a Claude Code plugin

set -euo pipefail

GROUNDUP_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "  groundup — senior engineer mentor framework"
echo "  ============================================"
echo ""
echo "  Installing as a Claude Code plugin..."
echo ""

# Check Claude Code is available
if ! command -v claude &>/dev/null; then
  echo "  ✗ Claude Code CLI not found."
  echo "    Install it from: https://claude.ai/code"
  echo ""
  exit 1
fi

# Install the plugin from the local directory
claude plugin install "$GROUNDUP_DIR"

echo ""
echo "  ✓ groundup installed."
echo ""
echo "  Skills available (namespaced under /groundup:):"
echo "    /groundup:architecture  /groundup:orient        /groundup:grill"
echo "    /groundup:flow-map      /groundup:pseudocode     /groundup:patterns"
echo "    /groundup:systematic-debugging                   /groundup:read-the-error"
echo "    /groundup:growth-review /groundup:ask-well"
echo ""
echo "  Open a project in Claude Code and describe what you want to build."
echo ""
echo "  To update: git pull && claude plugin update groundup"
echo "  To uninstall: claude plugin uninstall groundup"
echo ""
