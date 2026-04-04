<div align="center">

# learnings-for-claude

**Claude는 세션이 끊기면 모든 걸 잊습니다. 이 시스템은 잊지 않습니다.**

Claude가 스스로 읽고 쓰는 파일 기반 지식 라이브러리 —
같은 내용을 두 번 다시 설명하지 않아도 됩니다.

[설치](#설치) · [작동 방식](#작동-방식) · [MCP 서버](#mcp-서버) · [저장 관리 방식](#저장-관리-방식) · [Notion 연동](#notion-연동-선택) · [구조](#구조)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PyPI](https://img.shields.io/pypi/v/claude-library-mcp)](https://pypi.org/project/claude-library-mcp/)

[English](README.md) | **한국어**

</div>

---

## 문제

Claude와 반복 작업하다 보면 이런 일이 생깁니다:

- API 버그를 디버깅함. Claude와 함께 우회 방법을 찾음.
- 다음 세션에서 Claude가 같은 버그에 또 걸림.
- 또 설명함. 또 설명함.

코드에는 수정이 남지만, 거기서 배운 *원칙*은 남지 않습니다.

이 시스템은 원칙을 남깁니다.

---

## 작동 방식

**쓰기** — 아래 상황에서 Claude가 자동으로 기록합니다:

- 실험 / 백테스트 결론이 났을 때
- 접근법을 수정받았을 때 ("그건 그렇게 안 돼")
- 더 나은 방법을 발견했을 때
- 에러나 버그로 API/라이브러리 동작을 알게 됐을 때
- 아티클이나 문서에서 유효한 인사이트를 얻었을 때

세션 종료 시 `SessionEnd` 훅이 실행되고, Claude가 대화를 리뷰하여 기록할 내용이 있으면 파일을 쓰고 커밋합니다.

**읽기** — MCP 서버(`claude-library-mcp`)가 라이브러리를 검색 가능하게 합니다. 기술적 질문에 답하거나 접근법을 제안하기 전, Claude가 라이브러리에서 관련 학습을 검색합니다.

**흐름:**

```
세션 종료
    → SessionEnd 훅 실행
    → Claude 리뷰: 기록할 것 있나?
    → 있다면: library/[카테고리]/[서브카테고리]/[주제]/ 아래에 파일 작성
    → LIBRARY.md index 업데이트
    → git commit + push
    → Notion 동기화 (활성화 시)

새 세션 시작
    → 질문
    → MCP 서버가 라이브러리 검색 (인덱스 + 본문)
    → Claude가 관련 항목 읽은 후 응답
```

---

## 설치

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kangraemin/learnings-for-claude/main/install.sh)
```

설치 시 한국어/영어 선택 가능. 설치 중 선택:
- `.claude-library/` git 관리 방식 ([저장 관리 방식](#저장-관리-방식))
- [Notion 연동](#notion-연동-선택) 여부

### 업데이트

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kangraemin/learnings-for-claude/main/update.sh)
```

### 제거

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kangraemin/learnings-for-claude/main/uninstall.sh)
```

---

## MCP 서버

라이브러리는 PyPI에 배포된 MCP 서버를 통해 검색됩니다.

설치 시 `~/.claude/settings.json`에 자동 설정됩니다:

```json
{
  "mcpServers": {
    "claude-library": {
      "command": "uvx",
      "args": ["claude-library-mcp"],
      "env": {
        "LIBRARY_ROOT": "~/.claude/.claude-library"
      }
    }
  }
}
```

### 검색

`library_search(query)` — topic 이름, 파일 설명, 카테고리, 본문을 모두 검색합니다. 티어별 스코어링(topic > filename > description > category > body), 다중 키워드 AND 바이어스, 단어 경계 매칭을 사용합니다.

### 도구

| 도구 | 설명 |
|------|------|
| `library_search(query)` | 키워드로 라이브러리 검색 |
| `library_read(path)` | 특정 라이브러리 파일 읽기 |
| `library_list()` | LIBRARY.md 전체 인덱스 조회 |

---

## 저장 관리 방식

설치 시 선택:

| 방식 | 설명 |
|------|------|
| **로컬 파일만** | git 없이 `~/.claude/.claude-library/`에만 저장 |
| **~/.claude repo에 포함** | 기존 `~/.claude` git repo 안에서 함께 추적 |
| **별도 private repo** | library 전용 repo로 분리 관리. 여러 기기 간 동기화 가능. |

---

## Notion 연동 (선택)

Library를 Notion 데이터베이스에 미러링할 수 있습니다. 활성화하면 library 저장 시 git push 후 Notion에도 자동 동기화됩니다.

### 설정

`install.sh` 실행 중 아래 질문이 나옵니다:

```
Library를 Notion에도 연동할까요? [y/N]
```

Yes 선택 시 필요한 것:
- **NOTION_TOKEN** — [Notion 통합 페이지](https://www.notion.so/my-integrations)에서 Internal Integration 생성 후 토큰 복사
- **Notion 페이지 ID** — DB가 생성될 페이지 (페이지 URL의 마지막 32자리)

설치 시 "AI Library" 데이터베이스가 자동 생성됩니다:

| 컬럼 | 타입 | 설명 |
|------|------|------|
| Title | title | 항목 이름 |
| Category | select | 대분류 (`dev`, `ml`, `finance`) |
| Subcategory | select | 중분류 (`tooling`, `crypto`, `testing`) |
| Topic | select | 소주제 (`claude-code`, `bb-rsi-longshort`) |
| Tags | multi_select | 연관 주제 |
| Created | date | 작성일 |
| Path | rich_text | library 내 파일 경로 |

### 기존 파일 마이그레이션

```bash
# 드라이런 — 마이그레이션 대상 확인
~/.claude/scripts/notion-library-migrate.sh --dry-run

# 전체 마이그레이션
~/.claude/scripts/notion-library-migrate.sh

# 특정 카테고리만
~/.claude/scripts/notion-library-migrate.sh --category ml
```

---

## 구조

분류는 `TAXONOMY.md`를 따릅니다 — 도구명이나 프로젝트명이 아닌 도메인/기법 기준으로 분류합니다.

```
~/.claude/
  .claude-library/
    LIBRARY.md          ← 검색 가능한 인덱스
    GUIDE.md            ← Claude용 작성 가이드
    TAXONOMY.md         ← 분류 체계
    library/
      dev/
        tooling/        ← claude-code, mcp-patterns, ...
        testing/        ← spring-isolation, ...
      ml/
        classification/ ← gradient-boosting, ...
        time-series/
      finance/
        crypto/         ← bb-rsi-longshort, donchian, ...
        equity/         ← cross-momentum, vol-targeting, ...
      infra/            ← cicd, kaggle-env, ...
```

각 지식 파일:

```markdown
# [제목]

- 날짜: YYYY-MM-DD
- 출처: [실험명 / 디버깅 / 아티클]

## 상황
무슨 일이 있었는지. 에러 메시지, 데이터, 맥락.

## 교훈
다음에 어떻게 할지 (또는 하지 말아야 할지).
```

---

## 왜 만들었나

Claude는 좋은 사고 파트너입니다. 그런데 매 세션이 제로에서 시작됩니다.

과거의 실패, 수정했던 접근법, 반복되는 맥락 — 이걸 사용자가 직접 기억하고 매번 다시 설명해야 합니다.

이 시스템은 그 기억을 사람이 아닌 시스템이 갖도록 합니다.

---

## 라이선스

MIT
