# Idempotent installer for the dev-workspace toolbox. Re-running is safe.
#
#   git clone https://github.com/edglz/dev-workspace.git
#   cd dev-workspace
#   .\install.ps1
#
# Flags:  -SkipScoop  -SkipPip  -SkipNpm  -SkipProfile  -SkipSettings

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

function Write-Step { param([string]$M) Write-Host "==> $M" -ForegroundColor Cyan }
function Write-Skip { param([string]$M) Write-Host "    skip: $M" -ForegroundColor DarkGray }
function Write-Done { param([string]$M) Write-Host "    ok:   $M" -ForegroundColor Green }

# Refresh the current session's PATH from the user/machine registry values.
# Required after scoop/pip/npm modify user PATH so subsequent steps can find
# the freshly installed binaries without opening a new shell.
function Update-SessionPath {
    $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
                [Environment]::GetEnvironmentVariable('Path','User')
}

function Add-UserPath {
    param([Parameter(Mandatory)][string]$Dir)
    $cur = [Environment]::GetEnvironmentVariable('Path','User')
    if (($cur -split ';') -contains $Dir) { return }
    [Environment]::SetEnvironmentVariable('Path', "$cur;$Dir", 'User')
    Update-SessionPath
}

function Test-ScoopBucket {
    param([string]$Name)
    (scoop bucket list 2>&1 | Out-String) -match "(?m)^\s*$Name\s"
}

function Test-ScoopPackage {
    param([string]$Name)
    [bool](scoop list $Name 6>$null | Where-Object Name -eq $Name)
}

# 1. Scoop bootstrap, buckets, packages
if (-not $SkipScoop) {
    Write-Step 'Scoop'
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        Update-SessionPath
    }
    Write-Done 'scoop available'

    foreach ($b in 'extras','java') {
        if (Test-ScoopBucket $b) { Write-Skip "bucket $b" } else {
            scoop bucket add $b | Out-Null
            Write-Done "bucket $b added"
        }
    }

    $packages = @(
        'eza','bat','fd','ripgrep','zoxide','sd','dust','duf','delta','difftastic',
        'xh','dog','btop','procs','hyperfine','tealdeer','jaq','dasel','yq',
        'fzf','lazygit','just','watchexec','gping','trippy','tokei',
        'nodejs','bun','pnpm','deno','python','go','temurin21-jdk','gradle','maven','mise',
        'gh','atac','grpcurl','mongosh','supabase','ngrok','cloudflared',
        'kubectl','k9s','kubectx','kubens','helm','stern','dive','minikube','kind',
        'terraform','pulumi','flutter','glow','rclone','oh-my-posh'
    )

    Write-Step "Scoop packages ($($packages.Count))"
    $missing = $packages | Where-Object { -not (Test-ScoopPackage $_) }
    if ($missing) { scoop install @missing } else { Write-Skip 'all already installed' }

    foreach ($n in 'temurin21-jdk','maven','flutter') {
        if (Test-ScoopPackage $n) { scoop reset $n | Out-Null }
    }
    Update-SessionPath
    Write-Done 'scoop done'
}

# 2. pip user installs
if (-not $SkipPip) {
    Write-Step 'pip user installs'
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Skip 'python not on PATH'
    } else {
        python -m pip install --user --upgrade httpie posting pgcli | Out-Null
        $userBase = (python -c "import site; print(site.USER_BASE)" 2>&1) -split "`n" | Select-Object -First 1
        Add-UserPath (Join-Path $userBase.Trim() 'Scripts')
        Write-Done 'httpie, posting, pgcli'
    }
}

# 3. npm globals
if (-not $SkipNpm) {
    Write-Step 'npm globals'
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Skip 'npm not on PATH'
    } else {
        npm install -g wrangler @expo/cli 2>&1 | Out-Null
        Write-Done 'wrangler, @expo/cli'
    }
}

# 4. Profile
if (-not $SkipProfile) {
    Write-Step 'PowerShell profile'
    $allHosts = "$env:USERPROFILE\Documents\PowerShell\profile.ps1"
    New-Item -ItemType Directory -Path (Split-Path $allHosts) -Force | Out-Null
    Copy-Item "$root\profile.ps1" $allHosts -Force
    Write-Done $allHosts

    $ompTheme = Join-Path (Split-Path $allHosts) 'workspace.omp.json'
    Copy-Item "$root\workspace.omp.json" $ompTheme -Force
    Write-Done $ompTheme

    $winPs = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    New-Item -ItemType Directory -Path (Split-Path $winPs) -Force | Out-Null
    Copy-Item "$root\windowsPowerShell-stub.ps1" $winPs -Force
    Write-Done $winPs
}

# 5. Claude settings - merge into existing or create fresh
if (-not $SkipSettings) {
    Write-Step 'Claude settings.json'
    $claudeDir = "$env:USERPROFILE\.claude"
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
    $target = "$claudeDir\settings.json"
    $template = Get-Content "$root\settings.template.json" -Raw | ConvertFrom-Json

    if (Test-Path $target) {
        Copy-Item $target "$target.bak" -Force
        Write-Done "backup -> $target.bak"
        $current = Get-Content $target -Raw | ConvertFrom-Json
        $current.attribution = $template.attribution
        $current.permissions = $template.permissions
        if ($template.hooks) { $current.hooks = $template.hooks }
        $current | ConvertTo-Json -Depth 10 | Set-Content $target -Encoding UTF8
        Write-Done "merged into $target"
    } else {
        Copy-Item "$root\settings.template.json" $target -Force
        Write-Done "created $target"
    }
}

Write-Host ''
Write-Host 'Done. Open a new PowerShell session and run: ws' -ForegroundColor Green
