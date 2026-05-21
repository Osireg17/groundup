#!/usr/bin/env bash
# groundup uninstall script

set -euo pipefail

echo ""
echo "  groundup — uninstalling"
echo ""

if ! command -v claude &>/dev/null; then
  echo "  ✗ Claude Code CLI not found."
  exit 1
fi

claude plugin uninstall groundup

echo ""
echo "  groundup uninstalled."
echo ""
