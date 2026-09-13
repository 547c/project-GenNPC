# Project GenNPC — 킥오프 노트 (2026-09-04 작성, 2026-09-10 갱신)

이 문서는 project-jrpg와는 완전히 별개인 서브프로젝트 `project-GenNPC`의 시작 지점을 정리한 문서다.
project-jrpg 쪽 인수인계 문서(`project-jrpg-handoff.md`, Claude Project 안에 있음)는 이 문서 때문에 바꾸지 않았다 — 거긴 게임 본편 상태 그대로, 여기는 이 서브프로젝트 전용.

**2026-09-10 업데이트: AI의 역할을 "분류기(Pattern A)"로 확정.** 아래 새 섹션 참고 — 이게 이 프로젝트의 핵심 설계 결정이라 맨 위에 짚어둠.

**2026-09-10 추가 업데이트: El Ariss 교수님과의 미팅에서 새 기법(pathfinding/behavior tree/utility system) 소개받음. 방향은 GenNPC(Pattern A) 유지로 재확정, pathfinding은 phase 2 후보로 보류.** 맨 아래 "2026-09-10 El Ariss 미팅" 섹션 참고.

---

## 이게 뭔지 (한 줄 요약)

project-jrpg(Godot 4.7 JRPG, flag 기반 상태관리 시스템이 백본)의 서브프로젝트로, **손으로 쓴 flag 기반 대사 시스템 vs 생성형(LLM) AI가 실시간으로 만드는 대사**를 같은 게임 state 위에서 직접 비교해보는 실험 프로젝트.

메인 스토리/엔딩과는 완전히 무관한 NPC 한 명한테만 적용해서, project-jrpg 본편엔 리스크 없이 진행한다.

## 배경 — 왜 이걸 하는가

- 편입 지원(2027 가을) 포트폴리오/EC 서사의 다음 단계. project-jrpg가 "결정론적 상태관리를 직접 설계"였다면, 이건 "그 반대편(생성형)을 직접 만져보고 정직하게 비교"하는 단계로 이미 EC 초안(`ec-resume-draft.md`)에 "Autonomous AI NPC Dialogue Prototype" 항목으로 잡혀 있음.
- 2026-09-03 Dr. Omar El Ariss(state machine/statechart, 소프트웨어 테스팅 전공)와 첫 미팅 후 다음 주부터 정기 멘토십 시작. 이 주제(생성형 대사가 tracked state랑 모순 안 나는지 검증하는 문제)는 정확히 이분 전공 영역이라, 다음 미팅에서 꺼내볼 예정.
- (EC/지원서 전략 관련 디테일은 이 문서에서 다루지 않음 — 그건 별도 채팅에서 전담 중.)

---

## 오늘(9/4) 세션에서 정리한 것

### 용어
"generative NPC" / "AI-driven NPC" / "LLM-powered NPC" 다 같은 걸 가리키는 표현. 최근(지난 1년 이내)까지도 게임업계에서 계속 논쟁 중인 주제 — 3년 전 반짝하고 끝난 유행이 아님.

### 플랫폼/방식 옵션 4가지 (2026-09 기준 조사)

| 방식 | 장점 | 단점 |
|---|---|---|
| **Inworld AI** | LLM 라우팅+TTS+립싱크까지 통합 | Godot 공식 지원 없음(로그인 걸린 튜토리얼 문서뿐), 무료 티어는 넉넉한 편 |
| **Convai** | 비슷한 구조, 텍스트 전용 호출(`voiceResponse:false`) 가능 | Godot 공식 지원 없음, 무료 티어가 월 100회로 빡빡함, 무료 티어는 캐릭터를 웹 Playground에서만 생성 가능 |
| **직접 LLM API 호출** (Claude/OpenAI 등) | GDScript `HTTPRequest`로 직접 호출, Godot 예제/애셋 이미 존재, 완전한 자유도 | API 자체엔 무료 티어 없음(종량제, 다만 매우 저렴), API 키를 클라이언트에 노출하면 안 돼서 별도 백엔드/프록시 필요 |
| **로컬 LLM (Ollama 등)** | 완전 무료, 오프라인 | 저사양 PC에서 품질/속도 트레이드오프 큼, Godot 연동 플러그인(Noko) 있음 |

**아직 최종 확정 안 함.** 프로토타입(텍스트 전용) 단계에는 직접 API 호출 쪽이 더 낫다는 게 Claude(cloud session)의 의견이었지만, 이건 사용자가 직접 결정할 부분 — 다음 세션에서 확정 필요.

### 스팀 배포 시 비용 구조 (중요, 나중 문제지만 미리 알아둘 것)
- 로컬 LLM 번들 = 플레이어 컴퓨터에서 돌아가서 개발자 비용 0원, 대신 다운로드 용량 증가 + 저사양 PC에서 느림.
- 클라우드 API(Inworld/Convai/직접 API 다 동일) = 기본적으로 **개발자 계정에 청구**, 플레이어 늘수록 비용 증가. 대응책: BYOK(플레이어가 자기 API 키 입력), Convai Connect(플레이어가 자기 계정으로 로그인해서 자기 무료 할당량 사용), 세션/일일 사용량 상한.
- **단, 지금 단계(연구/프로토타입, 낯선 사람에게 배포 아님)에서는 이 문제를 지금 당장 풀 필요 없음** — 실제 스팀 출시 결정 시점에 다시 고려.
- Steam은 "AI Generated Content Disclosure" 정책이 있고, 런타임에 실시간 생성되는 AI 콘텐츠는 가드레일 설명까지 제출해야 함(확인 완료, 2026 기준). 지금 하려는 "state 모순 감지 + fallback" 작업이 나중에 이 제출에도 그대로 쓰일 가능성 있음.

### 업계 여론 정리 (Reddit/LinkedIn/Ubisoft 사례 조사)
- 반대 의견 대부분은 **"무한 자유 채팅"**을 겨냥함 (플레이어가 NPC랑 몇 시간이고 아무 얘기나 하게 두는 기능) — 이건 우리가 하려는 것과 다름.
- 반복되는 진짜 문제: hallucination(모르는 걸 지어냄), lore 모순, 프롬프트 인젝션/탈옥, 비용, latency, 캐릭터 유지의 어려움.
- **Ubisoft NEO NPC 프로젝트**(GDC 2024, Nvidia Audio2Face + Inworld LLM)가 정확히 우리가 하려는 방향과 같음: 작가가 캐릭터를 먼저 만들고 AI는 그걸 "연기"만 함, "캐릭터는 자유의지 없음, 이야기 속 역할일 뿐"이라고 명시, 가드레일(독성 필터, bias 체크) 있음. **중요한 확인 사실: Ubisoft 정도의 R&D팀도 "이게 진짜 이 캐릭터가 할 말인가" 검증을 아직 사람이 직접 하고 있음** — 자동 검증은 여전히 열린 문제.
- 좋은 절충 설계안(여러 출처 공통): AI가 스토리 방향을 정하게 하지 말고, 정해진 dialogue tree 뒤에서 반응만 생성하게 하거나, NPC가 "아는 정보 범위"를 사람이 미리 좁혀두는 방식.

### 핵심 기술 개념 — flag 시스템과의 연결고리 (제일 중요)

지금 project-jrpg의 `dialogue_data.gd`는 `show_if_flag`/`required_affinity` 같은 조건으로 "이 flag 상태에선 이 미리 쓴 문장을 보여줘라"는 방식. AI NPC는 미리 쓴 문장이 없고 그 순간 즉석에서 문장을 생성하므로, **GameState.flags/affinity 중 이 NPC가 알아야 할 것만 골라서 자연어 문장으로 변환해 AI 프롬프트에 매번 같이 넘겨주는 것**(= grounding)이 필요함. 이건 지금 `_resolve_start_id()`가 flag 보고 첫 대사를 분기시키는 것과 원리적으로 같은 패턴 — "flag → 조건 분기"의 대상이 "미리 쓴 문장"에서 "AI한테 알려줄 사실"로 바뀌는 것뿐.

**진짜 연구 질문**: grounding만으로는 AI가 가끔 그 사실을 무시하고 모순되는 말을 할 수 있음(hallucination) → **AI 출력이 넘겨준 flag/사실과 모순되는지 감지하고, 걸리면 안전한 대체 문장으로 fallback하는 메커니즘**을 만들고 관찰하는 것. 이게 Dr. El Ariss의 state machine/테스팅 전공과 자연스럽게 연결되는 지점.

---

## 2026-09-10 결정 — AI의 역할: 분류기(Pattern A) vs 생성기(Pattern B)

논의 중에 AI가 NPC 대화에서 맡을 수 있는 역할이 사실 두 가지로 나뉜다는 게 명확해짐:

**Pattern A — 분류기(classifier/router).** 플레이어가 자유 텍스트로 말하면, AI는 새 문장을 짓지 않고 **이미 손으로 다 써놓은 고정된 선택지 중 하나로 매칭**만 한다. 예: 대화 분기가 [밥먹으러 가기]/[집에 가기]/[영화보기] 세 개로 정해져 있을 때, 플레이어가 "아 배고프다"라고 타이핑하면 AI는 "이건 [밥먹으러 가기]에 해당한다"고 분류만 하고, 그 뒤로는 **기존에 버튼 클릭 시 실행되던 것과 완전히 같은 flag-설정 코드**가 그대로 실행됨.

**Pattern B — 생성기(generator).** AI가 NPC의 대사 자체를 그 자리에서 새로 지어냄. `GameState.flags`를 "grounding"으로 넘겨줘서 모순을 줄이고, 그래도 생긴 모순을 감지/fallback하는 게 핵심 과제 (9/4 정리 내용의 "핵심 기술 개념" 섹션이 이 Pattern B를 설명한 것).

**결정: Pattern A로 먼저 진행.** 이유:
1. **project-jrpg의 백본(`GameState`/`dialogue_data.gd`)을 전혀 안 건드려도 됨** — AI는 "어느 버튼을 누른 셈 칠지"만 판단하고, 실제 게임에 반영되는 문장/로직은 100% 기존 손으로 쓴 것 그대로. project-jrpg 인수인계 문서의 "핵심 백본 파일은 원칙적으로 안 건드린다" 원칙과 완벽히 부합.
2. 화면에 나오는 모든 대사가 여전히 사람이 쓴 것이므로, lore 모순/스포일러 위험이 Pattern B보다 훨씬 낮음.
3. 그럼에도 진짜 설계 문제가 남아있음 — "애매하거나 세 선택지 어디에도 안 맞는 입력(예: '그냥 좀 앉아있고 싶어')이 왔을 때 안전하게 원래 메뉴로 되돌리는 것"이 여전히 테스트/검증이 필요한 지점. Pattern B(생성+모순감지)보다 훨씬 다루기 쉬운 문제라 먼저 끝까지 완성해볼 수 있음.
4. Pattern A와 B는 배타적이지 않음 — 나중에 Pattern A 위에 짧은 생성형 리액션(Pattern B 일부)을 얹는 하이브리드도 가능. 지금은 A만으로 스코프를 좁혀서 시작.

## 지금까지 정해진 것

- 폴더/레포: `project-GenNPC`, project-jrpg와 완전히 별도.
- 스코프: 텍스트 대화만 먼저 (음성/립싱크는 나중 문제).
- 적용 대상: project-jrpg 메인 스토리와 무관한 NPC 한 명에게만, 리스크 없는 범위로.
- **AI의 역할: Pattern A(분류기) 채택 확정 (2026-09-10)** — 위 섹션 참고.
- CLAUDE.md/AI 관련 파일 공개 안 함(project-jrpg에서 정한 정책과 동일하게 여기서도 적용할지는 미정 — 시작할 때 다시 확인).

## 아직 안 정해진 것 (다음 세션에서 결정할 것들)

- [x] ~~API 제공자~~ → **2026-09-13 결정: 첫 스모크 테스트는 Gemini(Google AI Studio)로.** 무료 쿼터라 계정/카드 등록 부담 없이 바로 테스트 가능해서 첫 단추로 선택. 이 프로젝트 자체가 "비교"가 목적이라, 나중에 Claude(지금 이미 쓰고 있는 것)도 같은 코드 구조에 꽂아서 비교할 계획 — GLM/Hugging Face는 후순위.
- [x] ~~계정/API 키 준비~~ → **2026-09-13 완료.** Google AI Studio에서 "Project GenNPC" 클라우드 프로젝트 생성, Gemini API 키 발급 완료. 키는 `project-gennpc/.env`에 로컬 저장 (git에는 안 올라감, `.gitignore`로 제외).
- [x] ~~Godot 프로젝트로 바로 시작 vs 가벼운 스크립트부터~~ → **2026-09-13 결정: Godot 프로젝트 안에서 바로 시작.** (더 안전한 "스크립트 먼저" 경로도 있었지만, 사용자가 Godot 안에서 바로 하는 쪽을 선택함 — 이러면 API 자체 문제인지 GDScript HTTPRequest 연동 문제인지 구분이 살짝 더 어려울 수 있다는 점만 감안.)
- [x] ~~분류기 프롬프트/로직을 어디에 둘지~~ → **2026-09-13 결정: project-jrpg와 완전히 별개인 새 Godot 프로젝트(`project-GenNPC` 폴더)에서, 목업(가짜) flag 3개(go eat/go home/go watch movie)로 먼저 실험.** project-jrpg의 진짜 `GameState`/`dialogue_data.gd`는 전혀 안 건드림 — 원래 계획했던 "안전한 쪽" 그대로 확정.
- [x] ~~분류 정확도를 어떻게 테스트할지~~ → **2026-09-13 1차 스모크 테스트 완료 (3/3 통과).** 아래 "2026-09-13 첫 프로토타입 & 스모크 테스트" 섹션 참고. (계속 늘려갈 예정 — 지금은 최소 3케이스만 확인한 상태)
- [x] ~~git 레포 관리 여부~~ → **2026-09-13 결정: GitHub으로 관리, project-jrpg랑 같은 커밋 규칙(AI 트레일러 없이, 사람 말투).** 레포: https://github.com/547c/project-GenNPC (Public)

## 교수님 상담용 정리 (다음 미팅에서 꺼낼 내용)

Dr. El Ariss(state machine/statechart, 소프트웨어 테스팅 전공)와의 미팅에서 이 프로젝트를 꺼낼 때 참고할 프레이밍. (미팅 스크립트/영어 표현 자체는 별도 채팅에서 관리 중인 `el-ariss-meeting-script-english.md`에 있음 — 여긴 기술 내용만 정리.)

**한 줄 소개**: "내 게임의 대화 분기를, 버튼 클릭 대신 자유 텍스트 입력으로 고르게 만들어보고 있다. AI는 새 콘텐츠를 만들지 않고, 플레이어의 자연어 입력을 미리 정해진 선택지 중 하나로 분류하는 역할만 한다."

**교수님 전공이랑 자연스럽게 연결되는 지점**: 이건 사실상 "입력 공간이 무한(자연어)인데, 유효한 출력은 유한한 집합(정해진 flag 전이)으로 제한된 함수를 어떻게 검증하나"라는 문제임. 특히:
- 모든 가능한 자연어 입력을 열거해서 테스트할 수 없다는 점 — project-jrpg의 flag 조합 폭발(state explosion) 문제랑 형태는 다르지만 "input space가 너무 커서 완전 검증이 불가능하다"는 근본 구조는 똑같음.
- "애매한 입력이 왔을 때 잘못된 flag로 잘못 분류되면 안 된다"는 요구사항이, 결국 "결정론적 상태 전이 함수에 신뢰할 수 없는(non-deterministic) 분류기를 앞단에 붙였을 때, 안전하게 실패하는 방법"이라는 문제로 요약됨.
- 실제로 물어볼 만한 질문: "자연어처럼 사실상 무한한 입력 공간을 가진 시스템의 정확성을 실용적으로 검증하는 정식 방법이 있는지" (9/3 미팅에서 이미 pairwise/combinatorial testing 얘기가 나왔던 것과 연결 — 이번엔 flag 조합이 아니라 입력 분류 정확도 쪽에 적용 가능한지 여쭤보면 좋을 듯).

**이번 주 실제로 진행된 것은 아직 설계 논의 단계** — 코드/실험 결과는 없음. 미팅에서는 "방향을 이렇게 잡았는데 어떻게 생각하시는지" 정도로 가져가는 게 정직함.

## 2026-09-10 El Ariss 미팅 — 실제 있었던 일 (트랜스크립트 원문 대조 완료)

*(이전 버전엔 "트랜스크립트를 다시 볼 수 없어서 기억 기준으로 적음"이라고 써뒀었는데, 이후 원문을 다시 확보해서 대조 완료 — 아래는 실제 발언 기준.)*

### 대화 흐름
1. GenNPC 아이디어를 처음 설명함 — [go eat]/[go home]/[go watch movie] 3개 flag 예시, "I feel hungry"라고 치면 AI가 [go eat]로 매칭한다는 걸 그대로 설명함 (Pattern A 그대로).
2. 교수님이 "player가 아닌 캐릭터(NPC)들이 player의 행동에 따라 스스로 어떻게 반응/선택하는지"를 여러 번 물었는데, 답변은 계속 "player가 버튼을 클릭하면 flag가 켜진다"는 내용이었음 — 이건 **player 자신의 선택 메커니즘**이지 **NPC 스스로의 반응 로직**이 아니라서, 질문과 답이 몇 번 어긋났음 (약 02:03~05:35 구간). 다음에 이 질문 다시 나오면 "NPC 자체는 자기 행동을 스스로 결정하지 않는다, 전부 사람이 미리 써둔 대사/이벤트다"라고 먼저 짚어주면 헛도는 시간을 줄일 수 있을 듯.
3. 이 맥락에서 교수님이 NPC가 스스로 판단할 때 쓸 수 있는 3가지 대안 기법을 소개함:
   - **State machine** — 지금 쓰는 flag/if문 방식과 같은 것.
   - **Behavior tree** — 캐릭터마다 자기만의 트리를 갖고, 보는 변수(flag)가 바뀌면 트리 안 위치가 바뀌면서 다르게 반응.
   - **Utility system** — "you calculate an equation... based on the variable... combine all those variables into an action... multiply it... rank those numbers"라고 설명 (변수들을 하나의 숫자로 계산해서 제일 높은 걸 고르는 방식). **여기서 교수님이 직접 이렇게 말함: "That will work well with your new idea of AI, like writing text, and then you can divide it into numeric values."** → 즉 GenNPC의 텍스트 매칭 아이디어에 이 숫자 랭킹 방식을 적용해보라는 건 내(Claude)가 지어낸 비유가 아니라 **교수님이 직접 제안한 것**이었음 — 지난번 문서에 "이건 내 비유일 뿐"이라고 적었던 부분 정정.
4. API 관련: 지금 Claude 쓰고 있다고 답함, 무료 옵션으로 GLM 고려 중이라고 언급. 교수님이 추가로 **Gemini**(Google AI Studio, 무료 쿼터 있음, 코드에서 바로 호출 가능)와 **Hugging Face**(모델 다양, 일부 무료/일부 토큰 필요)도 제안함.
5. 연구 주제: "CS 관련이면 뭐든 좋고, state managing 쪽이면 더 좋다"고 답함. 교수님이 지금 project-jrpg NPC들이 **"그냥 서있기만 한다"**는 걸 확인하고, **NPC pathfinding/자율 이동을 새 연구 주제로 제안** — 나중에 강화학습(RL)까지 얹는 것도 가능하다고 언급.
6. 교수님의 실제 마지막 말(요약 아님, 원문): **"make it something you are interested in, figure out what you want to add to the game, we will link it to research. So next week you let me know what you want."**

### 그래서 다음 주(9/17)까지 정해야 하는 것 — 좁게 "utility로 GenNPC 만들기" 하나로 못박힌 게 아님
교수님이 낸 숙제는 "네가 게임에 실제로 추가하고 싶은 것 + 흥미 기준으로 하나 골라오면, 그걸 연구 주제로 formalize 해주겠다"는 열린 제안이었음. 그 안에서 구체적으로 뜬 후보는 두 개:
- **(A) GenNPC 계속 + utility식 숫자 스코어링 적용** — 교수님이 직접 제안한 조합, 지금까지 해온 설계 논의를 그대로 이어갈 수 있음.
- **(B) NPC pathfinding/자율 이동 (+선택적 RL)** — 완전히 새 주제, project-jrpg NPC가 "서있기만 하는" 문제를 실제로 풀게 됨.

**2026-09-10 대화(이 세션)에서 확정: (A)로 간다.** 이유는 위 "2026-09-10 결정" 섹션에 이미 적힌 대로 (설계 논의 진척도, 백본 안 건드리는 원칙, 스코프 관리). Pathfinding/RL은 **"나중에 할 수도 있는 phase 2 후보"**로만 기록해두고 지금은 착수 안 함.

**단, utility 스코어링을 GenNPC에 적용할 때 주의할 것**: 교수님이 설명한 utility system의 원래 예시(hunger/시간 같은 게임 내부 변수로 NPC가 자기 행동을 결정하는 것)와, GenNPC에 적용할 실제 방식(player가 친 텍스트와 각 후보 flag 사이의 관련도를 독립적으로 점수 매기는 것)은 **입력값 자체가 다른 별개의 계산**임 — 교수님도 "적용해볼 만하다"고 연결해준 것이지 "그대로 같은 것"이라고 하신 건 아니므로, 프로토타입 설계할 때 이 둘을 섞지 않도록 주의.

## 2026-09-13 첫 프로토타입 & 스모크 테스트

### 폴더 구조 (실수 하나 있었음, 정정)
Godot 새 프로젝트 만들 때 `project.godot`이 레포 루트가 아니라 `project-gennpc/` 하위 폴더에 생겨버림 (Godot "New Project" 다이얼로그가 프로젝트 이름으로 하위 폴더를 자동 생성한 것으로 추정). 그래서 최종 구조는:

```
project-GenNPC/              (git 레포 루트)
├── .git/
├── .gitignore
├── handoff.md
└── project-gennpc/          (진짜 Godot 프로젝트, res:// 기준점)
    ├── project.godot
    ├── .env                 (Gemini API 키, git에 안 올라감)
    ├── gennpc_test.gd
    └── test.tscn
```

git 자체엔 문제없음 (`.gitignore`의 `.godot/`, `.env` 패턴은 폴더 깊이 상관없이 적용됨).

### 스모크 테스트 결과 (Claude Code가 실행, Gemini API `gemini-3.6-flash` 사용)

| # | 입력 | 기대 결과 | 실제 결과 | 판정 |
|---|---|---|---|---|
| 1 | "아 배고프다" (명확) | go_eat | go_eat | ✅ |
| 2 | "음... 모르겠어" (애매) | none | none | ✅ |
| 3 | "오늘 날씨 어때?" (무관) | none | none | ✅ |

**3/3 통과.** 특히 2, 3번이 중요함 — 이게 이 프로젝트 시작할 때부터 걱정했던 "애매하거나 관계없는 입력이 왔을 때 안전하게 폴백하는지"에 대한 첫 실증 데이터. 명확한 입력만 맞추는 건 쉬운데, 폴백까지 확인된 건 이번이 처음.

지금까지는 [go_eat]/[go_home]/[go_movie] 3개짜리 목업 flag로만 테스트한 것 — 다음 단계는 이걸 project-jrpg 실제 세계관에 맞는 flag로 바꿔서 world bible(설정 문서)이랑 안 어긋나는지 테스트하는 것 (사용자가 처음부터 계획한 방향, 아직 안 건드림).

### 개발 환경 관련 참고
Claude Code가 이 컴퓨터에서 `godot`/`godot4` 실행 파일을 자동으로 못 찾음 (PATH에도, 일반 설치 경로에도 없음) — 그래서 headless 자동 테스트는 안 되고, 사용자가 Godot 에디터에서 직접 F6으로 돌려서 결과를 Claude Code/이 세션에 복사해주는 방식으로 진행 중. `godot-ai` MCP 서버도 연결 안 된 상태(ConnectionRefused). 앞으로도 이 방식(사용자가 직접 실행 → 결과 공유)으로 계속 갈 가능성 높음.

### GitHub 레포
https://github.com/547c/project-GenNPC (Public) — `git remote add` + `git push` 진행 중.

### API 제공자 후보 갱신 (9/10 미팅 반영)
- 지금 사용 중: Claude
- 무료 대안으로 고려 중: GLM
- 교수님 추가 제안: Gemini(Google AI Studio, 무료 쿼터), Hugging Face(일부 무료/일부 토큰 필요)
- → 아래 "아직 안 정해진 것" 체크리스트의 API 제공자 항목이 Claude vs OpenAI 2개에서 Claude/GLM/Gemini/Hugging Face 4개로 확장됨. 최종 결정은 여전히 미정.

## 2026-09-13 (계속) — 세계관 분리, 영어 전환, 다중 NPC, headless 자동화

### 결정: project-jrpg 실제 NPC/세계관 대신 완전히 별개인 합성 판타지 세계 사용
처음 계획은 project-jrpg의 진짜 NPC(카심 → 로한 → 엘라라 순으로 검토)를 재사용하는 것이었으나, 최종적으로 **project-jrpg 세계관/dialogue_data.gd와 완전히 무관한, 이 실험 전용의 작은 합성 판타지 세계**를 새로 만들기로 결정 (사용자 판단: "어차피 이건 교수랑 리서치하면서 정하는 프로젝트니 내 세계관 말고 jrpg랑 별개로 그냥 새로운 설정집 만들어서 새로운 npc 프로토타입을 만들까?"). 이유:
- project-jrpg 본편 lore/스포일러 리스크를 원천 차단.
- 리서치용 테스트베드는 검증된 메커니즘을 나중에 실제 NPC에 이식하는 게 목적이므로, 지금 단계에서 "이 NPC 써도 안전한가"를 매번 고민할 필요가 없음.

### 결정: NPC 1명이 아니라 2명으로 확장
나중에 GenNPC 메커니즘을 project-jrpg의 여러 실제 NPC에 적용할 가능성이 있으므로, 지금부터 "여러 NPC 각각 독립된 후보 목록을 갖고도 잘 작동하는지"를 검증하기로 함 (3명은 과함, 1명은 일반화 검증 불가 → 2명으로 결정).

### 결정: 이 서브프로젝트는 전부 영어로 진행
교수님(영어 사용자)과 함께하는 리서치 프로젝트이고, 테스트 입력도 영어로 칠 것이므로 **대사/설명(description) 전부 영어**로 작성하기로 함 (project-jrpg 본편은 한국어 유지, 이 서브프로젝트만 해당). 영어 난이도는 원어민 관용구 수준이 아니라 "유학 경험 있는 비원어민이 부담 없이 읽을 수 있는 평이하고 직관적인 영어"로 — 2차례 피드백 후 최종 확정 (예: "tracks" → "footprints"로 교체, 광부 스몰톡 소재를 공간적으로 모순되는 "It's dark down here"에서 "일이 힘든지" 쪽으로 교체).

### 최종 합성 NPC 콘텐츠 (`gennpc_test.gd`에 구현됨)

**Hunter "Daren"**

| id | description | response_text |
|---|---|---|
| forest_animals | wants to ask about strange behavior of animals in the forest | "The animals in the forest have been acting strange. Deer, foxes, all of them keep coming toward the village. That doesn't usually happen." |
| hunting_tips | wants to ask for hunting tips or advice | "Watch which way the wind is blowing. Check if the footprints are new or old. That's most of it." |
| smalltalk | just wants to make small talk, like about the weather | "The weather's strange lately. It should be getting colder by now, but it isn't." |

**Miner "Kor"**

| id | description | response_text |
|---|---|---|
| cave_rumor | wants to ask about strange rumors from the abandoned mine | "People say there are strange noises deep in the old mine. Some workers are too scared to go in." |
| equipment | wants to ask about mining equipment or tools | "You have to sharpen the pickaxe often. If you don't, you waste a lot of effort." |
| smalltalk | wants to ask if the mining work is hard or tiring | "It is tiring work. But I'm used to it by now." |

### 다중 NPC 리팩토링 + 테스트 결과
`classify_input(npc_id, player_text)` 형태로 리팩토링, NPC별 후보 목록 분리. 각 NPC 최소 1건씩 영어 입력으로 테스트:

| NPC | 입력 | 기대 결과 | 실제 결과 | 판정 |
|---|---|---|---|---|
| hunter | "Why are the animals acting so weird?" | forest_animals | forest_animals | ✅ |
| hunter | "Any tips for hunting?" | hunting_tips | hunting_tips | ✅ |
| hunter | "How's the weather today?" | smalltalk | smalltalk | ✅ |
| hunter | "I don't really know what to say" (애매) | none | none | ✅ |
| hunter | "Do you sell any weapons here?" (무관) | none | none | ✅ |
| miner | "Is something wrong in the mine?" | cave_rumor | cave_rumor | ✅ |
| miner | "What kind of tools do you use down there?" | equipment | equipment | ✅ |
| miner | "Isn't this work exhausting?" | smalltalk | smalltalk | ✅ |
| miner | "Hmm, not sure" (애매) | none | none | ✅ |
| miner | "What's your favorite food?" (무관) | none | none | ✅ |

**10/10 통과.** hunter/miner 각각 후보 3개 전부 + 애매한 입력 + 무관한 입력까지 커버 완료. 두 NPC의 후보 목록이 서로 완전히 분리되어 있고(hunter 입력이 miner 토픽으로 새지 않음, 역도 마찬가지), 애매/무관 입력 모두 `none`으로 정확히 폴백됨을 확인. 현재 프롬프트/description 구조에서 추가로 손볼 부분 없음 — 이 라운드는 코드 변경 없이 검증만 한 것이라 커밋 대상 아님.

### headless 자동 테스트 확보 (project-jrpg 수준으로 워크플로 개선)
Godot 실행 파일 경로 확보: `C:\Users\조영래\OneDrive\Desktop\Godot\Godot_v4.7.1-stable_win64.exe`. Claude Code가 이 경로로 headless 실행이 되는 걸 직접 확인함:

```
"/c/Users/조영래/OneDrive/Desktop/Godot/Godot_v4.7.1-stable_win64.exe" --headless --path "/c/Users/조영래/OneDrive/문서/project-GenNPC/project-gennpc" res://test.tscn
```

`classify_input()`/`_on_request_completed()`의 모든 종료 경로(API 키 없음, 알 수 없는 npc_id, HTTP 에러 응답, 정상 완료)에 `get_tree().quit()`을 추가해서 headless 모드에서 프로세스가 안 걸리고 항상 종료되도록 수정, exit code 0 확인 완료.

**이제부터 F6 + Output 패널 복붙 없이, Claude Code가 스스로 headless 실행 → 결과 확인 → 보고하는 방식으로 전환.** (아래 "개발 환경 관련 참고" 섹션에 적힌 "godot 실행 파일 못 찾음/headless 자동화 안 됨" 문제는 여기서 해결된 것으로 갱신.)

## 2026-09-13 (계속 2) — Phase 2 플레이 가능한 틀 + 모델 비교/확정

### Phase 2: 최소 게임 틀 구현
project-jrpg 코드는 재사용하지 않고 project-GenNPC 안에서 완전히 새로 작성하기로 결정 (이유: project-jrpg 대화 UI는 버튼 메뉴 방식이라 자유 텍스트 입력창은 어차피 새로 만들어야 해서 절반만 재사용하는 셈이고, GameState/오토로드 참조를 떼어내는 정리 비용이 더 클 것으로 판단).

새로 만든 것:
- `npc_classifier.gd` — `gennpc_test.gd`의 분류 로직을 게임용으로 재작성. `quit()` 대신 `classification_completed`/`classification_failed` 시그널로 결과를 돌려주는 재사용 가능한 노드.
- `player.gd` — WASD/방향키 자유 이동(충돌 무시).
- `game.gd` — NPC 범위 감지, E/Space 상호작용, 대화 UI 열고 닫기, 분류 결과 표시.
- `game.tscn` — Player + NPC_Hunter(Daren) + NPC_Miner(Kor) + 대화 UI.
- `gennpc_test.gd`/`test.tscn`(headless 회귀 테스트용)은 그대로 유지, 손대지 않음.

### 실제 플레이 중 발견한 버그: 인사말/추임새가 엉뚱한 답으로 새는 문제
사전 테스트 케이스는 다 통과했지만, 실제로 자유롭게 플레이해보니 바로 문제가 나옴 — hunter(Daren)한테 "okay cool", miner(Kor)한테 "hello"라고 치니 둘 다 `smalltalk`로 잘못 분류되어 뜬금없이 날씨/피곤함 얘기를 꺼냄. **사전에 다 못 만드는 애매한 입력 문제**(handoff.md 앞부분 "교수님 상담용 정리"에 이미 적어둔 그 우려)가 실전에서 그대로 확인된 사례 — 교수님한테 가져갈 실증 사례로 기록해둠.

원인: "smalltalk" 후보 설명이 제일 느슨해서, 특정 주제 없는 인사말/추임새가 들어오면 분류기가 그쪽으로 끌려감. `npc_classifier.gd`의 공용 프롬프트에 두 차례 규칙을 추가해 해결:
1. "인사말/추임새(hello, hi, okay, cool, thanks 등)만 있고 주제가 없으면 none" 규칙 추가
2. (1번 규칙 적용 후에도 남아있던 별개 케이스 — miner에게 "What's your favorite food?" → 여전히 `smalltalk`로 오분류) → "smalltalk는 description에 적힌 그 구체적 화제(날씨/피곤함)를 직접 언급할 때만 해당, 그 외 화제는 none" 규칙 + 반례를 추가로 명시

### 모델 비교: 3.6-flash → 3.5-flash-lite → gemma-4-31b-it 검토 → 3.5-flash-lite로 확정
개발 중 Gemini 무료 등급의 **일일 요청 한도(RPD)가 gemini-3.6-flash 기준 20건**이라는 걸 발견 — 하루 테스트만으로 바로 소진됨 (AI Studio "Rate Limit" 대시보드에서 확인: `https://aistudio.google.com` 안의 비율 제한 페이지). 이 태스크(자유 텍스트를 미리 정해진 소수 후보로 분류)가 고지능 모델이 필요한 일이 아니라는 점에 착안해 대안 모델을 조사/실측:

| 모델 | 일일 한도(RPD) | 이 태스크 적합성 |
|---|---|---|
| gemini-3.6-flash | 20 | 정확도 좋음 (10/10), 한도가 개발 단계엔 너무 빡빡함 |
| gemini-3.5-flash-lite | 500 | 처음엔 무관한 질문을 smalltalk로 오분류하는 문제 있었으나, 프롬프트 규칙 2차 보강 후 **14/14 통과** |
| gemma-4-31b-it (구글 오픈 모델, 같은 API로 호출 가능) | 14,400 | 추론 자체는 정확했으나(문제의 "food" 케이스도 논리적으론 맞힘), "id만 응답" 지시를 무시하고 매번 긴 서술형 응답을 냄 + 14건 중 3건(21%)이 HTTP 500/503로 응답 자체가 안 옴 → 지금 코드베이스(정확 문자열 매칭)와 안 맞고 안정성도 부족해 **채택 안 함** |

**최종 결정: `gemini-3.5-flash-lite`를 이 프로젝트의 기본 분류 모델로 확정.** 한도(500/일)와 검증된 정확도(14/14, 인사말·무관한 질문 폴백 케이스 포함) 둘 다 충족.

### 참고
- project-jrpg 본편 상태: Claude Project의 `project-jrpg-handoff.md` 참고 (여긴 안 건드림).
- EC/지원서 서사: `ec-resume-draft.md`에 이 프로젝트가 이미 초안으로 들어가 있음. Pattern A 결정에 맞게 그 문서의 "Autonomous AI NPC Dialogue Prototype" 설명도 업데이트가 필요할 수 있음 — 실제 진행 상황에 맞춰 다른 채팅에서 관리 중이니 그쪽에 이 결정 내용 전달 필요. (GenNPC 방향 유지가 EC 서사적으로도 맞는 선택인지는 이 채팅에서 확정 짓지 않음 — EC 전략은 다른 채팅이 전담.)
- 다음 정기 미팅: 매주 목요일 낮 12:00 (Central Time). 다음 미팅(9/17)까지 방향 결정 확정해서 알려드려야 함 (위 참고).
