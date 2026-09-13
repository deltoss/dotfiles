# CLAUDE.md

Personal [chezmoi](https://www.chezmoi.io/) dotfiles for both Windows and Linux. `home/` maps to `$HOME` (`dot_` → `.`, `.tmpl` = Go template rendered with chezmoi data). **Edit here and run `chezmoi apply`, never edit the deployed files in `$HOME`.**

## Layout

- `home/.chezmoi.toml.tmpl`, machine config: prompts for `email`/`username`/`computerPurpose` (`personal`|`work`), and is the **only** place 1Password runs (`onepasswordRead`, at `chezmoi init`). Everything else reads the resulting `[data]`, `{{ .key }}` in templates, `chezmoi data` in scripts, so `chezmoi apply` never needs `op`. Add new secrets as `[data]` keys here, never inline.
- `home/.chezmoidata/`, TOML data driving the install scripts, in `windows/`, `linux/`, `common/` subdirs (+ `steam-apps.toml` at root). chezmoi merges every file recursively by its top-level key.
- `home/.chezmoiscripts/{windows,linux,common}/run_onchange_after_*`, install/config scripts, re-run when their rendered content changes. `common/` holds the ones that are identical on both OSes and need no guard. Nushell (`.nu.tmpl`), with a few PowerShell (`.ps1.tmpl`) where it's genuinely cleaner (registry, Appx). Each is OS-guarded internally; chezmoi skips the empty render on the other OS.
- `scripts/`, Nushell helpers, **not** deployed (outside `home/`). Top-level scripts dispatch on `(sys host).name` to `scripts/{windows,linux}/`. Invoked from package entries as `nu $"($env.CHEZMOI_SOURCEDIR)/scripts/<name>.nu"`.
- `home/dot_config/`, `home/AppData/`, `home/Documents/`, …, config deployed to `$HOME`.

## Packages

Each OS's `install-packages` consumer installs its own `home/.chezmoidata/<os>/packages.toml` (`[[packages.<os>]]`) **plus** the shared `home/.chezmoidata/common/packages.toml` (`[[packages.common]]`), concatenated **OS-first, common-last**. `common` holds only packages whose install command + idempotency check are identical on both OSes (cargo/npm/uv/dotnet via `commands` + a `tool` check); the per-OS files hold winget/apt entries and the package managers themselves, which therefore install before the common bucket needs them. Entries are filtered by `tags` (`all` always; `personal`/`work` must match `.computerPurpose`).

The entry schema (`tool`, `precheck`, `commands`, `precommands`/`postcommands`, `package_type`, …) is the source-of-truth in the install-packages consumer template and the existing entries, read it there rather than duplicating it. The same data-file + consumer pattern applies to fonts, steam-apps, models, and uninstalls.

## Working on it

- Render a template: `cat file.tmpl | chezmoi execute-template`; inspect data: `chezmoi data`.
- The consumers *emit* Nushell, so validate without running: render, then `nu-check` the output.
