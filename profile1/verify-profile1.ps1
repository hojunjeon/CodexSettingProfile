$ErrorActionPreference = "Continue"

$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE ".codex" }
$expectedTriheadHome = Join-Path $env:USERPROFILE ".trihead"
if (-not $env:TRIHEAD_HOME) {
    $env:TRIHEAD_HOME = [Environment]::GetEnvironmentVariable("TRIHEAD_HOME", "User")
}

Write-Host "== profile1 verification =="
Write-Host "CODEX_HOME=$CodexHome"
Write-Host "TRIHEAD_HOME=$env:TRIHEAD_HOME"

if ($env:TRIHEAD_HOME -ne $expectedTriheadHome) {
    Write-Warning "TRIHEAD_HOME is not the expected global path: $expectedTriheadHome"
}

$checks = @(
    @{ Name = "codex"; Command = "codex"; Args = @("--version") },
    @{ Name = "omo"; Command = "omo"; Args = @("--version") },
    @{ Name = "opencode"; Command = "opencode"; Args = @("--version") },
    @{ Name = "trihead"; Command = "trihead"; Args = @("stats") }
)

foreach ($check in $checks) {
    Write-Host ""
    Write-Host "[$($check.Name)]"
    if (Get-Command $check.Command -ErrorAction SilentlyContinue) {
        & $check.Command @($check.Args)
    } else {
        Write-Warning "$($check.Command) not found"
    }
}

Write-Host ""
Write-Host "[doctor]"
if (Get-Command omo -ErrorAction SilentlyContinue) {
    omo doctor
} else {
    Write-Warning "omo not found"
}

Write-Host ""
Write-Host "[github]"
if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh auth status
} else {
    Write-Warning "gh not found; run gh auth login on this machine if GitHub access is needed."
}

Write-Host ""
Write-Host "[AGENTS.md]"
$agents = Join-Path $CodexHome "AGENTS.md"
if (Test-Path $agents) {
    Select-String -Path $agents -Pattern "trihead|TRIHEAD_HOME" | Select-Object -First 8
} else {
    Write-Warning "$agents not found"
}
