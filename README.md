# dev-workspace

[![release](https://img.shields.io/github/v/release/edglz/dev-workspace?display_name=tag)](https://github.com/edglz/dev-workspace/releases)
[![license](https://img.shields.io/github/license/edglz/dev-workspace)](LICENSE)
[![PowerShell 7+](https://img.shields.io/badge/PowerShell-7%2B-5391FE?logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)

A reproducible Windows + PowerShell 7 development environment: 64 modern CLI tools, sensible aliases, a discoverable PowerShell profile, and a Claude Code permission policy that auto-approves safe commands while still asking before destructive ones.

## Quick start

```powershell
git clone https://github.com/edglz/dev-workspace.git
cd dev-workspace
.\install.ps1
```

Open a new PowerShell session and run `ws` for the workspace overview.

The installer is idempotent: rerun it any time to re-sync after pulling new commits. Use `-SkipScoop`, `-SkipPip`, `-SkipNpm`, `-SkipProfile` or `-SkipSettings` to skip parts.

## What it sets up

- **Scoop buckets**: `main`, `extras`, `java`.
- **58 packages via Scoop** (modern CLI replacements, runtimes, Kubernetes, IaC, mobile, cloud, prompt engine).
- **3 Python tools via pip**: `httpie`, `posting`, `pgcli` (path is added to user `Path`).
- **2 npm globals**: `wrangler`, `@expo/cli`.
- **PowerShell profile** (`profile.ps1`) at `CurrentUserAllHosts`, plus a stub at `WindowsPowerShell\Microsoft.PowerShell_profile.ps1` so Windows PowerShell 5.1 inherits the same setup.
- **Oh My Posh prompt** (`workspace.omp.json`) — a custom two-line theme matching the workspace palette (cyan paths, yellow git, magenta when dirty, gray timing). Initialized automatically by `profile.ps1` when `oh-my-posh` is on PATH.
- **Claude Code `settings.json`** with permission rules and an empty attribution so commits stay clean.

## Profile commands

| Command          | What it does                                        |
| ---------------- | --------------------------------------------------- |
| `ws`             | Workspace overview: tools, aliases, perms summary   |
| `cheat`          | Tool catalog grouped by category                    |
| `cheat <tool>`   | One tool with description and example               |
| `cheat-search k` | Filter the catalog by keyword                       |
| `rules`          | Claude Code allow/ask/deny rules with grouping      |
| `paths`          | Profile, settings, memory, scoop locations          |
| `aliases-modern` | Active modern-CLI aliases                           |
| `z <fragment>`   | Jump to a directory by frequency (zoxide)           |

Every command supports `-Object` (where applicable) to return PSCustomObjects so you can pipe into `Where-Object`, `Sort-Object`, `Format-Table` etc.

## Aliases

| Alias  | Target  | Replaces      |
| ------ | ------- | ------------- |
| `ls`   | `eza`   | `ls`          |
| `ll`   | `eza`   | `ls -l`       |
| `cat`  | `bat`   | `cat`         |
| `grep` | `rg`    | `grep`        |
| `find` | `fd`    | `find`        |
| `top`  | `btop`  | `top`/`htop`  |
| `ps2`  | `procs` | `ps`          |
| `dig`  | `dog`   | `dig`         |
| `diff` | `difft` | `diff`        |
| `curl` | `xh`    | `curl`        |
| `man`  | `tldr`  | `man`         |
| `l`    | function `eza --icons --git`             |
| `la`   | function `eza --icons --git -la`         |
| `lt`   | function `eza --icons --git --tree -L=2` |
| `z`    | `__zoxide_z` | `cd`     |

## Tools

| Category   | Tools |
| ---------- | ----- |
| Modern CLI | eza, bat, rg, fd, sd, delta, difft, zoxide, dust, duf, xh, dog, btop, procs, hyperfine, tldr, jaq, yq, dasel, fzf, lazygit, just, watchexec, gping, trip, tokei |
| Runtime    | node, bun, pnpm, deno, python, go, java (Temurin 21), gradle, mvn, mise |
| VCS        | gh |
| Cloud      | ngrok, cloudflared, rclone, wrangler |
| API        | atac, posting, http, grpcurl |
| DB         | mongosh, pgcli, supabase |
| Kubernetes | kubectl, k9s, kubectx, kubens, helm, stern, dive, minikube, kind |
| IaC        | terraform, pulumi |
| Mobile     | flutter, expo |
| Misc       | glow, scoop, oh-my-posh, rtk |

Run `cheat` for the full catalog with descriptions and examples.

## Claude Code rules

The `settings.template.json` configures permissions so Claude can run safe operations without prompting and asks before destructive ones. Counters at time of writing:

| Effect | Rules | Behaviour                          |
| ------ | ----- | ---------------------------------- |
| allow  | 152   | Auto-approved, no prompt           |
| ask    | 95    | Always confirm before running      |
| deny   | 0     | Nothing fully blocked              |

Highlights:

- **allow**: every modern CLI, all runtimes (`node`, `bun`, `pnpm`, `deno`, `python`, `go`, `java`, `mvn`, `gradle`, `mise`), `git`, `gh`, `docker`, every Kubernetes tool, `terraform`, `pulumi`, `flutter`, `expo`, all profile commands.
- **ask**: `git reset`, `git push --force` and friends, `rm -rf`, `Remove-Item -Force`, `terraform apply/destroy`, `pulumi up/destroy`, `kubectl delete`, `helm uninstall`, `supabase db reset`, `rclone sync/delete/purge`, `npm publish`, `docker rm/rmi/system prune`, `sudo`, `scoop uninstall/reset`, and other one-way operations.
- `attribution.commit` and `attribution.pr` are set to empty strings so commits and PR descriptions are not auto-trailered.

The `hooks.PreToolUse` entry routes Bash calls through `rtk hook claude` (RTK is a token-optimizing CLI proxy). Remove the `hooks` block in `settings.template.json` before installing if you do not use RTK.

## Repository layout

```
dev-workspace/
  README.md                       this file
  CHANGELOG.md                    release notes
  LICENSE                         MIT
  profile.ps1                     PowerShell 7+ profile (CurrentUserAllHosts)
  workspace.omp.json              Oh My Posh theme matching the workspace palette
  windowsPowerShell-stub.ps1      Stub that makes Windows PowerShell 5.1 source profile.ps1
  settings.template.json          Claude Code settings template
  install.ps1                     Idempotent installer
  .gitignore
  .github/
    ISSUE_TEMPLATE/               bug + feature templates
    pull_request_template.md
```

## Re-sync after pulling

```powershell
git pull
.\install.ps1                    # all steps, idempotent
.\install.ps1 -SkipScoop -SkipPip -SkipNpm   # only refresh profile + settings
```

## Manual steps the installer does not cover

- Sign in to `gh auth login` if you want GitHub CLI.
- Run `flutter doctor` if you plan to build for Android (it will prompt for the Android SDK).
- `rtk` is not installed by `install.ps1` because it lives outside Scoop. Install it separately if you want the Bash-hook token optimization, otherwise edit `settings.template.json` to drop the `hooks` block.

## License

MIT.
