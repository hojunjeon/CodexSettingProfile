# profile1

`profile1`은 기존 대화 문맥 없이도 Windows Codex 환경을 다시 세팅할 수 있게 만든 재사용 프로필입니다.

## 설치되는 것

- npm으로 설치하는 Codex CLI와 OpenCode.
- `npx lazycodex-ai install --no-tui --codex-autonomous`로 설치하는 LazyCodex/OmO.
- `https://github.com/DietrichGebert/ponytail.git`에서 가져오는 ponytail.
- `https://github.com/hojunjeon/trihead.git`에서 가져오는 trihead와 Windows UTF-8/aggressive 기본값 패치.
- 로컬 Codex 플러그인 `trihead-optimizer`.
- `%USERPROFILE%\.codex\AGENTS.md`에 들어가는 전역 trihead 사용 규칙.
- `%USERPROFILE%\.codex\config.toml`에 들어가는 휴대 가능한 Codex 설정값.

## 요구사항

- Windows PowerShell.
- PATH에 잡힌 Git.
- PATH에 잡힌 Node.js, `npm`, `npx`.
- PATH에 잡힌 Python과 `pip`.
- GitHub, npm, PyPI에 접근 가능한 네트워크.
- Codex 계정 로그인은 머신마다 직접 해야 합니다.
- GitHub CLI 인증은 GitHub 작업이 필요할 때만 직접 하면 됩니다.

## 고정된 입력값

- `@openai/codex@0.142.4`
- `opencode-ai@1.17.11`
- `lazycodex-ai@4.14.1`
- `hojunjeon/trihead` commit `7ab5391531a3825c88d89073660154ae6bb93fff`
- `DietrichGebert/ponytail` commit `16f6cbf4b87792938e47b0f8c650b6d80fcbc98c`

## 파일 구성

- `AGENTS.md`: 설치 시 Codex home으로 복사되는 trihead 운영 규칙.
- `config.codex.example.toml`: 설치 스크립트가 적용하는 Codex 설정값의 읽기용 기준.
- `install-profile1.ps1`: 설치/적용 스크립트.
- `verify-profile1.ps1`: 설치 상태 검증 스크립트.
- `plugins/trihead-optimizer/`: 함께 배포하는 개인 플러그인.
- `patches/trihead-windows-aggressive.patch`: 설치 스크립트가 trihead에 적용하는 Windows 패치.
- `reports/`: 원본 머신에서 측정한 설치/벤치마크 근거.

## 설치

이 저장소 루트에서 실행합니다.

```powershell
powershell -ExecutionPolicy Bypass -File .\profile1\install-profile1.ps1
powershell -ExecutionPolicy Bypass -File .\profile1\verify-profile1.ps1
```

설치 스크립트는 기존 `%USERPROFILE%\.codex\AGENTS.md`와 `%USERPROFILE%\.codex\config.toml`을 백업한 뒤 수정합니다. 전체 config를 덮어쓰지 않고 필요한 profile 키만 upsert합니다.

설치 스크립트는 `%USERPROFILE%\.agents\plugins\marketplace.json`도 작성해서 `trihead-optimizer@personal`이 `codex plugin list`에서 발견되게 만듭니다.

trihead checkout은 `%USERPROFILE%\.codex-profile1\trihead` 아래에서 관리합니다. 그래서 설치 스크립트가 고정 commit으로 reset해도 사용자의 개인 소스 checkout을 건드리지 않습니다.

## 설치 후

필요하면 아래 명령을 직접 실행합니다.

```powershell
codex login
gh auth login
```

설치가 끝나면 Codex를 재시작해 플러그인, hook, `AGENTS.md`가 다시 로드되게 하세요.

## 검증 기준

- `codex --version`이 Codex CLI 버전을 출력합니다.
- `omo --version`이 OmO 버전을 출력합니다.
- `opencode --version`이 OpenCode 버전을 출력합니다.
- `trihead stats`가 실행되고 `%USERPROFILE%\.trihead`를 사용합니다.
- `omo doctor`가 `System OK` 또는 머신 인증 관련 이슈만 보고합니다.
- `codex plugin list`에 `omo@sisyphuslabs`, `ponytail@ponytail`, `trihead-optimizer@personal`이 installed/enabled 상태로 보입니다.

원본 머신에서는 36개 개발 상황 샘플에서 vanilla 대비 토큰 52.22% 절약, 품질 점수 평균 1.000을 측정했습니다. 자세한 값은 `reports/vanilla_vs_current_benchmark.md`를 보세요.
