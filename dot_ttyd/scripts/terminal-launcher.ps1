$esTemplate = "es -sort date-modified-descending count:100 -p -r !'\\\`$Recycle.Bin' -r !'^C:\\Program' -r !'C:\\Windows' -r {q:1} -r {q:2} -r {q:3} -r {q:4} -r {q:5} -r {q:6} -r {q:7} -r {q:8} -r {q:9}"

# Pipe null to disable the initial unnecessary search upon entering fzf
# Sleep command is there to debounce the query so we don't search on every single letter typed
$selection = $null | fzf --bind "change:reload-sync(Start-Sleep -m 100; $esTemplate)" --phony --query "" --header="Terminal Launcher"
if ($selection)
{
  $folder = [System.IO.Path]::GetDirectoryName($selection)
  & wezterm-gui start --cwd $folder
}
