# PowerShell profile - modern CLI workspace
# Entry points: ws | cheat | rules | paths | aliases-modern

$aliasMap = @{
    ls = 'eza'; ll = 'eza'; cat = 'bat'; grep = 'rg'; find = 'fd'
    top = 'btop'; ps2 = 'procs'; dig = 'dog'; diff = 'difft'
    curl = 'xh'; man = 'tldr'
}
foreach ($kv in $aliasMap.GetEnumerator()) {
    Set-Alias -Force -Name $kv.Key -Value $kv.Value
}

function l   { eza --icons --git $args }
function la  { eza --icons --git -la $args }
function lt  { eza --icons --git --tree --level=2 $args }

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

if (-not (Get-Module PSFzf)) {
    Import-Module PSFzf -ErrorAction SilentlyContinue
    if (Get-Module PSFzf) {
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    }
}

# Oh My Posh - prompt themed to match the workspace palette.
# Theme lives next to this profile so install.ps1 ships them together.
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $ompTheme = Join-Path $PSScriptRoot 'workspace.omp.json'
    if (Test-Path $ompTheme) {
        oh-my-posh init pwsh --config $ompTheme | Invoke-Expression
    }
}

# Tool catalog. Probe overrides the binary used to test installation when
# the user-facing name is not the executable on PATH (npx for expo, etc.).
$global:WorkspaceTools = @(
    [PSCustomObject]@{ Name='eza';        Category='Modern';   Replaces='ls';         Description='Listing with colors, icons, Git status';                Example='eza --icons --git -la' }
    [PSCustomObject]@{ Name='bat';        Category='Modern';   Replaces='cat';        Description='Cat with syntax highlighting and paging';               Example='bat README.md' }
    [PSCustomObject]@{ Name='rg';         Category='Modern';   Replaces='grep';       Description='Ripgrep: 10-100x faster, respects .gitignore';          Example='rg "TODO" src/' }
    [PSCustomObject]@{ Name='fd';         Category='Modern';   Replaces='find';       Description='Modern find: fast, regex-friendly';                     Example='fd ".ts$"' }
    [PSCustomObject]@{ Name='sd';         Category='Modern';   Replaces='sed';        Description='Intuitive find and replace (JS/Python regex)';          Example='sd "old" "new" file.txt' }
    [PSCustomObject]@{ Name='delta';      Category='Modern';   Replaces='diff';       Description='Git diff with syntax and side-by-side';                 Example='delta a.txt b.txt' }
    [PSCustomObject]@{ Name='difft';      Category='Modern';   Replaces='diff';       Description='Difftastic: structural diff aware of language';         Example='difft a.js b.js' }
    [PSCustomObject]@{ Name='zoxide';     Category='Modern';   Replaces='cd';         Description='Jump to directories by frequency (z proj)';             Example='z myrepo' }
    [PSCustomObject]@{ Name='dust';       Category='Modern';   Replaces='du';         Description='Visual disk usage with bars and tree';                  Example='dust -d 2' }
    [PSCustomObject]@{ Name='duf';        Category='Modern';   Replaces='df';         Description='Pretty df with per-device table';                       Example='duf' }
    [PSCustomObject]@{ Name='xh';         Category='Modern';   Replaces='curl';       Description='HTTPie-like client in Rust (~30% faster)';              Example='xh GET api.github.com/users/octocat' }
    [PSCustomObject]@{ Name='dog';        Category='Modern';   Replaces='dig';        Description='DNS client with DoH/DoT, JSON, colors';                 Example='dog example.com MX' }
    [PSCustomObject]@{ Name='btop';       Category='Modern';   Replaces='top';        Description='TUI system monitor with GPU and mouse';                 Example='btop' }
    [PSCustomObject]@{ Name='procs';      Category='Modern';   Replaces='ps';         Description='Colored process table with search';                     Example='procs node' }
    [PSCustomObject]@{ Name='hyperfine';  Category='Modern';   Replaces='time';       Description='Statistical benchmark (warmup + runs)';                 Example='hyperfine "ls" "eza"' }
    [PSCustomObject]@{ Name='tldr';       Category='Modern';   Replaces='man';        Description='tldr-pages: practical examples instantly';              Example='tldr tar' }
    [PSCustomObject]@{ Name='jaq';        Category='Modern';   Replaces='jq';         Description='jq in Rust, faster and stricter';                       Example='jaq ".items[]" data.json' }
    [PSCustomObject]@{ Name='yq';         Category='Modern';   Replaces='jq(yaml)';   Description='YAML processor with jq-like syntax';                    Example='yq ".version" pkg.yml' }
    [PSCustomObject]@{ Name='dasel';      Category='Modern';   Replaces='jq';         Description='Multi-format query: JSON/YAML/TOML/XML/CSV';            Example='dasel -f config.toml ".server.port"' }
    [PSCustomObject]@{ Name='fzf';        Category='Modern';   Replaces='-';          Description='Universal fuzzy finder';                                Example='fzf' }
    [PSCustomObject]@{ Name='lazygit';    Category='Modern';   Replaces='git UI';     Description='Full TUI for Git: stage, commit, rebase, merge';        Example='lazygit' }
    [PSCustomObject]@{ Name='just';       Category='Modern';   Replaces='make';       Description='Modern task runner with justfile';                      Example='just build' }
    [PSCustomObject]@{ Name='watchexec';  Category='Modern';   Replaces='watch';      Description='Re-run command when files change';                      Example='watchexec -e ts "npm test"' }
    [PSCustomObject]@{ Name='gping';      Category='Modern';   Replaces='ping';       Description='Ping with real-time graph';                             Example='gping google.com' }
    [PSCustomObject]@{ Name='trip';       Category='Modern';   Replaces='traceroute'; Description='Trippy: traceroute/mtr TUI multi-protocol';             Example='trip google.com' }
    [PSCustomObject]@{ Name='tokei';      Category='Modern';   Replaces='wc -l';      Description='Count lines of code grouped by language';               Example='tokei .' }
    [PSCustomObject]@{ Name='node';       Category='Runtime';  Replaces='-';          Description='Node.js runtime (includes npm)';                        Example='node app.js' }
    [PSCustomObject]@{ Name='bun';        Category='Runtime';  Replaces='node/npm';   Description='Runtime + bundler + installer 9-30x faster than npm';   Example='bun install' }
    [PSCustomObject]@{ Name='pnpm';       Category='Runtime';  Replaces='npm';        Description='Symlinked package manager (saves GB on monorepos)';     Example='pnpm install' }
    [PSCustomObject]@{ Name='deno';       Category='Runtime';  Replaces='node';       Description='TypeScript-first runtime, secure, native ESM';          Example='deno run main.ts' }
    [PSCustomObject]@{ Name='python';     Category='Runtime';  Replaces='-';          Description='Python 3 + pip';                                        Example='python -m venv .venv' }
    [PSCustomObject]@{ Name='go';         Category='Runtime';  Replaces='-';          Description='Go compiler';                                           Example='go build ./...' }
    [PSCustomObject]@{ Name='java';       Category='Runtime';  Replaces='-';          Description='OpenJDK 21 (Eclipse Temurin LTS)';                      Example='java -version' }
    [PSCustomObject]@{ Name='gradle';     Category='Runtime';  Replaces='maven';      Description='JVM build tool (Kotlin/Java)';                          Example='gradle build' }
    [PSCustomObject]@{ Name='mvn';        Category='Runtime';  Replaces='-';          Description='Maven: classic JVM build/dependency tool';              Example='mvn package' }
    [PSCustomObject]@{ Name='mise';       Category='Runtime';  Replaces='nvm/pyenv';  Description='Multi-version manager (Node/Python/Go/Ruby)';           Example='mise use node@20' }
    [PSCustomObject]@{ Name='gh';         Category='VCS';      Replaces='-';          Description='GitHub CLI: PRs, issues, releases, gh copilot';         Example='gh pr create' }
    [PSCustomObject]@{ Name='ngrok';      Category='Cloud';    Replaces='-';          Description='HTTP/TCP tunnel to expose localhost';                   Example='ngrok http 3000' }
    [PSCustomObject]@{ Name='cloudflared';Category='Cloud';    Replaces='ngrok';      Description='Cloudflare tunnel (free, no limits)';                   Example='cloudflared tunnel --url http://localhost:3000' }
    [PSCustomObject]@{ Name='rclone';     Category='Cloud';    Replaces='rsync';      Description='Sync to S3/GCS/R2/Drive/Dropbox + 70 services';         Example='rclone sync ./local s3:bucket' }
    [PSCustomObject]@{ Name='wrangler';   Category='Cloud';    Replaces='-';          Description='Cloudflare Workers/Pages/KV/R2/D1 CLI';                 Example='wrangler deploy' }
    [PSCustomObject]@{ Name='atac';       Category='API';      Replaces='postman';    Description='TUI API client in Rust, imports Postman, offline';      Example='atac' }
    [PSCustomObject]@{ Name='posting';    Category='API';      Replaces='postman';    Description='Modern TUI API client (Textual), YAML requests';        Example='posting' }
    [PSCustomObject]@{ Name='http';       Category='API';      Replaces='curl';       Description='HTTPie classic (Python) - complements xh';              Example='http GET httpbin.org/get' }
    [PSCustomObject]@{ Name='grpcurl';    Category='API';      Replaces='curl(grpc)'; Description='Curl for gRPC services with reflection';                Example='grpcurl -plaintext localhost:50051 list' }
    [PSCustomObject]@{ Name='mongosh';    Category='DB';       Replaces='-';          Description='Official Mongo shell with autocomplete';                Example='mongosh "mongodb://localhost"' }
    [PSCustomObject]@{ Name='pgcli';      Category='DB';       Replaces='psql';       Description='Postgres REPL with autocompletion';                     Example='pgcli postgres://user@host/db' }
    [PSCustomObject]@{ Name='supabase';   Category='DB';       Replaces='-';          Description='Local Postgres + Auth + Storage + Edge Functions';      Example='supabase start' }
    [PSCustomObject]@{ Name='kubectl';    Category='K8s';      Replaces='-';          Description='Official Kubernetes client';                            Example='kubectl get pods -A' }
    [PSCustomObject]@{ Name='k9s';        Category='K8s';      Replaces='kubectl UI'; Description='K8s TUI dashboard: pods, logs, exec, port-forward';     Example='k9s' }
    [PSCustomObject]@{ Name='kubectx';    Category='K8s';      Replaces='-';          Description='Fast switch between K8s clusters';                      Example='kubectx prod' }
    [PSCustomObject]@{ Name='kubens';     Category='K8s';      Replaces='-';          Description='Fast switch between K8s namespaces';                    Example='kubens kube-system' }
    [PSCustomObject]@{ Name='helm';       Category='K8s';      Replaces='-';          Description='Kubernetes package manager (charts)';                   Example='helm install nginx bitnami/nginx' }
    [PSCustomObject]@{ Name='stern';      Category='K8s';      Replaces='kubectl logs'; Description='Tail multi-pod logs with regex and colors';           Example='stern app-' }
    [PSCustomObject]@{ Name='dive';       Category='K8s';      Replaces='-';          Description='Inspect Docker image layers';                           Example='dive my-image:latest' }
    [PSCustomObject]@{ Name='minikube';   Category='K8s';      Replaces='-';          Description='Local K8s cluster in VM';                               Example='minikube start' }
    [PSCustomObject]@{ Name='kind';       Category='K8s';      Replaces='minikube';   Description='Local K8s in Docker containers (lighter)';              Example='kind create cluster' }
    [PSCustomObject]@{ Name='terraform';  Category='IaC';      Replaces='-';          Description='IaC standard: AWS/GCP/Azure/Cloudflare';                Example='terraform apply' }
    [PSCustomObject]@{ Name='pulumi';     Category='IaC';      Replaces='terraform';  Description='IaC with TS/Python/Go instead of HCL';                  Example='pulumi up' }
    [PSCustomObject]@{ Name='flutter';    Category='Mobile';   Replaces='-';          Description='Flutter SDK (includes dart) for cross-platform';        Example='flutter run' }
    [PSCustomObject]@{ Name='expo';       Category='Mobile';   Replaces='-';          Description='Expo CLI for React Native (cloud build via EAS)';       Example='npx expo start';     Probe='npx' }
    [PSCustomObject]@{ Name='glow';       Category='Misc';     Replaces='cat';        Description='Render Markdown with color in terminal';                Example='glow README.md' }
    [PSCustomObject]@{ Name='scoop';      Category='Misc';     Replaces='-';          Description='Windows package manager (admin-free)';                  Example='scoop install <tool>' }
    [PSCustomObject]@{ Name='oh-my-posh'; Category='Misc';     Replaces='-';          Description='Cross-shell prompt engine (theme: workspace.omp.json)'; Example='oh-my-posh print primary' }
    [PSCustomObject]@{ Name='rtk';        Category='Misc';     Replaces='-';          Description='Token-optimizing CLI proxy for Claude Code';            Example='rtk gain' }
)

function Get-RuleCount {
    param($Container, [string]$Key)
    # Measure-Object yields 0 for $null; @($null).Count yields 1, which we don't want.
    ($Container.$Key | Measure-Object).Count
}

function Read-ClaudeSettings {
    $path = "$env:USERPROFILE\.claude\settings.json"
    if (-not (Test-Path $path)) { return $null }
    Get-Content $path -Raw | ConvertFrom-Json
}

function cheat {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$Tool,
        [string]$Keyword,
        [switch]$Object
    )

    $set = $global:WorkspaceTools

    if ($Tool) {
        $hit = $set | Where-Object Name -ieq $Tool | Select-Object -First 1
        if (-not $hit) { Write-Warning "No tool named '$Tool'. Run cheat for the catalog."; return }
        if ($Object) { return $hit }
        Write-Host ''
        Write-Host "  $($hit.Name)" -NoNewline -ForegroundColor Cyan
        Write-Host "  [$($hit.Category)]" -NoNewline -ForegroundColor Magenta
        Write-Host "  replaces $($hit.Replaces)" -ForegroundColor DarkGray
        Write-Host "  $($hit.Description)" -ForegroundColor Gray
        Write-Host "  $ $($hit.Example)" -ForegroundColor Green
        Write-Host ''
        return
    }

    if ($Keyword) {
        $set = $set | Where-Object {
            $_.Name -match $Keyword -or $_.Replaces -match $Keyword -or
            $_.Description -match $Keyword -or $_.Category -match $Keyword
        }
        if (-not $set) { Write-Warning "No matches for '$Keyword'"; return }
    }

    if ($Object) { return $set }
    $set | Sort-Object Category, Name |
        Format-Table -GroupBy Category -Property Name, Replaces, Description -AutoSize -Wrap
}

function cheat-search {
    [CmdletBinding()] param([Parameter(Mandatory, Position=0)][string]$Keyword)
    cheat -Keyword $Keyword
}

function rules {
    [CmdletBinding()] param([switch]$Object)

    $s = Read-ClaudeSettings
    if (-not $s) { Write-Warning "settings.json not found at $env:USERPROFILE\.claude\settings.json"; return }

    $parse = {
        param($rule, $effect)
        if ($rule -match '^(?<shell>\w+)\((?<cmd>[^)]+?)(?::|\))') {
            [PSCustomObject]@{ Shell=$Matches.shell; Command=$Matches.cmd.Trim(); Effect=$effect; Rule=$rule }
        } else {
            [PSCustomObject]@{ Shell='-'; Command=$rule; Effect=$effect; Rule=$rule }
        }
    }

    $allow = @($s.permissions.allow) | ForEach-Object { & $parse $_ 'allow' }
    $ask   = @($s.permissions.ask)   | ForEach-Object { & $parse $_ 'ask' }
    $deny  = @($s.permissions.deny)  | ForEach-Object { & $parse $_ 'deny' }

    if ($Object) { return @($allow + $ask + $deny) }

    Write-Host ''
    Write-Host '  CLAUDE PERMISSION RULES' -ForegroundColor Cyan
    Write-Host "  $env:USERPROFILE\.claude\settings.json" -ForegroundColor DarkGray
    Write-Host ''
    @(
        [PSCustomObject]@{ Effect='allow'; Count=($allow | Measure-Object).Count; UniqueCmds=($allow.Command | Sort-Object -Unique | Measure-Object).Count; Description='Auto-approved (no prompt)' }
        [PSCustomObject]@{ Effect='ask';   Count=($ask   | Measure-Object).Count; UniqueCmds=($ask.Command   | Sort-Object -Unique | Measure-Object).Count; Description='Always confirm before running' }
        [PSCustomObject]@{ Effect='deny';  Count=($deny  | Measure-Object).Count; UniqueCmds=($deny.Command  | Sort-Object -Unique | Measure-Object).Count; Description='Blocked entirely' }
    ) | Format-Table -AutoSize | Out-Host

    function Show-RuleGroup {
        param($Items, [string]$Title, [System.ConsoleColor]$Color)
        if (-not $Items) { return }
        Write-Host "  $Title" -ForegroundColor $Color
        $Items | Group-Object Command | Sort-Object Name |
            ForEach-Object { [PSCustomObject]@{ Command=$_.Name; Shells=$_.Count } } |
            Format-Table -AutoSize | Out-Host
    }

    Show-RuleGroup $allow 'ALLOW - top-level commands'    Green
    Show-RuleGroup $ask   'ASK - destructive operations'  Yellow
    Show-RuleGroup $deny  'DENY - fully blocked'          Red
}

function paths {
    [CmdletBinding()] param([switch]$Object)
    $rows = @(
        @{ Key='Profile (all hosts, PS7+)';   Path=$PROFILE.CurrentUserAllHosts }
        @{ Key='Profile (current host)';      Path=$PROFILE.CurrentUserCurrentHost }
        @{ Key='Oh My Posh theme';            Path="$env:USERPROFILE\Documents\PowerShell\workspace.omp.json" }
        @{ Key='WinPS 5.1 stub';              Path="$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" }
        @{ Key='Claude global settings';      Path="$env:USERPROFILE\.claude\settings.json" }
        @{ Key='Claude memory dir';           Path="$env:USERPROFILE\.claude\projects\C--Users-PC\memory" }
        @{ Key='Scoop apps';                  Path="$env:USERPROFILE\scoop\apps" }
        @{ Key='Scoop shims';                 Path="$env:USERPROFILE\scoop\shims" }
    ) | ForEach-Object {
        [PSCustomObject]@{ Exists=(Test-Path $_.Path); Key=$_.Key; Path=$_.Path }
    }

    if ($Object) { return $rows }
    $rows | Format-Table -AutoSize
}

function aliases-modern {
    [CmdletBinding()] param([switch]$Object)
    $rows = 'ls','ll','cat','grep','find','top','ps2','dig','diff','curl','man','l','la','lt','z' |
        ForEach-Object {
            $cmd = Get-Command $_ -ErrorAction SilentlyContinue
            if (-not $cmd) { return }
            [PSCustomObject]@{
                Alias  = $_
                Kind   = $cmd.CommandType
                Target = if ($cmd.CommandType -eq 'Alias') { $cmd.Definition } else { '<function>' }
            }
        }
    if ($Object) { return $rows }
    $rows | Format-Table -AutoSize
}

function workspace {
    [CmdletBinding()] param()

    # Pre-fetch every available command in one pass instead of 60+ Get-Command lookups.
    $resolved = @{}
    Get-Command -CommandType Application,Function,Cmdlet,Alias -ErrorAction SilentlyContinue |
        ForEach-Object { $resolved[$_.Name] = $true }

    $green = $PSStyle.Foreground.Green
    $gray  = $PSStyle.Foreground.BrightBlack
    $reset = $PSStyle.Reset

    Write-Host ''
    Write-Host '  WORKSPACE' -ForegroundColor Cyan
    Write-Host '  =========' -ForegroundColor DarkGray
    Write-Host ''

    $tools = $global:WorkspaceTools | ForEach-Object {
        $probe = if ($_.Probe) { $_.Probe } else { $_.Name }
        [PSCustomObject]@{
            Name = $_.Name; Category = $_.Category; Installed = [bool]$resolved[$probe]
        }
    }

    Write-Host ('  Tools ({0} total)' -f $tools.Count) -ForegroundColor DarkGray
    foreach ($g in $tools | Group-Object Category | Sort-Object Name) {
        $installed = ($g.Group | Where-Object Installed).Count
        $names = $g.Group | ForEach-Object {
            if ($_.Installed) { "$green$($_.Name)$reset" } else { "$gray$($_.Name)$reset" }
        }
        Write-Host ('    {0,-9} ' -f $g.Name) -NoNewline -ForegroundColor Yellow
        Write-Host ('({0}/{1}) ' -f $installed, $g.Count) -NoNewline -ForegroundColor DarkGray
        Write-Host ($names -join ' ')
    }

    Write-Host ''
    Write-Host '  Profile commands' -ForegroundColor Yellow
    @(
        [PSCustomObject]@{ Command='ws';              Action='Workspace overview (this view)' }
        [PSCustomObject]@{ Command='cheat';           Action='Tool catalog by category' }
        [PSCustomObject]@{ Command='cheat <tool>';    Action='Description and example for one tool' }
        [PSCustomObject]@{ Command='cheat -Keyword';  Action='Filter the catalog by keyword' }
        [PSCustomObject]@{ Command='rules';           Action='Claude Code permission rules summary' }
        [PSCustomObject]@{ Command='paths';           Action='Profile, settings, memory, scoop locations' }
        [PSCustomObject]@{ Command='aliases-modern';  Action='Active modern-CLI aliases' }
        [PSCustomObject]@{ Command='z <fragment>';    Action='Jump to dir by frequency (zoxide)' }
        [PSCustomObject]@{ Command='lazygit';         Action='Git TUI' }
        [PSCustomObject]@{ Command='k9s';             Action='Kubernetes TUI' }
    ) | Format-Table -AutoSize -HideTableHeaders | Out-Host

    Write-Host '  Active aliases' -ForegroundColor Yellow
    aliases-modern | Out-Host

    $s = Read-ClaudeSettings
    if ($s) {
        Write-Host '  Claude permissions' -ForegroundColor Yellow
        [PSCustomObject]@{
            Allow = Get-RuleCount $s.permissions 'allow'
            Ask   = Get-RuleCount $s.permissions 'ask'
            Deny  = Get-RuleCount $s.permissions 'deny'
            Hooks = Get-RuleCount $s.hooks       'PreToolUse'
        } | Format-Table -AutoSize | Out-Host
    }

    Write-Host '  Run ' -NoNewline -ForegroundColor DarkGray
    Write-Host 'cheat' -NoNewline -ForegroundColor Green
    Write-Host ' for tool details, ' -NoNewline -ForegroundColor DarkGray
    Write-Host 'rules' -NoNewline -ForegroundColor Green
    Write-Host ' for permission detail, ' -NoNewline -ForegroundColor DarkGray
    Write-Host 'paths' -NoNewline -ForegroundColor Green
    Write-Host ' for filesystem layout.' -ForegroundColor DarkGray
    Write-Host ''
}
Set-Alias -Force ws workspace

# Banner only on interactive shells. Set $env:WORKSPACE_QUIET to silence.
if ($Host.UI.RawUI -and -not $env:WORKSPACE_QUIET) {
    Write-Host "Workspace ready. Try $($PSStyle.Foreground.Cyan)ws$($PSStyle.Reset) (overview), $($PSStyle.Foreground.Cyan)cheat$($PSStyle.Reset) (tools), $($PSStyle.Foreground.Cyan)rules$($PSStyle.Reset) (perms)." -ForegroundColor DarkGray
}
