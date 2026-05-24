use ./modules/fzf-env.nu *
use ./modules/run-detached.nu *

let es_template = "es -sort date-modified-descending count:100 -p -r !'\\$Recycle.Bin' -r !'^C:\\Program' -r !'C:\\Windows' -r {q:1} -r {q:2} -r {q:3} -r {q:4} -r {q:5} -r {q:6} -r {q:7} -r {q:8} -r {q:9}"

# Pipe null to disable the initial unnecessary search upon entering fzf
# Sleep command is there to debounce the query so we don't search on every single letter typed
let selection = null | fzf --preview $env.FZF_CUSTOM_PREVIEW --bind $"change:reload-sync\(sleep 100ms; ($es_template)\)" --phony --query "" --header="Editor Launcher"
if ($selection | is-not-empty) {
  let wezterm_running = (ps | where name =~ "wezterm-gui" | is-not-empty)
  if $wezterm_running {
    let pane_id = ^wezterm cli spawn -- $env.EDITOR $selection
    ^wezterm cli activate-pane --pane-id $pane_id
    print $"(ansi green)Spawned new tab, switch to your Wezterm terminal(ansi reset)"
  } else {
    run-detached wezterm-gui start -- $env.EDITOR $selection
  }
}