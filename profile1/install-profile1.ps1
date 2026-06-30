$ErrorActionPreference = "Stop"

$ProfileRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE ".codex" }
$TriheadHome = Join-Path $env:USERPROFILE ".trihead"
$PluginTarget = Join-Path $env:USERPROFILE "plugins\trihead-optimizer"
$TriheadRepo = Join-Path $env:USERPROFILE ".codex-profile1\trihead"
$CodexConfig = Join-Path $CodexHome "config.toml"
$PersonalMarketplace = Join-Path $env:USERPROFILE ".agents\plugins\marketplace.json"
$CodexVersion = "0.142.4"
$OpenCodeVersion = "1.17.11"
$LazyCodexVersion = "4.14.1"
$CodexNpmPackage = "@openai/codex@$CodexVersion"
$OpenCodeNpmPackage = "opencode-ai@$OpenCodeVersion"
$LazyCodexNpmPackage = "lazycodex-ai@$LazyCodexVersion"
$TriheadRef = "7ab5391531a3825c88d89073660154ae6bb93fff"
$PonytailRef = "16f6cbf4b87792938e47b0f8c650b6d80fcbc98c"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Save-Text($Path, $Text) {
    [System.IO.File]::WriteAllText($Path, $Text, $Utf8NoBom)
}

function Save-Lines($Path, $Lines) {
    Save-Text $Path (($Lines -join [Environment]::NewLine) + [Environment]::NewLine)
}

function Invoke-Native($Command, $CommandArgs) {
    & $Command @CommandArgs
    if ($LASTEXITCODE -ne 0) {
        throw "$Command $($CommandArgs -join ' ') failed with exit code $LASTEXITCODE"
    }
}

function Get-ToolOutput($Command, $CommandArgs) {
    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        return ""
    }
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $output = & $Command @CommandArgs 2>$null | Out-String
    $ErrorActionPreference = $previousErrorActionPreference
    return $output.Trim()
}

function Set-TomlValue($Path, $Table, $Key, $Value) {
    $lines = New-Object System.Collections.Generic.List[string]
    if (Test-Path $Path) {
        foreach ($line in [System.IO.File]::ReadAllLines((Resolve-Path $Path))) {
            [void]$lines.Add($line)
        }
    }

    $start = 0
    $end = $lines.Count
    if ($Table) {
        $header = "[$Table]"
        $headerIndex = -1
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i].Trim() -eq $header) {
                $headerIndex = $i
                break
            }
        }
        if ($headerIndex -lt 0) {
            if ($lines.Count -gt 0 -and $lines[$lines.Count - 1].Trim()) {
                [void]$lines.Add("")
            }
            [void]$lines.Add($header)
            [void]$lines.Add("$Key = $Value")
            Save-Lines $Path $lines
            return
        }
        $start = $headerIndex + 1
        $end = $lines.Count
        for ($i = $start; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match '^\s*\[') {
                $end = $i
                break
            }
        }
    } else {
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match '^\s*\[') {
                $end = $i
                break
            }
        }
    }

    $keyPattern = '^\s*' + [System.Text.RegularExpressions.Regex]::Escape($Key) + '\s*='
    for ($i = $start; $i -lt $end; $i++) {
        if ($lines[$i] -match $keyPattern) {
            $lines[$i] = "$Key = $Value"
            Save-Lines $Path $lines
            return
        }
    }
    $lines.Insert($end, "$Key = $Value")
    Save-Lines $Path $lines
}

New-Item -ItemType Directory -Force $CodexHome, $TriheadHome, (Split-Path -Parent $PluginTarget), (Split-Path -Parent $TriheadRepo), (Split-Path -Parent $PersonalMarketplace) | Out-Null
[Environment]::SetEnvironmentVariable("TRIHEAD_HOME", $TriheadHome, "User")
$env:TRIHEAD_HOME = $TriheadHome

$agentsSource = Join-Path $ProfileRoot "AGENTS.md"
$agentsTarget = Join-Path $CodexHome "AGENTS.md"
if (Test-Path $agentsTarget) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    Copy-Item -LiteralPath $agentsTarget -Destination "$agentsTarget.bak-$stamp" -Force
}
$agentsText = [System.IO.File]::ReadAllText((Resolve-Path $agentsSource)).Replace("%USERPROFILE%\.trihead", $TriheadHome)
Save-Text $agentsTarget $agentsText

if (Test-Path $CodexConfig) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    Copy-Item -LiteralPath $CodexConfig -Destination "$CodexConfig.bak-$stamp" -Force
} else {
    Save-Text $CodexConfig ""
}

$pluginSource = Join-Path $ProfileRoot "plugins\trihead-optimizer"
if (Test-Path $PluginTarget) {
    Remove-Item -LiteralPath $PluginTarget -Recurse -Force
}
Copy-Item -LiteralPath $pluginSource -Destination $PluginTarget -Recurse -Force
Save-Text $PersonalMarketplace @'
{
  "name": "personal",
  "interface": {
    "displayName": "Personal"
  },
  "plugins": [
    {
      "name": "trihead-optimizer",
      "source": {
        "source": "local",
        "path": "./plugins/trihead-optimizer"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Productivity"
    }
  ]
}
'@

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    throw "npm is required before installing Codex/LazyCodex tooling."
}
if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    throw "npx is required before installing LazyCodex."
}
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "python is required before installing trihead."
}
Invoke-Native "python" @("-m", "pip", "--version")

$currentCodex = Get-ToolOutput "codex" @("--version")
if ($currentCodex -notmatch [System.Text.RegularExpressions.Regex]::Escape($CodexVersion)) {
    Invoke-Native "npm" @("install", "-g", $CodexNpmPackage)
} else {
    Write-Host "codex $CodexVersion already installed."
}

$currentOpenCode = Get-ToolOutput "opencode" @("--version")
if ($currentOpenCode -notmatch [System.Text.RegularExpressions.Regex]::Escape($OpenCodeVersion)) {
    Invoke-Native "npm" @("install", "-g", $OpenCodeNpmPackage)
} else {
    Write-Host "opencode $OpenCodeVersion already installed."
}

$currentOmo = Get-ToolOutput "omo" @("--version")
if ($currentOmo -notmatch [System.Text.RegularExpressions.Regex]::Escape($LazyCodexVersion)) {
    Invoke-Native "npx" @("--yes", $LazyCodexNpmPackage, "install", "--no-tui", "--codex-autonomous")
} else {
    Write-Host "omo $LazyCodexVersion already installed."
}

if (Get-Command codex -ErrorAction SilentlyContinue) {
    $marketplaces = codex plugin marketplace list 2>$null | Out-String
    if ($marketplaces -notmatch "ponytail") {
        Invoke-Native "codex" @("plugin", "marketplace", "add", "--ref", $PonytailRef, "https://github.com/DietrichGebert/ponytail.git")
    }
    $plugins = codex plugin list 2>$null | Out-String
    if ($plugins -notmatch "ponytail@ponytail") {
        Invoke-Native "codex" @("plugin", "add", "ponytail@ponytail")
    }
    if ($plugins -notmatch "trihead-optimizer@personal") {
        Invoke-Native "codex" @("plugin", "add", "trihead-optimizer@personal")
    }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git is required before installing the patched trihead checkout."
}

if (-not (Test-Path $TriheadRepo)) {
    Invoke-Native "git" @("clone", "https://github.com/hojunjeon/trihead.git", $TriheadRepo)
} else {
    Invoke-Native "git" @("-C", $TriheadRepo, "fetch", "--all", "--prune")
}
Invoke-Native "git" @("-C", $TriheadRepo, "reset", "--hard", $TriheadRef)

$patch = Join-Path $ProfileRoot "patches\trihead-windows-aggressive.patch"
$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
git -C $TriheadRepo apply --reverse --check $patch 2>$null
$patchAlreadyApplied = $LASTEXITCODE -eq 0
$ErrorActionPreference = $previousErrorActionPreference
if (-not $patchAlreadyApplied) {
    Invoke-Native "git" @("-C", $TriheadRepo, "apply", "--check", $patch)
    Invoke-Native "git" @("-C", $TriheadRepo, "apply", $patch)
}

Invoke-Native "python" @("-m", "pip", "install", "--upgrade", "pip")
Invoke-Native "python" @("-m", "pip", "install", "--force-reinstall", $TriheadRepo)

Set-TomlValue $CodexConfig $null "model" '"gpt-5.5"'
Set-TomlValue $CodexConfig $null "model_reasoning_effort" '"xhigh"'
Set-TomlValue $CodexConfig $null "approval_policy" '"never"'
Set-TomlValue $CodexConfig $null "sandbox_mode" '"danger-full-access"'
Set-TomlValue $CodexConfig $null "network_access" '"enabled"'
Set-TomlValue $CodexConfig $null "service_tier" '"default"'
Set-TomlValue $CodexConfig "features" "goals" "true"
Set-TomlValue $CodexConfig "features" "unified_exec" "true"
Set-TomlValue $CodexConfig "features" "child_agents_md" "true"
Set-TomlValue $CodexConfig "features" "multi_agent" "true"
Set-TomlValue $CodexConfig "features" "plugin_hooks" "true"
Set-TomlValue $CodexConfig "features" "plugins" "true"
Set-TomlValue $CodexConfig "features" "memories" "true"
Set-TomlValue $CodexConfig "desktop" "integratedTerminalShell" '"gitBash"'
Set-TomlValue $CodexConfig "desktop" "conversationDetailMode" '"STEPS_COMMANDS"'
Set-TomlValue $CodexConfig "desktop" "show-context-window-usage" "true"
Set-TomlValue $CodexConfig "features.multi_agent_v2" "enabled" "false"
Set-TomlValue $CodexConfig "features.multi_agent_v2" "max_concurrent_threads_per_session" "1000"
Set-TomlValue $CodexConfig 'plugins."omo@sisyphuslabs"' "enabled" "true"
Set-TomlValue $CodexConfig 'plugins."omo@sisyphuslabs".mcp_servers.context7' "enabled" "true"
Set-TomlValue $CodexConfig 'plugins."omo@sisyphuslabs".mcp_servers.codegraph' "enabled" "true"
Set-TomlValue $CodexConfig 'plugins."omo@sisyphuslabs".mcp_servers.git_bash' "enabled" "true"
Set-TomlValue $CodexConfig 'plugins."trihead-optimizer@personal"' "enabled" "true"
Set-TomlValue $CodexConfig 'plugins."ponytail@ponytail"' "enabled" "true"
Set-TomlValue $CodexConfig "agents" "max_threads" "1000"

Write-Host "profile1 applied."
Write-Host "TRIHEAD_HOME=$TriheadHome"
Write-Host "Codex config updated at $CodexConfig."
Write-Host "Run profile1\verify-profile1.ps1 next."
