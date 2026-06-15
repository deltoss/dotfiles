# CLAUDE.md

Personal [chezmoi](https://www.chezmoi.io/) dotfiles for both Windows and Linux. The source dir maps to `$HOME` (`dot_` → `.`, `.tmpl` = Go template rendered with chezmoi data). **Edit here and run `chezmoi apply` — never edit the deployed files in `$HOME`.**

## Layout

- `.chezmoi.toml.tmpl` — machine config: prompts for `email`/`username`/`computerPurpose` (`personal`|`work`), and is the **only** place 1Password runs (`onepasswordRead`, at `chezmoi init`). Everything else reads the resulting `[data]` — `{{ .key }}` in templates, `chezmoi data` in scripts — so `chezmoi apply` never needs `op`. Add new secrets as `[data]` keys here, never inline.
- `.chezmoidata/` — TOML data driving the install scripts, in `windows/`, `linux/`, `common/` subdirs (+ `steam-apps.toml` at root). chezmoi merges every file recursively by its top-level key.
- `.chezmoiscripts/{windows,linux}/run_onchange_after_*` — install/config scripts, re-run when their rendered content changes. Nushell (`.nu.tmpl`), with a few PowerShell (`.ps1.tmpl`) where it's genuinely cleaner (registry, Appx). Each is OS-guarded internally; chezmoi skips the empty render on the other OS.
- `scripts/` — Nushell helpers, **not** deployed (chezmoi-ignored). Top-level scripts dispatch on `(sys host).name` to `scripts/{windows,linux}/`. Invoked from package entries as `nu $"($env.CHEZMOI_SOURCEDIR)/scripts/<name>.nu"`.
- `dot_config/`, `dot_claude/`, `AppData/`, `Documents/`, … — config deployed to `$HOME`.

## Packages

Each OS's `install-packages` consumer installs its own `.chezmoidata/<os>/packages.toml` (`[[packages.<os>]]`) **plus** the shared `.chezmoidata/common/packages.toml` (`[[packages.common]]`), concatenated **OS-first, common-last**. `common` holds only packages whose install command + idempotency check are identical on both OSes (cargo/npm/uv/dotnet via `commands` + a `tool` check); the per-OS files hold winget/apt entries and the package managers themselves — which therefore install before the common bucket needs them. Entries are filtered by `tags` (`all` always; `personal`/`work` must match `.computerPurpose`).

The entry schema (`tool`, `precheck`, `commands`, `precommands`/`postcommands`, `package_type`, …) is the source-of-truth in the install-packages consumer template and the existing entries — read it there rather than duplicating it. The same data-file + consumer pattern applies to fonts, steam-apps, and uninstalls.

## Working on it

- Render a template: `cat file.tmpl | chezmoi execute-template`; inspect data: `chezmoi data`.
- The consumers *emit* Nushell, so validate without running: render, then `nu-check` the output.
