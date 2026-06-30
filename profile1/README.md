# profile1

This profile makes a Windows Codex environment reusable without relying on the original chat context.

## What It Installs

- Codex CLI and OpenCode through npm.
- LazyCodex/OmO through `npx lazycodex-ai install --no-tui --codex-autonomous`.
- ponytail from `https://github.com/DietrichGebert/ponytail.git`.
- trihead from `https://github.com/hojunjeon/trihead.git`, with the included Windows UTF-8 and aggressive-default patch.
- A local `trihead-optimizer` Codex plugin.
- Global trihead guidance in `%USERPROFILE%\.codex\AGENTS.md`.
- Portable Codex config values in `%USERPROFILE%\.codex\config.toml`.

## Requirements

- Windows PowerShell.
- Git on PATH.
- Node.js with `npm` and `npx` on PATH.
- Python on PATH.
- Network access to GitHub, npm, and PyPI.
- Codex account/login is still machine-specific.
- GitHub CLI auth is optional unless you need GitHub operations.

## Pinned Inputs

- `@openai/codex@0.142.4`
- `opencode-ai@1.17.11`
- `lazycodex-ai@4.14.1`
- `hojunjeon/trihead` commit `7ab5391531a3825c88d89073660154ae6bb93fff`
- `DietrichGebert/ponytail` commit `16f6cbf4b87792938e47b0f8c650b6d80fcbc98c`

## Files

- `AGENTS.md`: trihead operating rules copied into Codex home.
- `config.codex.example.toml`: readable reference for the config values applied by the installer.
- `install-profile1.ps1`: setup script.
- `verify-profile1.ps1`: local verification script.
- `plugins/trihead-optimizer/`: bundled personal plugin.
- `patches/trihead-windows-aggressive.patch`: trihead Windows patch used by the installer.
- `reports/`: source-machine setup and benchmark evidence.

## Install

Run from this repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\profile1\install-profile1.ps1
powershell -ExecutionPolicy Bypass -File .\profile1\verify-profile1.ps1
```

The installer backs up existing `%USERPROFILE%\.codex\AGENTS.md` and `%USERPROFILE%\.codex\config.toml` before changing them. It upserts only the profile keys it needs instead of replacing the whole config.

The installer also writes `%USERPROFILE%\.agents\plugins\marketplace.json` so `trihead-optimizer@personal` is discoverable by `codex plugin list`.

The trihead checkout is managed under `%USERPROFILE%\.codex-profile1\trihead` so the installer can reset it to the pinned commit without touching a personal source checkout.

## After Install

Run these if needed:

```powershell
codex login
gh auth login
```

Restart Codex after the installer finishes so plugins, hooks, and AGENTS.md are reloaded.

## Expected Verification

- `codex --version` prints a Codex CLI version.
- `omo --version` prints an OmO version.
- `opencode --version` prints an OpenCode version.
- `trihead stats` runs and uses `%USERPROFILE%\.trihead`.
- `omo doctor` reports `System OK` or only machine-auth issues.
- `codex plugin list` shows `omo@sisyphuslabs`, `ponytail@ponytail`, and `trihead-optimizer@personal` installed/enabled.

The source machine measured 52.22% token reduction across 36 development scenarios with quality score average 1.000. See `reports/vanilla_vs_current_benchmark.md`.
