# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal [chezmoi](https://www.chezmoi.io/) dotfiles for Windows machines (with minor Linux support). Source dir maps to `$HOME`: `dot_` prefix becomes `.` (e.g., `dot_config/lazygit` → `~/.config/lazygit`), and `.tmpl` suffix means the file is a Go template rendered with chezmoi data. Never edit deployed files in `$HOME` — edit here, then run `chezmoi apply`.

## Structure

- `.chezmoi.toml.tmpl` — machine config: prompts for email/username/`computerPurpose` (`personal` or `work`), pulls secrets from 1Password (`onepasswordRead`). Templates branch on `.computerPurpose` and `.osid`.
- `.chezmoidata/` — TOML data driving the install scripts, split into `windows/` and `linux/` subdirs (`steam-apps.toml` stays at the root). See Packages below.
- `.chezmoiscripts/` — `run_onchange_after_*` scripts. Scripts are Nushell (`.nu.tmpl`), with a few kept in PowerShell (`.ps1.tmpl`) for certain tasks that's easier and cleaner to do in PowerShell.
- `.chezmoiexternal.toml.tmpl` — external git repos cloned into `~/.config` (PowerShell profile, nushell, nvim, wezterm configs live in separate repos, refreshed weekly).
- `.chezmoiignore` — excludes `scripts/`, `README.md`, and OS-specific dirs from deployment.
- `dot_config/`, `dot_claude/`, `AppData/`, `Documents/` — actual config files deployed to `$HOME`.
- `scripts/` — nushell helper scripts, NOT deployed (chezmoi-ignored). Invoked from package entries via `nu $"($env.CHEZMOI_SOURCEDIR)/scripts/<name>.nu"`. Top-level scripts are OS dispatchers that `match (sys host).name` and call `scripts/windows/` or `scripts/linux/` variants.

## Packages

`.chezmoidata/windows/packages.toml` defines a flat list of `[[packages.windows]]` entries, filtered by `tags`: `"all"` always installs; `"personal"`/`"work"` must match `.computerPurpose`. Installation happens in `.chezmoiscripts/windows/run_onchange_after_install-packages.nu.tmpl` — Nushell, self-elevates via `gsudo`.

Entry fields:
- `package_type` — `"winget"` (uses `id`) or `"commands"` (uses `commands` list).
- `id` — winget package ID; skipped if already installed (checked via `Get-WinGetPackage`). Optional `version` pins it.
- `name` — display name (falls back to `id`).
- `tool` — executable name; if present, entry is skipped when `which` finds it (preferred idempotency check for `commands` entries).
- `precheck` — a Nushell expression returning a bool; the entry installs only if it evaluates to `true`, otherwise it's skipped. Like `tool` but an arbitrary command instead of a binary lookup (e.g. `"not ('C:\Some\Path' | path exists)"` installs only when that path is missing). Only evaluated when the entry isn't already detected as installed.
- `commands` — list of Nushell install commands (npm, cargo, uv, choco, scoop, `winget`, or a `scripts/*.nu` script; irreducibly-PowerShell installers run via `powershell -c`). Without `tool`, they re-run every time the script triggers, so they must be idempotent themselves.
- `precommands` / `postcommands` — arrays of commands run before/after the install, only when the entry is actually being installed (skipped if already present). E.g., PATH refresh, setup scripts.
- `description` — printed during install.

Same data-file + script pattern applies to `.chezmoidata/{windows,linux}/fonts.toml`, `.chezmoidata/windows/uninstalls.toml`, and `.chezmoidata/steam-apps.toml` (kept at the root), with their matching `.chezmoiscripts/` scripts.

## Working on this repo

- Test a template: `chezmoi execute-template '{{ .osid }}'` or `cat file.tmpl | chezmoi execute-template`
- View available template variables: `chezmoi data`
- 1Password (`op`) is invoked **only** by `.chezmoi.toml.tmpl`, at `chezmoi init` (needs the 1Password CLI authenticated). Every other template/script reads the values from config `[data]` — `{{ .key }}` in templates, `chezmoi data` in scripts — so `chezmoi apply` never needs `op`. Add any new secret as a `[data]` key in `.chezmoi.toml.tmpl`, not inline.