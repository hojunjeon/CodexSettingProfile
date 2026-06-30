Use trihead for token-heavy work.

- `TRIHEAD_HOME` is configured as `%USERPROFILE%\.trihead`; keep CCR storage global across workspaces.
- Prefer `trihead run --hint <rg|pytest|diff|json|files> -- <command...>` for noisy shell commands.
- Use `trihead compress --mode aggressive --hint <type> <file>` for large saved outputs.
- Use `trihead filter --hint <type> <file>` for rg, pytest, diff, and file-list output.
- Use `trihead shape <file>` before long summaries when exact facts are already preserved.
- Preserve exact paths, line numbers, error names, URLs, hashes, IDs, JSON keys, status fields, failing assertions, and commands.
- If a `[trihead ccr:<sha>]` marker appears, retrieve the full original only when needed with `trihead retrieve <sha>`.
