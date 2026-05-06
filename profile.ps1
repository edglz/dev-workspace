# PowerShell profile - modern CLI workspace
# Entry points: ws | cheat | rules | paths | aliases-modern

#region Aliases
'ls','cat','cp','mv','rm' | ForEach-Object {
    Remove-Item "Alias:$_" -Force -ErrorAction SilentlyContinue
}

$aliasMap = @{
    ls = 'eza'; ll = 'eza'; cat = 'bat'; grep = 'rg'; find = 'fd'
    top = 'btop'; ps2 = 'procs'; dig = 'dog'; diff = 'difft'
    curl = 'xh'; man = 'tldr'
}
$aliasMap.GetEnumerator() | ForEach-Object {
    Set-Alias -Force -Name $_.Key -Value $_.Value
}

function l   { eza --icons --git $args }
function la  { eza --icons --git -la $args }
function lt  { eza --icons --git --tree --level=2 $args }
#endregion

#region Integrations
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}
#endregion

#region Tool catalog
$global:WorkspaceTools = @(
    # Modern CLI replacements
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

    # Runtimes
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

    # VCS / Cloud / Tunnels
    [PSCustomObject]@{ Name='gh';         Category='VCS';      Replaces='-';          Description='GitHub CLI: PRs, issues, releases, gh copilot';         Example='gh pr create' }
    [PSCustomObject]@{ Name='ngrok';      Category='Cloud';    Replaces='-';          Description='HTTP/TCP tunnel to expose localhost';                   Example='ngrok http 3000' }
    [PSCustomObject]@{ Name='cloudflared';Category='Cloud';    Replaces='ngrok';      Description='Cloudflare tunnel (free, no limits)';                   Example='cloudflared tunnel --url http://localhost:3000' }
    [PSCustomObject]@{ Name='rclone';     Category='Cloud';    Replaces='rsync';      Description='Sync to S3/GCS/R2/Drive/Dropbox + 70 services';         Example='rclone sync ./local s3:bucket' }
    [PSCustomObject]@{ Name='wrangler';   Category='Cloud';    Replaces='-';          Description='Cloudflare Workers/Pages/KV/R2/D1 CLI';                 Example='wrangler deploy' }

    # APIs
    [PSCustomObject]@{ Name='atac';       Category='API';      Replaces='postman';    Description='TUI API client in Rust, imports Postman, offline';      Example='atac' }
    [PSCustomObject]@{ Name='posting';    Category='API';      Replaces='postman';    Description='Modern TUI API client (Textual), YAML requests';        Example='posting' }
    [PSCustomObject]@{ Name='http';       Category='API';      Replaces='curl';       Description='HTTPie classic (Python) - complements xh';              Example='http GET httpbin.org/get' }
    [PSCustomObject]@{ Name='grpcurl';    Category='API';      Replaces='curl(grpc)'; Description='Curl for gRPC services with reflection';                Example='grpcurl -plaintext localhost:50051 list' }

    # Databases
    [PSCustomObject]@{ Name='mongosh';    Category='DB';       Replaces='-';          Description='Official Mongo shell with autocomplete';                Example='mongosh "mongodb://localhost"' }
    [PSCustomObject]@{ Name='pgcli';      Category='DB';       Replaces='psql';       Description='Postgres REPL with autocompletion';                     Example='pgcli postgres://user@host/db' }
    [PSCustomObject]@{ Name='supabase';   Category='DB';       Replaces='-';          Description='Local Postgres + Auth + Storage + Edge Functions';      Example='supabase start' }

    # Kubernetes
    [PSCustomObject]@{ Name='kubectl';    Category='K8s';      Replaces='-';          Description='Official Kubernetes client';                            Example='kubectl get pods -A' }
    [PSCustomObject]@{ Name='k9s';        Category='K8s';      Replaces='kubectl UI'; Description='K8s TUI dashboard: pods, logs, exec, port-forward';     Example='k9s' }
    [PSCustomObject]@{ Name='kubectx';    Category='K8s';      Replaces='-';          Description='Fast switch between K8s clusters';                      Example='kubectx prod' }
    [PSCustomObject]@{ Name='kubens';     Category='K8s';      Replaces='-';          Description='Fast switch between K8s namespaces';                    Example='kubens kube-system' }
    [PSCustomObject]@{ Name='helm';       Category='K8s';      Replaces='-';          Description='Kubernetes package manager (charts)';                   Example='helm install nginx bitnami/nginx' }
    [PSCustomObject]@{ Name='stern';      Category='K8s';      Replaces='kubectl logs'; Description='Tail multi-pod logs with regex and colors';           Example='stern app-' }
    [PSCustomObject]@{ Name='dive';       Category='K8s';      Replaces='-';          Description='Inspect Docker image layers';                           Example='dive my-image:latest' }
    [PSCustomObject]@{ Name='minikube';   Category='K8s';      Replaces='-';          Description='Local K8s cluster in VM';                               Example='minikube start' }
    [PSCustomObject]@{ Name='kind';       Category='K8s';      Replaces='minikube';   Description='Local K8s in Docker containers (lighter)';              Example='kind create cluster' }

    # IaC
    [PSCustomObject]@{ Name='terraform';  Category='IaC';      Replaces='-';          Description='IaC standard: AWS/GCP/Azure/Cloudflare';                Example='terraform apply' }
    [PSCustomObject]@{ Name='pulumi';     Category='IaC';      Replaces='terraform';  Description='IaC with TS/Python/Go instead of HCL';                  Example='pulumi up' }

    # Mobile
    [PSCustomObject]@{ Name='flutter';    Category='Mobile';   Replaces='-';          Description='Flutter SDK (includes dart) for cross-platform';        Example='flutter run' }
    [PSCustomObject]@{ Name='expo';       Category='Mobile';   Replaces='-';          Description='Expo CLI for React Native (cloud build via EAS)';       Example='npx expo start' }

    # Misc
    [PSCustomObject]@{ Name='glow';       Category='Misc';     Replaces='cat';        Description='Render Markdown with color in terminal';                Example='glow README.md' }
    [PSCustomObject]@{ Name='scoop';      Category='Misc';     Replaces='-';          Description='Windows package manager (admin-free)';                  Example='scoop install <tool>' }
    [PSCustomObject]@{ Name='rtk';        Category='Misc';     Replaces='-';          Description='Token-optimizing CLI proxy for Claude Code';            Example='rtk gain' }
)
#endregion

#region Helpers
function Test-ToolInstalled {
    param([string]$Name)
    $check = switch ($Name) {
        'expo' { 'npx' }
        default { $Name }
    }
    [bool](Get-Command $check -ErrorAction SilentlyContinue)
}

function Get-WorkspaceProfileFunctions {
    @(
        [PSCustomObject]@{ Command='ws';              Action='Workspace overview (this view)' }
        [PSCustomObject]@{ Command='cheat';           Action='Tool catalog by category' }
        [PSCustomObject]@{ Command='cheat <tool>';    Action='Description and example for one tool' }
        [PSCustomObject]@{ Command='cheat-search';    Action='Filter tools by keyword (-Keyword <kw>)' }
        [PSCustomObject]@{ Command='rules';           Action='Claude Code permission rules summary' }
        [PSCustomObject]@{ Command='paths';           Action='Profile, settings, memory, scoop locations' }
        [PSCustomObject]@{ Command='aliases-modern';  Action='Active modern-CLI aliases' }
        [PSCustomObject]@{ Command='z <fragment>';    Action='Jump to dir by frequency (zoxide)' }
        [PSCustomObject]@{ Command='lazygit';         Action='Git TUI' }
        [PSCustomObject]@{ Command='k9s';             Action='Kubernetes TUI' }
    )
}
#endregion

#region cheat
function cheat {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)][string]$Tool,
        [switch]$Object
    )

    if ($Tool) {
        $hit = $global:WorkspaceTools | Where-Object Name -ieq $Tool | Select-Object -First 1
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

    if ($Object) { return $global:WorkspaceTools }

    $global:WorkspaceTools |
        Sort-Object Category, Name |
        Format-Table -GroupBy Category -Property Name, Replaces, Description -AutoSize -Wrap
}

function cheat-search {
    [CmdletBinding()]
    param([Parameter(Mandatory, Position=0)][string]$Keyword)
    $hits = $global:WorkspaceTools | Where-Object {
        $_.Name -match $Keyword -or $_.Replaces -match $Keyword -or
        $_.Description -match $Keyword -or $_.Category -match $Keyword
    }
    if (-not $hits) { Write-Warning "No matches for '$Keyword'"; return }
    $hits | Format-Table -GroupBy Category -Property Name, Replaces, Description -AutoSize -Wrap
}
#endregion

#region rules
function rules {
    [CmdletBinding()]
    param([switch]$Object)

    $settings = "$env:USERPROFILE\.claude\settings.json"
    if (-not (Test-Path $settings)) { Write-Warning "settings.json not found at $settings"; return }
    $s = Get-Content $settings -Raw | ConvertFrom-Json
    $allow = if ($s.permissions.allow) { @($s.permissions.allow) } else { @() }
    $ask   = if ($s.permissions.ask)   { @($s.permissions.ask)   } else { @() }
    $deny  = if ($s.permissions.deny)  { @($s.permissions.deny)  } else { @() }

    $parse = {
        param($rule)
        if ($rule -match '^(?<shell>\w+)\((?<cmd>[^):*]+)') {
            [PSCustomObject]@{ Shell=$Matches.shell; Command=$Matches.cmd.Trim(); Rule=$rule }
        } else {
            [PSCustomObject]@{ Shell='-'; Command=$rule; Rule=$rule }
        }
    }

    $allowParsed = $allow | ForEach-Object { & $parse $_ } |
        ForEach-Object { $_ | Add-Member -NotePropertyName Effect -NotePropertyValue 'allow' -PassThru }
    $askParsed   = $ask   | ForEach-Object { & $parse $_ } |
        ForEach-Object { $_ | Add-Member -NotePropertyName Effect -NotePropertyValue 'ask' -PassThru }
    $denyParsed  = $deny  | ForEach-Object { & $parse $_ } |
        ForEach-Object { $_ | Add-Member -NotePropertyName Effect -NotePropertyValue 'deny' -PassThru }

    if ($Object) { return ($allowParsed + $askParsed + $denyParsed) }

    Write-Host ''
    Write-Host "  CLAUDE PERMISSION RULES" -ForegroundColor Cyan
    Write-Host "  $settings" -ForegroundColor DarkGray
    Write-Host ''
    [PSCustomObject]@{
        Effect      = 'allow'
        Count       = $allow.Count
        UniqueCmds  = ($allowParsed.Command | Sort-Object -Unique).Count
        Description = 'Auto-approved (no prompt)'
    },
    [PSCustomObject]@{
        Effect      = 'ask'
        Count       = $ask.Count
        UniqueCmds  = ($askParsed.Command | Sort-Object -Unique).Count
        Description = 'Always confirm before running'
    },
    [PSCustomObject]@{
        Effect      = 'deny'
        Count       = $deny.Count
        UniqueCmds  = ($denyParsed.Command | Sort-Object -Unique).Count
        Description = 'Blocked entirely'
    } | Format-Table -AutoSize

    Write-Host "  ALLOW - top-level commands" -ForegroundColor Green
    $allowParsed | Group-Object Command |
        Sort-Object Name |
        ForEach-Object { [PSCustomObject]@{ Command=$_.Name; Shells=$_.Count } } |
        Format-Table -AutoSize

    Write-Host "  ASK - destructive operations" -ForegroundColor Yellow
    $askParsed | Group-Object Command |
        Sort-Object Name |
        ForEach-Object { [PSCustomObject]@{ Command=$_.Name; Shells=$_.Count } } |
        Format-Table -AutoSize

    if ($deny.Count) {
        Write-Host "  DENY - fully blocked" -ForegroundColor Red
        $denyParsed | Format-Table Command, Rule -AutoSize
    }
}
#endregion

#region paths
function paths {
    [CmdletBinding()]
    param([switch]$Object)

    $rows = @(
        [PSCustomObject]@{ Key='Profile (all hosts, PS7+)';     Path=$PROFILE.CurrentUserAllHosts }
        [PSCustomObject]@{ Key='Profile (current host)';         Path=$PROFILE.CurrentUserCurrentHost }
        [PSCustomObject]@{ Key='WinPS 5.1 stub';                  Path="$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" }
        [PSCustomObject]@{ Key='Claude global settings';          Path="$env:USERPROFILE\.claude\settings.json" }
        [PSCustomObject]@{ Key='Claude memory dir';               Path="$env:USERPROFILE\.claude\projects\C--Users-PC\memory" }
        [PSCustomObject]@{ Key='Scoop apps';                      Path="$env:USERPROFILE\scoop\apps" }
        [PSCustomObject]@{ Key='Scoop shims';                     Path="$env:USERPROFILE\scoop\shims" }
    ) | ForEach-Object {
        $_ | Add-Member -NotePropertyName Exists -NotePropertyValue (Test-Path $_.Path) -PassThru
    }

    if ($Object) { return $rows }
    $rows | Format-Table -Property Exists, Key, Path -AutoSize
}
#endregion

#region aliases-modern
function aliases-modern {
    [CmdletBinding()]
    param([switch]$Object)

    $known = 'ls','ll','cat','grep','find','top','ps2','dig','diff','curl','man','l','la','lt','z'
    $rows = $known | ForEach-Object {
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
#endregion

#region ws
function workspace {
    [CmdletBinding()] param()

    Write-Host ''
    Write-Host '  WORKSPACE' -ForegroundColor Cyan
    Write-Host '  =========' -ForegroundColor DarkGray
    Write-Host ''

    # Tools by category with install state
    $byCat = $global:WorkspaceTools | ForEach-Object {
        $_ | Add-Member -NotePropertyName Installed -NotePropertyValue (Test-ToolInstalled $_.Name) -PassThru
    } | Group-Object Category

    Write-Host '  Tools (' -NoNewline -ForegroundColor DarkGray
    Write-Host "$($global:WorkspaceTools.Count)" -NoNewline -ForegroundColor Cyan
    Write-Host ' total)' -ForegroundColor DarkGray
    foreach ($g in $byCat) {
        $installed = ($g.Group | Where-Object Installed).Count
        $names = $g.Group | ForEach-Object {
            if ($_.Installed) { "$([char]27)[32m$($_.Name)$([char]27)[0m" }
            else { "$([char]27)[90m$($_.Name)$([char]27)[0m" }
        }
        Write-Host ("    {0,-9} " -f $g.Name) -NoNewline -ForegroundColor Yellow
        Write-Host ("({0}/{1}) " -f $installed, $g.Count) -NoNewline -ForegroundColor DarkGray
        Write-Host ($names -join ' ')
    }

    # Profile commands as a real table
    Write-Host ''
    Write-Host '  Profile commands' -ForegroundColor Yellow
    Get-WorkspaceProfileFunctions | Format-Table -AutoSize -HideTableHeaders | Out-Host

    # Aliases as a table
    Write-Host '  Active aliases' -ForegroundColor Yellow
    aliases-modern | Out-Host

    # Permission summary
    $settings = "$env:USERPROFILE\.claude\settings.json"
    if (Test-Path $settings) {
        Write-Host '  Claude permissions' -ForegroundColor Yellow
        $s = Get-Content $settings -Raw | ConvertFrom-Json
        [PSCustomObject]@{
            Allow = if ($s.permissions.allow) { @($s.permissions.allow).Count } else { 0 }
            Ask   = if ($s.permissions.ask)   { @($s.permissions.ask).Count }   else { 0 }
            Deny  = if ($s.permissions.deny)  { @($s.permissions.deny).Count }  else { 0 }
            Hooks = if ($s.hooks.PreToolUse) { @($s.hooks.PreToolUse).Count } else { 0 }
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
#endregion

# Banner
Write-Host 'Workspace ready. Try ' -NoNewline -ForegroundColor DarkGray
Write-Host 'ws' -NoNewline -ForegroundColor Cyan
Write-Host ' (overview), ' -NoNewline -ForegroundColor DarkGray
Write-Host 'cheat' -NoNewline -ForegroundColor Cyan
Write-Host ' (tools), ' -NoNewline -ForegroundColor DarkGray
Write-Host 'rules' -NoNewline -ForegroundColor Cyan
Write-Host ' (perms).' -ForegroundColor DarkGray
