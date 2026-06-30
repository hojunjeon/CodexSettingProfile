$ErrorActionPreference = "Stop"

$ProfileRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE ".codex" }
$TriheadHome = Join-Path $env:USERPROFILE ".trihead"
$PluginTarget = Join-Path $env:USERPROFILE "plugins\trihead-optimizer"
$TriheadRepo = Join-Path $env:USERPROFILE "src\trihead"

New-Item -ItemType Directory -Force $CodexHome, $TriheadHome, (Split-Path -Parent $PluginTarget), (Split-Path -Parent $TriheadRepo) | Out-Null
[Environment]::SetEnvironmentVariable("TRIHEAD_HOME", $TriheadHome, "User")
$env:TRIHEAD_HOME = $TriheadHome

$agentsSource = Join-Path $ProfileRoot "AGENTS.md"
$agentsTarget = Join-Path $CodexHome "AGENTS.md"
if (Test-Path $agentsTarget) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    Copy-Item -LiteralPath $agentsTarget -Destination "$agentsTarget.bak-$stamp" -Force
}
Copy-Item -LiteralPath $agentsSource -Destination $agentsTarget -Force

$pluginSource = Join-Path $ProfileRoot "plugins\trihead-optimizer"
if (Test-Path $PluginTarget) {
    Remove-Item -LiteralPath $PluginTarget -Recurse -Force
}
Copy-Item -LiteralPath $pluginSource -Destination $PluginTarget -Recurse -Force

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    throw "npm is required before installing Codex/LazyCodex tooling."
}

npm install -g "@openai/codex@latest" "opencode-ai@latest"
npx lazycodex-ai install --no-tui --codex-autonomous

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git is required before installing the patched trihead checkout."
}

if (-not (Test-Path $TriheadRepo)) {
    git clone "https://github.com/hojunjeon/trihead.git" $TriheadRepo
} else {
    git -C $TriheadRepo fetch --all --prune
    git -C $TriheadRepo pull --ff-only
}

$patch = Join-Path $ProfileRoot "patches\trihead-windows-aggressive.patch"
git -C $TriheadRepo apply --reverse --check $patch 2>$null
if ($LASTEXITCODE -ne 0) {
    git -C $TriheadRepo apply --check $patch
    git -C $TriheadRepo apply $patch
}

python -m pip install --upgrade pip
python -m pip install --force-reinstall $TriheadRepo

Write-Host "profile1 applied."
Write-Host "TRIHEAD_HOME=$TriheadHome"
Write-Host "Review profile1\config.codex.example.toml and merge needed settings into $CodexHome\config.toml."
Write-Host "Run profile1\verify-profile1.ps1 next."
