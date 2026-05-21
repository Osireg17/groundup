#!/usr/bin/env bash
# groundup update script
# Updates the groundup plugin to the latest version

set -euo pipefail

echo ""
echo "  groundup — updating..."
echo ""

if ! command -v claude &>/dev/null; then
  echo "  ✗ Claude Code CLI not found."
  exit 1
fi

claude plugin update groundup

echo ""
echo "  ✓ groundup updated."
echo ""
