#!/usr/bin/env bash
# =============================================================================
# OpenNotes Rebrand Script
# Thực hiện: P1-TASK-01 (Global String Replacement)
# Source: OpenNotes_TechSpec_Phase0_1.docx
# =============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "================================================"
echo "  OpenNotes Rebrand Script"
echo "  Root: $REPO_ROOT"
echo "================================================"

# Files to skip (preserve LICENSE content)
SKIP_PATTERNS=(
  "node_modules"
  ".git"
  "LICENSE"
  "*.lock"
  "package-lock.json"
)

build_exclude_args() {
  local args=()
  for p in "${SKIP_PATTERNS[@]}"; do
    args+=("--exclude-dir=$p" "--exclude=$p")
  done
  echo "${args[@]}"
}

# Perform replacement using perl (cross-platform safe)
replace_in_files() {
  local find_str="$1"
  local replace_str="$2"
  local extensions="$3"
  
  echo ""
  echo ">> Replacing: '$find_str' → '$replace_str'"
  
  find "$REPO_ROOT" -type f \( \
    -name "*.ts" -o -name "*.tsx" -o \
    -name "*.js" -o -name "*.jsx" -o \
    -name "*.json" -o -name "*.html" -o \
    -name "*.xml" -o -name "*.md" -o \
    -name "*.yml" -o -name "*.yaml" -o \
    -name "*.env" -o -name "*.env.example" -o \
    -name "*.gradle" -o -name "*.plist" \
  \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -name "LICENSE" \
  -not -name "package-lock.json" \
  | xargs -I{} perl -pi -e "s/\Q$find_str\E/$replace_str/g" {} 2>/dev/null || true
  
  local count=$(find "$REPO_ROOT" -type f \( \
    -name "*.ts" -o -name "*.tsx" -o \
    -name "*.js" -o -name "*.jsx" -o \
    -name "*.json" -o -name "*.html" -o \
    -name "*.xml" -o -name "*.md" -o \
    -name "*.yml" -o -name "*.yaml" \
  \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" \
  | xargs grep -l "$replace_str" 2>/dev/null | wc -l | tr -d ' ')
  
  echo "   → Found in $count files after replacement"
}

echo ""
echo "[STEP 1] String replacements (case-sensitive)..."

# Theo bảng trong spec: thứ tự quan trọng (dài trước ngắn sau)
replace_in_files "streetwriters/notesnook" "openlay/opennotes"
replace_in_files "notesnook.com" "opennotes.openlay.com"
replace_in_files "Notesnook" "OpenNotes"
replace_in_files "notesnook" "opennotes"
replace_in_files "NOTESNOOK" "OPENNOTES"
replace_in_files "Streetwriters" "OpenLay"
replace_in_files "streetwriters" "openlay"

echo ""
echo "[STEP 2] Package name replacements..."
replace_in_files "@notesnook/" "@openlay/notes-"

echo ""
echo "[STEP 3] Bundle ID replacements..."
replace_in_files "com.streetwriters.notesnook" "com.openlay.notes"
replace_in_files "io.streetwriters.notesnook" "com.openlay.notes"

echo ""
echo "[STEP 4] API endpoint replacements..."
replace_in_files "api.notesnook.com" "api.opennotes.openlay.com"
replace_in_files "auth.notesnook.com" "auth.opennotes.openlay.com"
replace_in_files "events.notesnook.com" "sse.opennotes.openlay.com"
replace_in_files "monograph.notesnook.com" "mono.opennotes.openlay.com"

echo ""
echo "================================================"
echo "[VERIFY] Scanning for remaining old brand references..."
remaining=$(find "$REPO_ROOT" -type f \( \
  -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.json" \
  -o -name "*.html" -o -name "*.xml" \
\) \
-not -path "*/node_modules/*" \
-not -path "*/.git/*" \
-not -name "LICENSE" \
| xargs grep -il "notesnook\|streetwriters" 2>/dev/null | wc -l | tr -d ' ')

echo "Remaining files with old brand references: $remaining"
if [ "$remaining" -gt "0" ]; then
  echo ""
  echo "Files still containing old references:"
  find "$REPO_ROOT" -type f \( \
    -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.json" \
    -o -name "*.html" -o -name "*.xml" \
  \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -name "LICENSE" \
  | xargs grep -il "notesnook\|streetwriters" 2>/dev/null | head -20
fi
echo ""
echo "================================================"
echo "  Rebrand complete!"
echo "================================================"
