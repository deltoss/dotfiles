# Dotfiles

This repository serves as my personal dotfiles and system configuration hub, powered by `Chezmoi` for seamless management across Windows machines. It contains my curated configuration files, automated package installations, and setup scripts for both personal and work environments. Whether setting up a fresh install or keeping multiple machines in sync, this repo acts as my single source of truth, saving hours of manual configuration time through version-controlled, easily deployable setups.

## Prerequisites

- `PowerShell 7+` → To install Nerd fonts using [nerd-fonts-installer-PS](https://github.com/deltoss/nerd-fonts-installer-ps)
- `Git` → To clone/pull from public repositories
- `1Password CLI` → For secrets in templates

## Windows Installation

1. Open up `PowerShell` as administrator.

   ---

   > 💡 Tip
   > 
   > Opening PowerShell as administrator is optional, but the chezmoi process would then prompt you to escalate privileges for each script to run.

   ---

2. Run the below command to install the pre-requisites and Chezmoi

   ```powershell
   winget install --id Git.Git -e
   winget install --id AgileBits.1Password -e
   winget install --id AgileBits.1Password.CLI -e
   winget install --id Microsoft.PowerShell -e
   winget install --id twpayne.chezmoi -e
   ```

3. [Optional] Set up your SSH credentials with git. Otherwise Chezmoi will use HTTPS instead of your SSH keys when cloning external repositories. See [GitHub Gists - SSH on Windows](https://gist.github.com/deltoss/d7aa8beb0e6d456b223041f9fe120b61)

4. To authenticate with `1Password`, see steps in [1Password - Get started with 1Password CLI](https://developer.1password.com/docs/cli/get-started/)

5. Restart the terminal

6. Run the below commands:

   ```powershell
   chezmoi init deltoss/dotfiles --ssh --apply --verbose
   ```

## Debugging Chezmoi

- Test templates with `chezmoi execute-template '{{ .chezmoi.os }}'`. See [Chezmoi References - Commands - execute-template - examples](https://www.chezmoi.io/reference/commands/execute-template/#examples)
- View variables with `chezmoi data`. See [Chezmoi References - Variables](https://www.chezmoi.io/reference/templates/variables/)

