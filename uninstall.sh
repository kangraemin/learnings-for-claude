#!/bin/bash
set -e

TARGET="${1:-$(pwd)}"
SETTINGS="$HOME/.claude/settings.json"
HOOK_DEST="$HOME/.claude/hooks/library-sync.sh"

echo "learnings-for-claude: $TARGET 에서 제거 중..."

# 1. LIBRARY.md / GUIDE.md 제거
for f in LIBRARY.md GUIDE.md; do
  if [ -f "$TARGET/$f" ]; then
    rm "$TARGET/$f"
    echo "  $f 제거"
  fi
done

# 2. library/ 제거
if [ -d "$TARGET/library" ]; then
  echo ""
  echo "  library/ 를 제거하면 모든 학습 기록이 삭제됩니다."
  printf "  계속하시겠습니까? [y/N] "
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    rm -rf "$TARGET/library"
    echo "  library/ 제거"
  else
    echo "  library/ 유지"
  fi
fi

# 3. CLAUDE.md에서 규칙 제거
CLAUDE_MD="$TARGET/CLAUDE.md"
MARKER="## Library 시스템"

if [ -f "$CLAUDE_MD" ] && grep -qF "$MARKER" "$CLAUDE_MD"; then
  awk -v marker="$MARKER" '
    $0 == marker { found=1; next }
    found && /^## / { found=0 }
    !found
  ' "$CLAUDE_MD" > "$CLAUDE_MD.tmp"
  sed -i '' -e '${/^[[:space:]]*$/d;}' "$CLAUDE_MD.tmp"
  mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
  echo "  CLAUDE.md 규칙 제거"
fi

# 4. 훅 제거 여부 확인
if command -v jq &>/dev/null && grep -qF "library-sync" "$SETTINGS" 2>/dev/null; then
  echo ""
  echo "  SessionEnd/PostCompact 훅도 제거하시겠습니까?"
  echo "  (다른 프로젝트에서도 사용 중이라면 N을 선택하세요)"
  printf "  [y/N] "
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    jq '
      .hooks.SessionEnd = [(.hooks.SessionEnd // [])[] | select((.hooks[0].command // "") | contains("library-sync") | not)] |
      .hooks.PostCompact = [(.hooks.PostCompact // [])[] | select((.hooks[0].command // "") | contains("library-sync") | not)]
    ' "$SETTINGS" > "$SETTINGS.tmp"
    mv "$SETTINGS.tmp" "$SETTINGS"
    rm -f "$HOOK_DEST"
    echo "  훅 제거"
  else
    echo "  스킵"
  fi
fi

echo "완료"
