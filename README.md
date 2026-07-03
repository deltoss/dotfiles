# Dotfiles

This repository serves as my personal dotfiles and system configuration hub, powered by `Chezmoi` for seamless management across Windows and Linux machines.

It contains my curated configuration files, automated package installations, and setup scripts for both personal and work environments. Whether setting up a fresh install or keeping multiple machines in sync, this repo acts as my single source of truth, saving hours of manual configuration time through version-controlled, easily deployable setups.

## Prerequisites

- `Nushell` → To run the shell scripts
- `Git` → To clone/pull from public repositories
- `1Password CLI` → For secrets in templates

### Windows

- `PowerShell 7+` → To install Nerd fonts using [nerd-fonts-installer-PS](https://github.com/deltoss/nerd-fonts-installer-ps)
- `gsudo` → For command elevation on Windows

## Installation

### Linux

#### CachyOS

1. Open up a terminal.

2. Run the below commands to install the pre-requisites and Chezmoi:

   ```bash
   # Nushell (runs the scripts), Git, and Chezmoi, all in the official repos
   sudo pacman -S --needed --noconfirm nushell git chezmoi

   # 1Password's AUR packages are signature-verified, so import its signing key first
   curl -sS https://downloads.1password.com/linux/keys/1password.asc | gpg --import
   paru -S 1password 1password-cli
   ```

3. [Optional] Set up your SSH credentials with git. Otherwise Chezmoi will use HTTPS instead of your SSH keys when cloning external repositories. See [GitHub Gists - SSH on Linux](https://gist.github.com/deltoss/5eeb3985fac481bba00bcec8da249875)

4. To authenticate with `1Password`, enable CLI integration in the desktop app (Settings → Developer → "Integrate with 1Password CLI"), or run `op signin`. See [1Password - Get started with 1Password CLI](https://developer.1password.com/docs/cli/get-started/).

5. Restart the terminal.

6. Run the below command:

   ```bash
   chezmoi init deltoss/dotfiles --ssh --apply --verbose
   ```

### Windows

1. Open up `PowerShell` as administrator.

   ---

   > 💡 Tip
   > 
   > Opening PowerShell as administrator is optional, but the chezmoi process would then prompt you to escalate privileges for each script to run.

   ---

2. Run the below command to install the pre-requisites and Chezmoi

   ```powershell
   winget install --id Nushell.Nushell -e
   winget install --id Git.Git -e
   winget install --id AgileBits.1Password -e
   winget install --id AgileBits.1Password.CLI -e
   winget install --id twpayne.chezmoi -e

   winget install --id Microsoft.PowerShell -e
   winget install --id gerardog.gsudo -e
   ```

3. [Optional] Set up your SSH credentials with git. Otherwise Chezmoi will use HTTPS instead of your SSH keys when cloning external repositories. See [GitHub Gists - SSH on Windows](https://gist.github.com/deltoss/d7aa8beb0e6d456b223041f9fe120b61)

4. To authenticate with `1Password`, see steps in [1Password - Get started with 1Password CLI](https://developer.1password.com/docs/cli/get-started/)

5. Restart the terminal

6. Run the below commands:

   ```powershell
   chezmoi init deltoss/dotfiles --ssh --apply --verbose
   ```

## Debugging Chezmoi

- Test templates with `chezmoi execute-template '{{ .osid }}'`. See [Chezmoi References - Commands - execute-template - examples](https://www.chezmoi.io/reference/commands/execute-template/#examples)
- Test an entire template file with `cat mytemplate.nu.tmpl | chezmoi execute-template`
- View variables with `chezmoi data`. See [Chezmoi References - Variables](https://www.chezmoi.io/reference/templates/variables/)
- Try the Linux install scripts in a throwaway container before applying (see `.containers/`).