# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal [chezmoi](https://www.chezmoi.io/) dotfiles for Windows machines (with minor Linux support). Source dir maps to `$HOME`: `dot_` prefix becomes `.` (e.g., `dot_config/lazygit` → `~/.config/lazygit`), and `.tmpl` suffix means the file is a Go template rendered with chezmoi data. Never edit deployed files in `$HOME` — edit here, then run `chezmoi apply`.

## Structure

- `.chezmoi.toml.tmpl` — machine config: prompts for email/username/`computerPurpose` (`personal` or `work`), pulls secrets from 1Password (`onepasswordRead`). Templates branch on `.computerPurpose` and `.osid`.
- `.chezmoidata/` — TOML data driving the install scripts (see Packages below).
- `.chezmoiscripts/` — `run_onchange_after_*` scripts; chezmoi re-runs each when its rendered content changes (data file changes embed into the template output, triggering re-run).
- `.chezmoiexternal.toml.tmpl` — external git repos cloned into `~/.config` (PowerShell profile, nushell, nvim, wezterm configs live in separate repos, refreshed weekly).
- `.chezmoiignore` — excludes `scripts/`, `README.md`, and OS-specific dirs from deployment.
- `dot_config/`, `dot_claude/`, `AppData/`, `Documents/` — actual config files deployed to `$HOME`.
- `scripts/` — nushell helper scripts, NOT deployed (chezmoi-ignored). Invoked from package entries via `nu "$env:CHEZMOI_SOURCEDIR/scripts/<name>.nu"`. Top-level scripts are OS dispatchers that `match (sys host).name` and call `scripts/windows/` or `scripts/linux/` variants.

## Packages

`.chezmoidata/packages.toml` defines a flat list of `[[packages.windows]]` entries, filtered by `tags`: `"all"` always installs; `"personal"`/`"work"` must match `.computerPurpose`. Installation happens in `.chezmoiscripts/run_onchange_after_windows-install-packages.ps1.tmpl` (self-elevates to admin).

Entry fields:
- `package_type` — `"winget"` (uses `id`) or `"commands"` (uses `commands` list).
- `id` — winget package ID; skipped if already installed (checked via `Get-WinGetPackage`). Optional `version` pins it.
- `name` — display name (falls back to `id`).
- `tool` — executable name; if present, entry is skipped when `Get-Command` finds it (preferred idempotency check for `commands` entries).
- `commands` — list of install commands (npm, cargo, uv, choco, scoop, or a `scripts/*.nu` script). Without `tool`, they re-run every time the script triggers, so they must be idempotent themselves.
- `precommand` / `postcommand` — always run before/after the entry, even if already installed (e.g., PATH refresh, setup scripts).
- `description` — printed during install.

Same data-file + script pattern applies to `.chezmoidata/fonts.toml`, `steam-apps.toml`, and `uninstalls.toml` with their matching `.chezmoiscripts/` scripts.

## Working on this repo

- Test a template: `chezmoi execute-template '{{ .osid }}'` or `cat file.tmpl | chezmoi execute-template`
- View available template variables: `chezmoi data`
- Templates referencing 1Password (`onepasswordRead`) need an authenticated 1Password CLI to render.