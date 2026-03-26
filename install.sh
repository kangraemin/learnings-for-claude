#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$(pwd)}"
SETTINGS="$HOME/.claude/settings.json"
HOOK_DEST="$HOME/.claude/hooks/library-sync.sh"

echo "learnings-for-claude: $TARGET 에 설치 중..."

# 1. LIBRARY.md 생성
if [ -f "$TARGET/LIBRARY.md" ]; then
  echo "  LIBRARY.md 이미 존재 — 스킵"
else
  cp "$SCRIPT_DIR/templates/LIBRARY.md" "$TARGET/LIBRARY.md"
  echo "  LIBRARY.md 생성"
fi

# 2. library/ 구조 생성
if [ -d "$TARGET/library" ]; then
  echo "  library/ 이미 존재 — 스킵"
else
  mkdir -p "$TARGET/library"
  cp "$SCRIPT_DIR/templates/library/_template.md" "$TARGET/library/_template.md"
  echo "  library/ 생성"
fi

# 3. GUIDE.md 복사
if [ -f "$TARGET/GUIDE.md" ]; then
  echo "  GUIDE.md 이미 존재 — 스킵"
else
  cp "$SCRIPT_DIR/GUIDE.md" "$TARGET/GUIDE.md"
  echo "  GUIDE.md 생성"
fi

# 4. 프로젝트 CLAUDE.md에 규칙 추가
CLAUDE_MD="$TARGET/CLAUDE.md"
MARKER="## Library 시스템"

if [ -f "$CLAUDE_MD" ] && grep -qF "$MARKER" "$CLAUDE_MD"; then
  echo "  CLAUDE.md 규칙 이미 존재 — 스킵"
else
  echo "" >> "$CLAUDE_MD"
  cat "$SCRIPT_DIR/templates/claude-rules.md" >> "$CLAUDE_MD"
  echo "  CLAUDE.md 규칙 추가"
fi

# 5. SessionEnd / PostCompact 훅 설치 (jq 필요)
if ! command -v jq &>/dev/null; then
  echo "  경고: jq 없음 — 훅 스킵 (brew install jq 후 재설치 권장)"
elif grep -qF "library-sync" "$SETTINGS" 2>/dev/null; then
  echo "  훅 이미 존재 — 스킵"
else
  mkdir -p "$(dirname "$HOOK_DEST")"
  cp "$SCRIPT_DIR/hooks/library-sync.sh" "$HOOK_DEST"
  chmod +x "$HOOK_DEST"

  [ -f "$SETTINGS" ] && cp "$SETTINGS" "$SETTINGS.bak" || echo "{\"hooks\":{}}" > "$SETTINGS"

  HOOK_JSON="{\"hooks\":[{\"type\":\"command\",\"command\":\"$HOOK_DEST\",\"timeout\":30}]}"
  jq --argjson hook "$HOOK_JSON" '
    .hooks.SessionEnd = (.hooks.SessionEnd // []) + [$hook] |
    .hooks.PostCompact = (.hooks.PostCompact // []) + [$hook]
  ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"

  echo "  SessionEnd / PostCompact 훅 등록"
fi

echo ""
echo "완료. Claude가 자동으로 학습을 기록합니다."
