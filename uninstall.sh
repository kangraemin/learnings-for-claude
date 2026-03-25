#!/bin/bash
set -e

TARGET="${1:-$(pwd)}"
SETTINGS="$HOME/.claude/settings.json"
HOOK_DEST="$HOME/.claude/hooks/session-start-learnings.sh"

echo "learnings-for-claude: $TARGET 에서 제거 중..."

# 1. LEARNINGS.md 제거
if [ -f "$TARGET/LEARNINGS.md" ]; then
  rm "$TARGET/LEARNINGS.md"
  echo "  LEARNINGS.md 제거"
fi

# 2. 프로젝트 CLAUDE.md에서 규칙 제거
CLAUDE_MD="$TARGET/CLAUDE.md"
MARKER="## Learnings 시스템"

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

# 3. SessionStart 훅 제거 여부 확인
if command -v jq &>/dev/null && grep -qF "session-start-learnings" "$SETTINGS" 2>/dev/null; then
  echo ""
  echo "  SessionStart 훅도 제거하시겠습니까?"
  echo "  (다른 프로젝트에서도 learnings-for-claude를 사용 중이라면 N을 선택하세요)"
  printf "  [y/N] "
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    jq '.hooks.SessionStart = [.hooks.SessionStart[] | select(.hooks[0].command | contains("session-start-learnings") | not)]' \
      "$SETTINGS" > "$SETTINGS.tmp"
    mv "$SETTINGS.tmp" "$SETTINGS"
    rm -f "$HOOK_DEST"
    echo "  SessionStart 훅 제거"
  else
    echo "  스킵"
  fi
fi

echo "완료"
