# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `workspace.omp.json` Oh My Posh theme: two-line single-bar prompt with cyan path, yellow/magenta/red git states (dirty/behind/ahead), and gray execution time over 500ms.
- `profile.ps1` now initializes Oh My Posh automatically when the binary is on PATH, loading the theme from alongside the profile.
- `oh-my-posh` added to the Scoop package list, the `WorkspaceTools` catalog (Misc), the `paths` view, and the Claude Code permission allowlist.

## [1.0.0] - 2026-05-05

### Added
- PowerShell 7+ profile (`profile.ps1`) with discoverable commands: `ws`, `cheat`, `cheat-search`, `rules`, `paths`, `aliases-modern`.
- Tool catalog covering 64 modern CLIs grouped into 10 categories (Modern, Runtime, VCS, Cloud, API, DB, K8s, IaC, Mobile, Misc).
- Modern aliases (`ls`, `cat`, `grep`, `find`, `top`, `dig`, `diff`, `curl`, `man`) targeting Rust/Go replacements.
- Idempotent installer (`install.ps1`) covering Scoop bootstrap, 57 packages, pip user installs, npm globals, profile copy, and Claude settings merge with backup.
- Windows PowerShell 5.1 stub so the profile applies in legacy hosts.
- Claude Code settings template with 152 allow rules, 95 ask rules, and empty attribution to keep commits and PRs un-trailered.
