$ErrorActionPreference = "Stop"

$failures = New-Object System.Collections.Generic.List[string]

function Add-Failure($Message) {
    [void]$failures.Add($Message)
    Write-Error $Message -ErrorAction Continue
}

function Test-CommandExists($Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Add-Failure "$Name not found"
        return $false
    }
    return $true
}

function Invoke-Required($Name, $Command, $CommandArgs) {
    Write-Host ""
    Write-Host "[$Name]"
    if (-not (Test-CommandExists $Command)) {
        return
    }
    & $Command @CommandArgs
    if ($LASTEXITCODE -ne 0) {
        Add-Failure "$Name failed with exit code $LASTEXITCODE"
    }
}

$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE ".codex" }
$expectedTriheadHome = Join-Path $env:USERPROFILE ".trihead"
if (-not $env:TRIHEAD_HOME) {
    $env:TRIHEAD_HOME = [Environment]::GetEnvironmentVariable("TRIHEAD_HOME", "User")
}

Write-Host "== profile1 verification =="
Write-Host "CODEX_HOME=$CodexHome"
Write-Host "TRIHEAD_HOME=$env:TRIHEAD_HOME"

if ($env:TRIHEAD_HOME -ne $expectedTriheadHome) {
    Add-Failure "TRIHEAD_HOME is not the expected global path: $expectedTriheadHome"
}

Invoke-Required "codex" "codex" @("--version")
Invoke-Required "omo" "omo" @("--version")
Invoke-Required "opencode" "opencode" @("--version")
Invoke-Required "trihead" "trihead" @("stats")

Write-Host ""
Write-Host "[doctor]"
if (Get-Command omo -ErrorAction SilentlyContinue) {
    omo doctor
    if ($LASTEXITCODE -ne 0) {
        Add-Failure "omo doctor failed with exit code $LASTEXITCODE"
    }
} else {
    Add-Failure "omo not found"
}

Write-Host ""
Write-Host "[github]"
if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh auth status
} else {
    Write-Warning "gh not found; run gh auth login on this machine if GitHub access is needed."
}

Write-Host ""
Write-Host "[plugins]"
if (Get-Command codex -ErrorAction SilentlyContinue) {
    $pluginList = codex plugin list | Out-String
    foreach ($plugin in @("omo@sisyphuslabs", "ponytail@ponytail", "trihead-optimizer@personal")) {
        if ($pluginList -match [System.Text.RegularExpressions.Regex]::Escape($plugin)) {
            Write-Host "$plugin ok"
        } else {
            Add-Failure "$plugin missing from codex plugin list"
        }
    }
} else {
    Add-Failure "codex not found"
}

Write-Host ""
Write-Host "[config]"
$config = Join-Path $CodexHome "config.toml"
if (Test-Path $config) {
    $configText = Get-Content -Raw $config
    foreach ($pattern in @('model = "gpt-5.5"', 'model_reasoning_effort = "xhigh"', 'trihead-optimizer@personal', 'ponytail@ponytail', 'omo@sisyphuslabs')) {
        if ($configText -match [System.Text.RegularExpressions.Regex]::Escape($pattern)) {
            Write-Host "$pattern ok"
        } else {
            Add-Failure "$pattern missing from $config"
        }
    }
} else {
    Add-Failure "$config not found"
}

Write-Host ""
Write-Host "[AGENTS.md]"
$agents = Join-Path $CodexHome "AGENTS.md"
if (Test-Path $agents) {
    $agentsText = Get-Content -Raw $agents
    foreach ($pattern in @("trihead", "TRIHEAD_HOME")) {
        if ($agentsText -match $pattern) {
            Write-Host "$pattern ok"
        } else {
            Add-Failure "$pattern missing from $agents"
        }
    }
} else {
    Add-Failure "$agents not found"
}

if ($failures.Count -gt 0) {
    Write-Host ""
    Write-Host "profile1 verification failed:"
    foreach ($failure in $failures) {
        Write-Host "- $failure"
    }
    exit 1
}

Write-Host ""
Write-Host "profile1 verification passed."
