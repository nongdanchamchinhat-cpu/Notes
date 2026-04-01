#!/usr/bin/env bash
# =============================================================================
# OpenNotes Branding Verification Script (P1-TASK-08)
# Đảm bảo không còn reference nào đến Notesnook/Streetwriters trong source
# =============================================================================

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "Scanning: $REPO_ROOT"
echo ""

remaining=$(find "$REPO_ROOT" -type f \( \
  -name "*.ts" -o -name "*.tsx" -o \
  -name "*.js" -o -name "*.jsx" -o \
  -name "*.json" -o -name "*.html" -o \
  -name "*.xml" -o -name "*.md" -o \
  -name "*.yml" -o -name "*.yaml" \
\) \
-not -path "*/node_modules/*" \
-not -path "*/.git/*" \
-not -name "LICENSE" \
-not -name "package-lock.json" \
| xargs grep -il "notesnook\|streetwriters" 2>/dev/null)

count=$(echo "$remaining" | grep -c . 2>/dev/null || echo 0)

if [ -z "$remaining" ] || [ "$count" -eq 0 ]; then
  echo "✅ PASS: No old brand references found in source files!"
  echo "   Ready for production release."
  exit 0
else
  echo "❌ FAIL: Found $count file(s) still containing old brand references:"
  echo ""
  echo "$remaining"
  echo ""
  echo "Run scripts/rebrand.sh to fix these issues."
  exit 1
fi
