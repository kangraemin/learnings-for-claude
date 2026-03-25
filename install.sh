#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$(pwd)}"

echo "learnings-for-claude: $TARGET 에 설치 중..."

# 1. LEARNINGS.md 생성
if [ -f "$TARGET/LEARNINGS.md" ]; then
  echo "  LEARNINGS.md 이미 존재 — 스킵"
else
  cp "$SCRIPT_DIR/templates/LEARNINGS.md" "$TARGET/LEARNINGS.md"
  echo "  LEARNINGS.md 생성"
fi

# 2. CLAUDE.md에 규칙 추가
CLAUDE_MD="$TARGET/CLAUDE.md"
MARKER="## Learnings 시스템"

if [ -f "$CLAUDE_MD" ] && grep -qF "$MARKER" "$CLAUDE_MD"; then
  echo "  CLAUDE.md 규칙 이미 존재 — 스킵"
else
  echo "" >> "$CLAUDE_MD"
  cat "$SCRIPT_DIR/templates/claude-rules.md" >> "$CLAUDE_MD"
  echo "  CLAUDE.md 규칙 추가"
fi

# 3. 글로벌 learnings 디렉토리 + 글로벌 CLAUDE.md 규칙 추가
GLOBAL_DIR="$HOME/.claude/learnings"
GLOBAL_CLAUDE="$HOME/.claude/CLAUDE.md"
GLOBAL_MARKER="## 글로벌 Learnings"

if [ ! -d "$GLOBAL_DIR" ]; then
  mkdir -p "$GLOBAL_DIR"
  cp "$SCRIPT_DIR/global/_template.md" "$GLOBAL_DIR/_template.md"
  echo "  ~/.claude/learnings/ 생성"
else
  echo "  ~/.claude/learnings/ 이미 존재 — 스킵"
fi

if [ -f "$GLOBAL_CLAUDE" ] && grep -qF "$GLOBAL_MARKER" "$GLOBAL_CLAUDE"; then
  echo "  ~/.claude/CLAUDE.md 글로벌 규칙 이미 존재 — 스킵"
else
  echo "" >> "$GLOBAL_CLAUDE"
  cat "$SCRIPT_DIR/templates/global-claude-rules.md" >> "$GLOBAL_CLAUDE"
  echo "  ~/.claude/CLAUDE.md 글로벌 규칙 추가"
fi

echo ""
echo "완료. Claude가 자동으로 학습을 기록합니다."
