#!/bin/bash
set -e

TARGET="${1:-$(pwd)}"

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

# 3. 글로벌 CLAUDE.md 규칙 제거 여부 확인
GLOBAL_CLAUDE="$HOME/.claude/CLAUDE.md"
GLOBAL_MARKER="## 글로벌 Learnings"

if [ -f "$GLOBAL_CLAUDE" ] && grep -qF "$GLOBAL_MARKER" "$GLOBAL_CLAUDE"; then
  echo ""
  echo "  ~/.claude/CLAUDE.md 의 글로벌 규칙도 제거하시겠습니까?"
  echo "  (다른 프로젝트에서도 learnings-for-claude를 사용 중이라면 N을 선택하세요)"
  printf "  [y/N] "
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    awk -v marker="$GLOBAL_MARKER" '
      $0 == marker { found=1; next }
      found && /^## / { found=0 }
      !found
    ' "$GLOBAL_CLAUDE" > "$GLOBAL_CLAUDE.tmp"
    sed -i '' -e '${/^[[:space:]]*$/d;}' "$GLOBAL_CLAUDE.tmp"
    mv "$GLOBAL_CLAUDE.tmp" "$GLOBAL_CLAUDE"
    echo "  ~/.claude/CLAUDE.md 글로벌 규칙 제거"
  else
    echo "  스킵"
  fi
fi

echo "완료"
