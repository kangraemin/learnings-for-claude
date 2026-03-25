#!/bin/bash
# SessionStart: 현재 프로젝트의 LEARNINGS.md를 context에 주입
# 글로벌 learnings도 함께 주입

LEARNINGS="$PWD/LEARNINGS.md"
GLOBAL_DIR="$HOME/.claude/learnings"

# 프로젝트 learnings
if [ -f "$LEARNINGS" ]; then
  echo "=== Project Learnings ==="
  cat "$LEARNINGS"
  echo ""
fi

# 글로벌 learnings
if [ -d "$GLOBAL_DIR" ]; then
  for f in "$GLOBAL_DIR"/*.md; do
    [ -f "$f" ] && [ "$(basename "$f")" != "_template.md" ] || continue
    echo "=== Global Learnings: $(basename "$f" .md) ==="
    cat "$f"
    echo ""
  done
fi
