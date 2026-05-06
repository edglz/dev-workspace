# Idempotent installer for the dev-workspace toolbox.
# Run from any PowerShell 7+ session. Re-running is safe.
#
#   irm <raw-url>/install.ps1 | iex
#   # or
#   .\install.ps1
#
# Supported flags:
#   -SkipScoop      Skip Scoop bootstrap and package installs
#   -SkipPip        Skip Python pip installs (httpie, posting, pgcli)
#   -SkipNpm        Skip global npm installs (wrangler, @expo/cli)
#   -SkipProfile    Skip writing the PowerShell profile
#   -SkipSettings   Skip writing Claude settings.json

[CmdletBinding()]
param(
    [switch]$SkipScoop,
    [switch]$SkipPip,
    [switch]$SkipNpm,
    [switch]$SkipProfile,
    [switch]$SkipSettings
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Step  { param([string]$M) Write-Host "==> $M" -ForegroundColor Cyan }
function Write-Skip  { param([string]$M) Write-Host "    skip: $M" -ForegroundColor DarkGray }
function Write-Done  { param([string]$M) Write-Host "    ok:   $M" -ForegroundColor Green }

# 1. Scoop + buckets + packages
if (-not $SkipScoop) {
    Write-Step 'Scoop bootstrap'
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }
    Write-Done 'scoop available'

    $buckets = scoop bucket list 2>&1 | Out-String
    foreach ($b in 'extras','java') {
        if ($buckets -notmatch "(?m)^\s*$b\s") {
            scoop bucket add $b | Out-Null
            Write-Done "bucket $b added"
        } else {
            Write-Skip "bucket $b"
        }
    }

    $scoopPkgs = @(
        # Modern CLI replacements
        'eza','bat','fd','ripgrep','zoxide','sd','dust','duf','delta','difftastic',
        'xh','dog','btop','procs','hyperfine','tealdeer','jaq','dasel','yq',
        'fzf','lazygit','just','watchexec','gping','trippy','tokei',
        # Runtimes
        'nodejs','bun','pnpm','deno','python','go','temurin21-jdk','gradle','maven','mise',
        # APIs / DBs / Cloud
        'gh','atac','grpcurl','mongosh','supabase','ngrok','cloudflared',
        # Kubernetes
        'kubectl','k9s','kubectx','kubens','helm','stern','dive','minikube','kind',
        # IaC / Mobile / Misc
        'terraform','pulumi','flutter','glow','rclone'
    )

    Write-Step "Scoop packages ($($scoopPkgs.Count))"
    $installed = scoop list 2>&1 | Out-String
    $toInstall = $scoopPkgs | Where-Object { $installed -notmatch "(?m)^\s*$_\s" }
    if ($toInstall) {
        scoop install @toInstall
    } else {
        Write-Skip 'all packages already installed'
    }

    foreach ($needsReset in 'temurin21-jdk','maven','flutter') {
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            scoop reset $needsReset 2>&1 | Out-Null
        }
    }
    Write-Done 'scoop packages'
}

# 2. pip user installs
if (-not $SkipPip) {
    Write-Step 'pip user installs'
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Skip 'python not on PATH (run scoop step first)'
    } else {
        python -m pip install --user --upgrade httpie posting pgcli | Out-Null
        $pyScripts = python -c "import site, os; print(os.path.join(site.USER_BASE, 'Scripts'))" 2>&1
        $pyScripts = ($pyScripts -split "`n")[0].Trim()
        $userPath = [Environment]::GetEnvironmentVariable('Path','User')
        if ($userPath -notlike "*$pyScripts*") {
            [Environment]::SetEnvironmentVariable('Path', "$userPath;$pyScripts", 'User')
            Write-Done "PATH += $pyScripts"
        }
        Write-Done 'httpie, posting, pgcli'
    }
}

# 3. npm globals
if (-not $SkipNpm) {
    Write-Step 'npm globals'
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Skip 'npm not on PATH (run scoop step first)'
    } else {
        npm install -g wrangler @expo/cli 2>&1 | Out-Null
        Write-Done 'wrangler, @expo/cli'
    }
}

# 4. Profile
if (-not $SkipProfile) {
    Write-Step 'PowerShell profile'
    $allHosts = "$env:USERPROFILE\Documents\PowerShell\profile.ps1"
    $allHostsDir = Split-Path -Parent $allHosts
    if (-not (Test-Path $allHostsDir)) { New-Item -ItemType Directory -Path $allHostsDir -Force | Out-Null }
    Copy-Item -Path "$root\profile.ps1" -Destination $allHosts -Force
    Write-Done $allHosts

    $winPsDir = "$env:USERPROFILE\Documents\WindowsPowerShell"
    if (-not (Test-Path $winPsDir)) { New-Item -ItemType Directory -Path $winPsDir -Force | Out-Null }
    Copy-Item -Path "$root\windowsPowerShell-stub.ps1" -Destination "$winPsDir\Microsoft.PowerShell_profile.ps1" -Force
    Write-Done "$winPsDir\Microsoft.PowerShell_profile.ps1"
}

# 5. Claude settings (merge, do not overwrite)
if (-not $SkipSettings) {
    Write-Step 'Claude settings.json'
    $claudeDir = "$env:USERPROFILE\.claude"
    if (-not (Test-Path $claudeDir)) { New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null }
    $target = "$claudeDir\settings.json"
    $template = Get-Content "$root\settings.template.json" -Raw | ConvertFrom-Json

    if (Test-Path $target) {
        Copy-Item -Path $target -Destination "$target.bak" -Force
        Write-Done "backup -> $target.bak"
        $current = Get-Content $target -Raw | ConvertFrom-Json
        $current | Add-Member -NotePropertyName attribution -NotePropertyValue $template.attribution -Force
        $current | Add-Member -NotePropertyName permissions -NotePropertyValue $template.permissions -Force
        if ($template.hooks) {
            $current | Add-Member -NotePropertyName hooks -NotePropertyValue $template.hooks -Force
        }
        $current | ConvertTo-Json -Depth 10 | Set-Content -Path $target -Encoding UTF8
        Write-Done "merged into $target"
    } else {
        Copy-Item -Path "$root\settings.template.json" -Destination $target -Force
        Write-Done "created $target"
    }
}

Write-Host ''
Write-Host 'Done. Open a new PowerShell session and run: ws' -ForegroundColor Green
