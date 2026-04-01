#!/usr/bin/env bash
# =============================================================================
# OpenNotes FULL Rebrand Script
# Covers: file content, file renames, directory renames, asset renames
# Replaces the incomplete rebrand.sh with full coverage
# =============================================================================
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DRY_RUN="${DRY_RUN:-false}"
LOG_FILE="$REPO_ROOT/rebrand.log"

# Brand mapping
OLD_COMPANY="streetwriters"
OLD_COMPANY_CAP="Streetwriters"
OLD_APP="notesnook"
OLD_APP_CAP="Notesnook"
OLD_APP_UPPER="NOTESNOOK"
OLD_BUNDLE="com.streetwriters.notesnook"
OLD_BUNDLE_IOS="org.streetwriters.notesnook"
OLD_DOMAIN="notesnook.com"

NEW_COMPANY="openlay"
NEW_COMPANY_CAP="OpenLay"
NEW_APP="opennotes"
NEW_APP_CAP="OpenNotes"
NEW_APP_UPPER="OPENNOTES"
NEW_BUNDLE="com.openlay.notes"
NEW_DOMAIN="opennotes.openlay.com"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*" | tee -a "$LOG_FILE"; }
step() { echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"; echo -e "${BLUE}[STEP]${NC} $*" | tee -a "$LOG_FILE"; }

> "$LOG_FILE"

echo "================================================"
echo "  OpenNotes FULL Rebrand Script"
echo "  Root: $REPO_ROOT"
echo "  Dry run: $DRY_RUN"
echo "================================================"

# =============================================================================
# STEP 1: Content replacement in ALL text files (not just select extensions)
# =============================================================================
step "1/6 — Replacing content in ALL text files"

# Use grep to find files, then perl to replace — covers every text file type
# Order matters: longest/most-specific strings first to avoid partial matches
REPLACEMENTS=(
  # API endpoints (most specific URLs first)
  "api.notesnook.com|api.opennotes.openlay.com"
  "auth.notesnook.com|auth.opennotes.openlay.com"
  "events.notesnook.com|sse.opennotes.openlay.com"
  "monograph.notesnook.com|mono.opennotes.openlay.com"
  "app.notesnook.com|app.opennotes.openlay.com"
  "help.notesnook.com|help.opennotes.openlay.com"
  "blog.notesnook.com|blog.opennotes.openlay.com"
  "vericrypt.notesnook.com|vericrypt.opennotes.openlay.com"

  # GitHub / org paths
  "streetwriters/notesnook-themes|openlay/opennotes-themes"
  "streetwriters/notesnook|openlay/opennotes"

  # Bundle IDs (before generic replacements)
  "org.streetwriters.notesnook|com.openlay.notes"
  "com.streetwriters.notesnook|com.openlay.notes"
  "io.streetwriters.notesnook|com.openlay.notes"

  # Package scopes
  "@notesnook-importer/|@opennotes-importer/"
  "@notesnook/|@opennotes/"

  # Domain
  "notesnook.com|opennotes.openlay.com"

  # Brand names (case variants — order: Capitalized, lowercase, UPPER)
  "Notesnook|OpenNotes"
  "notesnook|opennotes"
  "NOTESNOOK|OPENNOTES"

  # Company names
  "Streetwriters|OpenLay"
  "streetwriters|openlay"
  "STREETWRITERS|OPENLAY"

  # Email domains
  "streetwriters.co|openlay.co"
)

replace_content() {
  local find_str="$1"
  local replace_str="$2"
  local tmpfile="/tmp/rebrand_matches.txt"

  # Find ALL text files containing the string, excluding binary/vendor dirs
  find "$REPO_ROOT" -type f \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" \
    -not -name "LICENSE" \
    -not -name "package-lock.json" \
    -not -name "*.png" -not -name "*.jpg" -not -name "*.jpeg" \
    -not -name "*.gif" -not -name "*.ico" -not -name "*.icns" \
    -not -name "*.woff" -not -name "*.woff2" -not -name "*.ttf" -not -name "*.eot" \
    -not -name "*.otf" -not -name "*.zip" -not -name "*.tar.gz" \
    -not -name "*.so" -not -name "*.dylib" -not -name "*.dll" \
    -not -name "*.a" -not -name "*.o" -not -name "*.class" \
    -not -name "*.jar" -not -name "*.aar" \
    -not -name "rebrand-full.sh" \
    -print0 2>/dev/null | xargs -0 grep -rl "$find_str" 2>/dev/null > "$tmpfile" || true

  local count
  count=$(wc -l < "$tmpfile" | tr -d ' ')

  if [ "$count" -eq 0 ] || [ ! -s "$tmpfile" ]; then
    log "  '$find_str' → '$replace_str' — no matches"
    rm -f "$tmpfile"
    return
  fi

  log "  '$find_str' → '$replace_str' — $count file(s)"

  if [ "$DRY_RUN" = "true" ]; then
    head -5 "$tmpfile" | while read -r f; do echo "    [dry] $f"; done
    [ "$count" -gt 5 ] && echo "    ... and $((count - 5)) more"
    rm -f "$tmpfile"
    return
  fi

  xargs perl -pi -e "s/\Q$find_str\E/$replace_str/g" < "$tmpfile" 2>/dev/null || true
  rm -f "$tmpfile"
}

for pair in "${REPLACEMENTS[@]}"; do
  IFS='|' read -r old new <<< "$pair"
  replace_content "$old" "$new"
done

# =============================================================================
# STEP 2: Java/Kotlin package directory restructuring
# =============================================================================
step "2/6 — Restructuring Android Java/Kotlin package directories"

ANDROID_SRC="$REPO_ROOT/apps/mobile/android/app/src"
OLD_PKG_DIR="com/streetwriters/notesnook"
NEW_PKG_DIR="com/openlay/notes"

move_android_package() {
  local src_variant="$1"  # main, release, androidTest, etc.
  local old_dir="$ANDROID_SRC/$src_variant/java/$OLD_PKG_DIR"
  local new_dir="$ANDROID_SRC/$src_variant/java/$NEW_PKG_DIR"

  if [ ! -d "$old_dir" ]; then
    log "  $src_variant: no old dir, skipping"
    return
  fi

  log "  $src_variant: $old_dir → $new_dir"

  if [ "$DRY_RUN" = "true" ]; then
    find "$old_dir" -type f | while read -r f; do echo "    [dry] would move: $f"; done
    return
  fi

  mkdir -p "$new_dir"

  # Copy all files/subdirs preserving structure
  cp -r "$old_dir"/* "$new_dir"/ 2>/dev/null || true
  cp -r "$old_dir"/.[!.]* "$new_dir"/ 2>/dev/null || true

  # Handle subdirectories (e.g., datatypes/)
  find "$old_dir" -mindepth 1 -type d | while read -r subdir; do
    local rel="${subdir#$old_dir/}"
    mkdir -p "$new_dir/$rel"
  done

  # Remove old directory tree
  rm -rf "$ANDROID_SRC/$src_variant/java/com/streetwriters"

  log "  $src_variant: done"
}

move_android_package "main"
move_android_package "release"
move_android_package "androidTest"
move_android_package "debug"
move_android_package "staging"

# Also rename NotesnookTileService.java → OpenNotesTileService.java
if [ -f "$ANDROID_SRC/main/java/$NEW_PKG_DIR/NotesnookTileService.java" ]; then
  mv "$ANDROID_SRC/main/java/$NEW_PKG_DIR/NotesnookTileService.java" \
     "$ANDROID_SRC/main/java/$NEW_PKG_DIR/OpenNotesTileService.java" 2>/dev/null || true
  log "  Renamed NotesnookTileService.java → OpenNotesTileService.java"
fi

# =============================================================================
# STEP 3: iOS project directory renames
# =============================================================================
step "3/6 — Renaming iOS project directories and files"

IOS_DIR="$REPO_ROOT/apps/mobile/ios"

# Directory renames (order matters — deepest first or rename leaf→parent)
IOS_DIR_RENAMES=(
  "Notesnook.xcodeproj/xcshareddata/xcschemes/Notesnook.xcscheme|OpenNotes.xcscheme"
  "Notesnook.xcodeproj/xcshareddata/xcschemes/NotesnookRelease.xcscheme|OpenNotesRelease.xcscheme"
  "Notesnook.xcodeproj|OpenNotes.xcodeproj"
  "Notesnook.xcworkspace|OpenNotes.xcworkspace"
  "Notesnook/Notesnook.entitlements|OpenNotes/OpenNotes.entitlements"
  "Notesnook/NotesnookDebug.entitlements|OpenNotes/OpenNotesDebug.entitlements"
  "Notesnook/Images.xcassets/notesnook-text.png|OpenNotes/Images.xcassets/opennotes-text.png"
  "Notesnook|OpenNotes"
  "NotesnookTests/NotesnookTests.m|OpenNotesTests/OpenNotesTests.m"
  "NotesnookTests|OpenNotesTests"
  "Notesnook-Bridging-Header.h|OpenNotes-Bridging-Header.h"
  "NotesWidgetExtensionDebug.entitlements|NotesWidgetExtensionDebug.entitlements"
)

rename_ios_item() {
  local old_path="$IOS_DIR/$1"
  local new_path="$IOS_DIR/$2"

  if [ ! -e "$old_path" ]; then
    return
  fi

  # Ensure parent dir exists
  mkdir -p "$(dirname "$new_path")"

  log "  $1 → $2"

  if [ "$DRY_RUN" = "true" ]; then
    return
  fi

  mv "$old_path" "$new_path" 2>/dev/null || true
}

for pair in "${IOS_DIR_RENAMES[@]}"; do
  IFS='|' read -r old new <<< "$pair"
  rename_ios_item "$old" "$new"
done

# =============================================================================
# STEP 4: Rename source files with "notesnook" in their names
# =============================================================================
step "4/6 — Renaming source files containing 'notesnook' in filename"

FILE_RENAMES=(
  # Web
  "apps/web/src/assets/notesnook-logo.png|apps/web/src/assets/opennotes-logo.png"
  "apps/web/src/dialogs/settings/notesnook-circle-settings.ts|apps/web/src/dialogs/settings/opennotes-circle-settings.ts"

  # Mobile app
  "apps/mobile/app/assets/images/notesnook.png|apps/mobile/app/assets/images/opennotes.png"
  "apps/mobile/app/assets/images/notesnook-dark.png|apps/mobile/app/assets/images/opennotes-dark.png"
  "apps/mobile/app/utils/notesnook-module.ts|apps/mobile/app/utils/opennotes-module.ts"
  "apps/mobile/app/screens/settings/notesnook-circle.tsx|apps/mobile/app/screens/settings/opennotes-circle.tsx"

  # Android drawable
  "apps/mobile/android/app/src/main/res/drawable/notesnooktext.png|apps/mobile/android/app/src/main/res/drawable/opennotestext.png"

  # Docs
  "docs/help/contents/_include/static/mobile-integration/select-notesnook-android.png|docs/help/contents/_include/static/mobile-integration/select-opennotes-android.png"
  "docs/help/contents/_include/static/mobile-integration/select-notesnook-ios.png|docs/help/contents/_include/static/mobile-integration/select-opennotes-ios.png"
  "docs/help/contents/backup-and-restore-notes-in-notesnook.md|docs/help/contents/backup-and-restore-notes-in-opennotes.md"
  "docs/help/contents/create-a-note-in-notesnook.md|docs/help/contents/create-a-note-in-opennotes.md"
  "docs/help/contents/export-notes-from-notesnook.md|docs/help/contents/export-notes-from-opennotes.md"
)

for pair in "${FILE_RENAMES[@]}"; do
  IFS='|' read -r old new <<< "$pair"
  old_path="$REPO_ROOT/$old"
  new_path="$REPO_ROOT/$new"

  if [ ! -e "$old_path" ]; then
    continue
  fi

  log "  $old → $new"

  if [ "$DRY_RUN" = "true" ]; then
    continue
  fi

  mkdir -p "$(dirname "$new_path")"
  mv "$old_path" "$new_path"
done

# =============================================================================
# STEP 5: Fix import paths and references that changed due to file renames
# =============================================================================
step "5/6 — Fixing import paths after file renames"

IMPORT_FIXES=(
  # Web asset imports
  "notesnook-logo.png|opennotes-logo.png"
  "notesnook-circle-settings|opennotes-circle-settings"

  # Mobile imports
  "notesnook-module|opennotes-module"
  "notesnook-circle|opennotes-circle"
  "images/notesnook.png|images/opennotes.png"
  "images/notesnook-dark.png|images/opennotes-dark.png"

  # Android drawable reference
  "notesnooktext|opennotestext"

  # iOS references in pbxproj and other config files (already moved dirs)
  "Notesnook.xcodeproj|OpenNotes.xcodeproj"
  "Notesnook.xcworkspace|OpenNotes.xcworkspace"
  "Notesnook-Bridging-Header.h|OpenNotes-Bridging-Header.h"
  "NotesnookRelease.xcscheme|OpenNotesRelease.xcscheme"
  "NotesnookTests|OpenNotesTests"
  "NotesnookDebug.entitlements|OpenNotesDebug.entitlements"
  "Notesnook.entitlements|OpenNotes.entitlements"
  "notesnook-text.png|opennotes-text.png"

  # Doc references
  "select-notesnook-android.png|select-opennotes-android.png"
  "select-notesnook-ios.png|select-opennotes-ios.png"
  "backup-and-restore-notes-in-notesnook|backup-and-restore-notes-in-opennotes"
  "create-a-note-in-notesnook|create-a-note-in-opennotes"
  "export-notes-from-notesnook|export-notes-from-opennotes"
)

for pair in "${IMPORT_FIXES[@]}"; do
  IFS='|' read -r old new <<< "$pair"
  replace_content "$old" "$new"
done

# =============================================================================
# STEP 6: Update AUTHORS file
# =============================================================================
step "6/6 — Updating AUTHORS file"

AUTHORS_FILE="$REPO_ROOT/AUTHORS"
if [ -f "$AUTHORS_FILE" ] && [ "$DRY_RUN" != "true" ]; then
  perl -pi -e 's/^Notesnook is written/OpenNotes is written/g' "$AUTHORS_FILE"
  log "  Updated AUTHORS header"
fi

# =============================================================================
# VERIFICATION
# =============================================================================
echo ""
echo "================================================"
echo "  VERIFICATION"
echo "================================================"

# Scan for ANY remaining references (all file types)
remaining_files=$(find "$REPO_ROOT" -type f \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -name "LICENSE" \
  -not -name "package-lock.json" \
  -not -name "*.png" -not -name "*.jpg" -not -name "*.jpeg" \
  -not -name "*.gif" -not -name "*.ico" -not -name "*.icns" \
  -not -name "*.woff" -not -name "*.woff2" -not -name "*.ttf" -not -name "*.eot" \
  -not -name "rebrand-full.sh" \
  -not -name "rebrand.sh" \
  -not -name "verify-brand.sh" \
  2>/dev/null | xargs grep -ril 'notesnook\|streetwriters' 2>/dev/null || true)

remaining_count=0
if [ -n "$remaining_files" ]; then
  remaining_count=$(echo "$remaining_files" | wc -l | tr -d ' ')
fi

# Check for files/dirs still named with old brand
remaining_names=$(find "$REPO_ROOT" -not -path "*/node_modules/*" -not -path "*/.git/*" \
  \( -name "*notesnook*" -o -name "*Notesnook*" -o -name "*streetwriters*" -o -name "*Streetwriters*" \) \
  2>/dev/null || true)

remaining_names_count=0
if [ -n "$remaining_names" ]; then
  remaining_names_count=$(echo "$remaining_names" | wc -l | tr -d ' ')
fi

echo ""
if [ "$remaining_count" -eq 0 ] && [ "$remaining_names_count" -eq 0 ]; then
  echo -e "${GREEN}✅ PASS: No old brand references found!${NC}"
else
  if [ "$remaining_count" -gt 0 ]; then
    echo -e "${RED}❌ Content references remaining: $remaining_count file(s)${NC}"
    echo "$remaining_files" | head -30
  fi
  echo ""
  if [ "$remaining_names_count" -gt 0 ]; then
    echo -e "${RED}❌ File/dir names remaining: $remaining_names_count item(s)${NC}"
    echo "$remaining_names" | head -30
  fi
fi

echo ""
echo "================================================"
echo "  Rebrand complete! Log: $LOG_FILE"
echo "================================================"
