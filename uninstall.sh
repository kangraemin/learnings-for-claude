#!/bin/bash
set -e

TARGET="${1:-$(pwd)}"

echo "learnings-for-claude: $TARGET 에서 제거 중..."

# LEARNINGS.md 제거
if [ -f "$TARGET/LEARNINGS.md" ]; then
  rm "$TARGET/LEARNINGS.md"
  echo "  LEARNINGS.md 제거"
fi

# CLAUDE.md에서 규칙 제거
CLAUDE_MD="$TARGET/CLAUDE.md"
MARKER="## Learnings 시스템"

if [ -f "$CLAUDE_MD" ] && grep -qF "$MARKER" "$CLAUDE_MD"; then
  # marker부터 다음 ## 섹션 전까지 삭제 (변수를 큰따옴표로 awk에 전달)
  awk -v marker="$MARKER" '
    $0 == marker { found=1; next }
    found && /^## / { found=0 }
    !found
  ' "$CLAUDE_MD" > "$CLAUDE_MD.tmp"
  # 끝 빈 줄 정리
  sed -i '' -e '${/^[[:space:]]*$/d;}' "$CLAUDE_MD.tmp"
  mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
  echo "  CLAUDE.md 규칙 제거"
fi

echo "완료"
