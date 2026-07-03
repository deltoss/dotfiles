---
name: add-package
description: >-
  Add a package, app, or CLI tool to this chezmoi dotfiles repo's install lists.
  Use whenever user wants something installed on their machines via dotfiles,
  e.g. "add yazi", "install X on both machines", "add this to my dotfiles", "I
  want <app> on my PC", "add <package> to packages.toml". Trigger even when user
  names a tool and just says "add it" without mentioning packages.toml/chezmoi.
  Finds the OFFICIAL install method (no guessing), writes the TOML entry, validates.
---

# Add Package (chezmoi dotfiles)

Add package to install lists. Write `[[packages.<scope>]]` entry in right
`.chezmoidata/<scope>/packages.toml`, official method only, then validate.

Two machines: **Windows** and **Linux**.
Edit source here. **Never run `chezmoi apply`**. User does that.

Existing entries = schema source of truth. Read the target file first; fields are self-explanatory from examples. Copy the nearest entry of the same `package_type` and adapt.

## Steps

**1. Scope: which file?**
- `common/`, *only* tools installed by identical `cargo`/`npm`/`uv`/`dotnet`
  command on both OSes (`commands` + `tool`). Preferred for cross-platform CLIs.
- `linux/`, pacman/aur/flatpak + Linux `commands`. Use `distros = ["cachyos"]`.
- `windows/`, winget/choco/scoop + Windows `commands`.

Default both machines. Cross-platform cargo/npm/uv/dotnet tool → one `common`
entry. Else → one entry per OS file.

**2. Official method: research, don't guess.** Determine the correct installation method by consulting the project's own official sources. Usually its' GitHub repository, official website, or documentation. **Not training data or community guesses**.

Priority:
1. Official vendor method. Flathub must be **developer-verified** (badge).
2. Prefer cross-platform + open.
3. In official repos → per-OS manager: **winget** (Win), **pacman** (Arch).
4. AUR/repackage = last resort, only if officially named or no first-party. Add
   `#` comment saying why (see existing AUR entries).
5. **Never Snap, and compiling from source**

No repo/flatpak/winget? → official `.msi`/installer on repository releases. Create scripts to download the setup file and start the installation process. **Ask user before doing this!**
**No official method for an OS → STOP, ask user.**

**3. Verify id exists.** Use package manager commands to verify if they actually exists. Otherwise, use the web search tools to check.

**4. Binary vs id.** `tool` = the executable name for `which`-idempotency check.
Set it when it differs from id (`go-yq`→`yq`, `imagemagick`→`magick`,
`worktrunk`→`wt`). GUI app, no CLI → omit `tool` (winget falls back to id check;
pacman/flatpak already idempotent).

**5. Write.** Copy nearest same-`package_type` entry. Respect order: managers
before consumers, `cargo-binstall` before `cargo binstall` users, Flatpak
remote-setup before flatpak apps. `tags`: `["all"]` default (dev), `personal`
(media), `work` (job), state your guess.

**6. Validate.**
```
chezmoi data
```
Must succeed (TOML parses + merges). Then render+check current-OS consumer:
```
chezmoi execute-template < .chezmoiscripts/windows/run_onchange_after_install-packages.nu.tmpl | save --force $"($env.TEMP)/check.nu"
nu-check $"($env.TEMP)/check.nu"
```
Linux consumer renders empty off-Linux, for Linux-only entry just confirm
`chezmoi data` ok + entry mirrors an existing one.

**7. Test on the target distro(s) (Linux entries).** `nu-check` only proves it
parses. For each distro in the entry's `distros`, run the install script in that
distro's container under `.containers/` (see its `README.md`) and fix the entry
until it installs clean. CLI tool → also run it. Windows-only entry → skip.

**8. Report + docs.** Package + file, command/source per OS, why official,
caveats (unverified, no build for an OS, post-install step, version pin). Update
`README.md` if the package is a prerequisite or needs a documented manual step.
Match the existing tone.