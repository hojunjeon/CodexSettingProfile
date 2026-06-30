# profile1

Codex를 고성능, 고효율 작업용으로 맞추는 재사용 프로필입니다. 현재 머신에서 검증한 LazyCodex/OmO, ponytail, trihead 중심 세팅을 다른 환경에 옮길 수 있게 문서와 스크립트로 정리했습니다.

## 목표

- 성능: Codex reasoning을 높게 두고 LazyCodex/OmO의 도구, 훅, 하위 에이전트 기능을 사용합니다.
- 토큰 절약: trihead를 noisy command, diff, rg, pytest, JSON, 파일 목록 출력에 기본 적용합니다.
- 품질: ponytail로 과한 구조를 줄이고, trihead는 경로, 라인 번호, 에러명, URL, 해시, ID, JSON 키, 실패 assertion 같은 재현 정보는 보존하도록 강제합니다.

## 포함 파일

- `AGENTS.md`: 모든 워크스페이스에 넣을 trihead 사용 규칙.
- `config.codex.example.toml`: 현재 검증된 Codex 설정의 휴대 가능한 핵심 예시.
- `install-profile1.ps1`: Windows PowerShell 설치/적용 스크립트.
- `verify-profile1.ps1`: 설치 상태 점검 스크립트.
- `plugins/trihead-optimizer/`: 개인 Codex 플러그인으로 재사용할 trihead 스킬.
- `patches/trihead-windows-aggressive.patch`: Windows cp949/UTF-8 대응과 aggressive 기본값 패치.
- `reports/`: 현재 머신에서 측정한 벤치마크와 세팅 요약.

## 설치

PowerShell에서 이 저장소 루트 기준으로 실행합니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\profile1\install-profile1.ps1
powershell -ExecutionPolicy Bypass -File .\profile1\verify-profile1.ps1
```

설치 스크립트는 `$env:USERPROFILE\.codex\AGENTS.md`를 적용하고, 기존 파일이 있으면 백업합니다. `TRIHEAD_HOME`은 사용자 환경변수로 `$env:USERPROFILE\.trihead`에 맞춥니다.

## Codex 설정

`config.codex.example.toml`은 전체 설정 파일이 아니라 병합용 예시입니다. 기존 `$env:USERPROFILE\.codex\config.toml`을 통째로 덮어쓰지 말고 필요한 항목만 반영하세요. 훅 trust hash, OpenAI Desktop 런타임 경로, keyring, GitHub 인증 상태는 머신마다 다르므로 이 프로필에 포함하지 않습니다.

## 인증

GitHub 인증은 복사하지 않습니다. 새 머신에서는 직접 실행합니다.

```powershell
gh auth login
gh auth status
```

## 검증 기준

현재 원본 환경 기준 확인값은 다음과 같습니다.

- `codex-cli 0.142.4`
- `omo 4.14.1`
- `opencode 1.17.11`
- `omo doctor`: `System OK`
- benchmark: 36개 개발 상황 샘플에서 vanilla 대비 토큰 52.22% 절약, 품질 점수 평균 1.000

정확한 수치는 `reports/vanilla_vs_current_benchmark.md`를 참고하세요.
