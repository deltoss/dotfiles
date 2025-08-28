# Based on: https://doitpshway.com/automation-of-your-git-repository-via-git-hooks-and-powershell-scripts#2-how-to-check-commit-message-format-commit-msg

# path to temporary file containing commit message
param ($commitPath)

$ErrorActionPreference = "stop"

# Write-Host is used to display output in GIT console

function _ErrorWithBypassOption {
    param ($message)

    if ( !([appdomain]::currentdomain.getassemblies().fullname -like "*System.Windows.Forms*")) {
        Add-Type -AssemblyName System.Windows.Forms
    }

    $message

    # Create a custom message box with Yes/No options
    $result = [System.Windows.Forms.MessageBox]::Show(
        $message + "`n`nDo you want to bypass this check and commit anyway?",
        'Commit Format Error',
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        Write-Host "Bypassing commit format check..."
        exit 0 # Allow commit to proceed
    } else {
        exit 1 # Block commit
    }
}

try {
    Write-Host "Checking the format of commit message..."
    $commitMsg = Get-Content $commitPath -TotalCount 1

    if ($commitMsg -notmatch "^[A-Za-z0-9]{1,}-[0-9]{1,} - " -and $commitMsg -notmatch "Merge branch ") {
        _ErrorWithBypassOption "Name of commit isn't in correct format:`n<TicketName> - <Message>`n`nFor example:`n'AB-1234: Added new feature for commits'"
    }
} catch {
    $errorMsg = "There was an error:`n$_"
    Write-Host $errorMsg
    $null = [System.Windows.Forms.MessageBox]::Show($errorMsg, 'ERROR', 'OK', 'Error')
    exit 1
}
