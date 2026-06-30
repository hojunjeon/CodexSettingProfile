# Vanilla Codex vs Current LazyCodex/Trihead Setup Benchmark

Scope: local CLI-output token workload benchmark. Vanilla means raw command/log text sent as-is. Current means trihead aggressive compression/filtering with current Codex/LazyCodex setup.

## Summary

| Cases | Vanilla tokens | Current tokens | Token saved | Mean quality | Mean preprocess ms |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 36 | 61,744 | 29,501 | 52.2% | 1.000 | 11.63 |

## By Category

| Category | Cases | Vanilla tokens | Current tokens | Token saved | Mean quality | Mean preprocess ms |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| agent | 1 | 1,470 | 240 | 83.7% | 1.000 | 5.83 |
| auth | 1 | 62 | 54 | 12.9% | 1.000 | 2.47 |
| build | 2 | 2,192 | 439 | 80.0% | 1.000 | 4.56 |
| ci | 1 | 1,164 | 295 | 74.7% | 1.000 | 8.00 |
| config | 1 | 35 | 36 | 0.0% | 1.000 | 0.52 |
| database | 1 | 737 | 150 | 79.7% | 1.000 | 4.20 |
| debug | 3 | 2,430 | 1,202 | 50.5% | 1.000 | 5.27 |
| deploy | 1 | 1,353 | 195 | 85.6% | 1.000 | 7.31 |
| deps | 1 | 2,719 | 242 | 91.1% | 1.000 | 7.83 |
| diff | 3 | 4,499 | 4,318 | 4.0% | 1.000 | 24.93 |
| docs | 1 | 1,836 | 196 | 89.3% | 1.000 | 7.20 |
| doctor | 2 | 66 | 68 | 0.0% | 1.000 | 0.71 |
| files | 1 | 5,459 | 5,070 | 7.1% | 1.000 | 71.04 |
| frontend | 1 | 631 | 162 | 74.3% | 1.000 | 3.71 |
| git | 1 | 1,050 | 150 | 85.7% | 1.000 | 4.60 |
| install | 1 | 1,126 | 153 | 86.4% | 1.000 | 5.89 |
| json | 2 | 10,727 | 619 | 94.2% | 1.000 | 17.70 |
| lsp | 1 | 6,229 | 6,229 | 0.0% | 1.000 | 24.35 |
| review | 1 | 1,759 | 1,760 | 0.0% | 1.000 | 9.97 |
| search | 2 | 6,238 | 6,207 | 0.5% | 1.000 | 32.42 |
| security | 2 | 3,861 | 521 | 86.5% | 1.000 | 9.96 |
| tests | 6 | 6,101 | 1,195 | 80.4% | 1.000 | 5.73 |

## Case Detail

| Case | Category | Source | Hint | Vanilla | Current | Saved | Quality | Method | CCR | ms | Workload ratio |
| --- | --- | --- | --- | ---: | ---: | ---: | ---: | --- | --- | ---: | ---: |
| real trihead unittest pass | tests | real | pytest | 21 | 3 | 85.7% | 1.000 | rtk_filter | no | 1.87 | 0.143 |
| real trihead compileall | build | real | log | 11 | 11 | 0.0% | 1.000 | raw | no | 0.45 | 1.000 |
| real codex doctor json | doctor | real | json | 35 | 36 | 0.0% | 1.000 | raw | no | 0.74 | 1.029 |
| real omo doctor | doctor | real | log | 31 | 32 | 0.0% | 1.000 | raw | no | 0.68 | 1.032 |
| real gh auth status | auth | real | log | 62 | 54 | 12.9% | 1.000 | structure_summary | yes | 2.47 | 0.871 |
| real plugin list | config | real | log | 35 | 36 | 0.0% | 1.000 | raw | no | 0.52 | 1.029 |
| real trihead source rg | search | real | rg | 3,956 | 3,956 | 0.0% | 1.000 | raw | no | 15.93 | 1.000 |
| real trihead git diff | diff | real | diff | 1,561 | 1,561 | 0.0% | 1.000 | raw | no | 32.10 | 1.000 |
| synthetic large rg | search | synthetic | rg | 2,282 | 2,251 | 1.4% | 1.000 | structure_summary | yes | 48.91 | 0.986 |
| synthetic file list | files | synthetic | files | 5,459 | 5,070 | 7.1% | 1.000 | structure_summary | yes | 71.04 | 0.929 |
| synthetic deploy json | json | synthetic | json | 6,518 | 457 | 93.0% | 1.000 | structure_summary | yes | 24.57 | 0.070 |
| synthetic failing pytest | tests | synthetic | pytest | 458 | 121 | 73.6% | 1.000 | structure_summary | yes | 5.34 | 0.264 |
| synthetic python traceback | debug | synthetic | log | 868 | 185 | 78.7% | 1.000 | structure_summary | yes | 8.90 | 0.213 |
| synthetic github actions log | ci | synthetic | log | 1,164 | 295 | 74.7% | 1.000 | structure_summary | yes | 8.00 | 0.253 |
| synthetic multi-file diff | diff | synthetic | diff | 1,368 | 1,187 | 13.2% | 1.000 | structure_summary | yes | 25.84 | 0.868 |
| synthetic lsp diagnostics | lsp | synthetic | json | 6,229 | 6,229 | 0.0% | 1.000 | raw | no | 24.35 | 1.000 |
| synthetic package install log | install | synthetic | log | 1,126 | 153 | 86.4% | 1.000 | structure_summary | yes | 5.89 | 0.136 |
| synthetic docker build | build | synthetic | log | 2,181 | 428 | 80.4% | 1.000 | structure_summary | yes | 8.68 | 0.196 |
| synthetic migration sql diff | diff | synthetic | diff | 1,570 | 1,570 | 0.0% | 1.000 | raw | no | 16.86 | 1.000 |
| synthetic api error burst | json | synthetic | json | 4,209 | 162 | 96.2% | 1.000 | structure_summary | yes | 10.82 | 0.038 |
| synthetic windows cp949 error | debug | synthetic | log | 629 | 83 | 86.8% | 1.000 | structure_summary | yes | 3.13 | 0.132 |
| synthetic npm audit | security | synthetic | json | 2,651 | 358 | 86.5% | 1.000 | structure_summary | yes | 14.30 | 0.135 |
| synthetic review comments | review | synthetic | log | 1,759 | 1,760 | 0.0% | 1.000 | raw | no | 9.97 | 1.001 |
| synthetic flaky test history | tests | synthetic | log | 1,645 | 418 | 74.6% | 1.000 | structure_summary | yes | 9.44 | 0.254 |
| synthetic cargo failure | tests | synthetic | cargo | 778 | 92 | 88.2% | 1.000 | structure_summary | yes | 3.91 | 0.118 |
| synthetic go race log | debug | synthetic | log | 933 | 934 | 0.0% | 1.000 | raw | no | 3.79 | 1.001 |
| synthetic playwright failure | tests | synthetic | log | 585 | 142 | 75.7% | 1.000 | structure_summary | yes | 3.93 | 0.243 |
| synthetic browser console | frontend | synthetic | log | 631 | 162 | 74.3% | 1.000 | structure_summary | yes | 3.71 | 0.257 |
| synthetic coverage report | tests | synthetic | log | 2,614 | 419 | 84.0% | 1.000 | structure_summary | yes | 9.88 | 0.160 |
| synthetic merge conflict | git | synthetic | log | 1,050 | 150 | 85.7% | 1.000 | structure_summary_aggressive | yes | 4.60 | 0.143 |
| synthetic secrets scan | security | synthetic | log | 1,210 | 163 | 86.5% | 1.000 | structure_summary | yes | 5.61 | 0.135 |
| synthetic kubernetes events | deploy | synthetic | log | 1,353 | 195 | 85.6% | 1.000 | structure_summary | yes | 7.31 | 0.144 |
| synthetic dependency tree | deps | synthetic | log | 2,719 | 242 | 91.1% | 1.000 | structure_summary | yes | 7.83 | 0.089 |
| synthetic sql duplicate key | database | synthetic | log | 737 | 150 | 79.7% | 1.000 | structure_summary | yes | 4.20 | 0.204 |
| synthetic agent prompt trace | agent | synthetic | log | 1,470 | 240 | 83.7% | 1.000 | structure_summary | yes | 5.83 | 0.163 |
| synthetic release notes | docs | synthetic | log | 1,836 | 196 | 89.3% | 1.000 | structure_summary | yes | 7.20 | 0.107 |

## Notes

- Quality is trihead fact-preservation score against the raw text; vanilla raw output is the reference.
- Performance is measured as model input workload reduction plus local preprocessing overhead. It does not claim model answer accuracy from live repeated model calls.
- CCR yes means the full original was stored and can be recovered with `trihead retrieve <sha>` when exact omitted context is needed.
- Short already-compact outputs may show 0% savings; current setup keeps them raw rather than forcing lossy compression.
