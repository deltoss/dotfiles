# Chezmoi

## Prerequisites

- `Git` → To clone/pull from public repositories
- `1Password CLI` → For secrets in templates
- `gsudo` → To elevate permissions with scripts

## Windows Installation

1. Open up `Powershell`

1. Run the below command to install the pre-requisites and Chezmoi

   ```powershell
   winget install --id=gerardog.gsudo -e
   winget install --id=Git.Git -e
   winget install --id=AgileBits.1Password.CLI -e
   winget install --id=twpayne.chezmoi -e
   ```

3. Restart the terminal

4. [Optional] Set up your SSH credentials with git. Otherwise Chezmoi will use HTTPS instead of your SSH keys. See [GitHub Gists - SSH on Windows](https://gist.github.com/deltoss/d7aa8beb0e6d456b223041f9fe120b61)

5. To authenticate with `1Password`, see steps in [1Password - Get started with 1Password CLI](https://developer.1password.com/docs/cli/get-started/)

6. Clone this repository with this command:

   ```powershell
   git clone git@github.com:deltoss/dotfiles.git "$Env:USERPROFILE/.local/share/chezmoi"
   ```

7. Restart the terminal

8. Run the below commands:

   ```powershell
   chezmoi init
   chezmoi apply
   ```

## Debugging Chezmoi

- Test templates with `chezmoi execute-template '{{ .chezmoi.os }}'`. See [Chezmoi References - Commands - execute-template - examples](https://www.chezmoi.io/reference/commands/execute-template/#examples)
- View variables with `chezmoi data`. See [Chezmoi References - Variables](https://www.chezmoi.io/reference/templates/variables/)

