---
name: trihead-token-optimizer
description: Use trihead to reduce token usage for large command outputs, logs, JSON payloads, diffs, searches, and final summaries while preserving deterministic facts.
---

# Trihead Token Optimizer

Use this skill whenever work may produce large command output, logs, diffs, JSON, file lists, search results, or long summaries.

## Commands

- Prefer `trihead run --hint <type> -- <command...>` for noisy commands.
- Use `trihead filter --hint rg <file>` for search output.
- Use `trihead compress --mode aggressive --hint <type> <file>` for saved large output.
- Use `trihead shape <file>` before long narrative summaries.
- Use `trihead retrieve <sha>` only when a compressed result's CCR marker is needed to recover the full original.

## Quality Rules

- Preserve exact file paths, line numbers, error names, URLs, hashes, IDs, JSON keys, status fields, failing assertions, and commands.
- Do not compress away information needed to reproduce, verify, or fix a failure.
- If a compressed result looks too lossy, rerun with `--mode balanced` or retrieve the original.
