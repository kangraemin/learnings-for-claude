#!/bin/bash
# SessionEnd / PostCompact: library 업데이트 체크

LIBRARY="$PWD/LIBRARY.md"

[ -f "$LIBRARY" ] || exit 0

claude -p "이번 세션에서 library에 기록할 만한 결론이 있었는지 확인하고, 있다면 GUIDE.md 형식에 따라 library/에 추가하고 LIBRARY.md index를 업데이트해라. 없으면 아무것도 하지 마라." 2>/dev/null || true
