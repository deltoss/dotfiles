$xdgProfile = "$Env:UserProfile/.config/PowerShell/profile.ps1"
if (Test-Path $xdgProfile) {
    . $xdgProfile
}
