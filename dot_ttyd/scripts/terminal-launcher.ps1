$esTemplate = "es -sort date-modified-descending count:100 -r !'*Recycle.Bin*\*' !'*RECYCLE*\*' {q:1} {q:2} {q:3} {q:4} {q:5} {q:6} {q:7} {q:8} {q:9}"

# Pipe null to disable the initial unnecessary search upon entering fzf
# Sleep command is there to debounce the query so we don't search on every single letter typed
$selection = $null | fzf --bind "change:reload-sync(Start-Sleep -m 100; $esTemplate)" --phony --query "" --header="Terminal Launcher"
if ($selection)
{
  $folder = [System.IO.Path]::GetDirectoryName($selection)
  & wezterm cli spawn --new-window --cwd $folder
}
