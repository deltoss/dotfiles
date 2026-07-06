# Standalone plocate search for yazi (Linux). Run with: nu -n <this file>
# Requires: plocate, fzf, and a running yazi instance (YAZI_ID is set by yazi
# for its child processes; `ya emit` uses it to reach the instance).
# No dependency on the nushell profile: fzf opts (incl. --with-shell so the
# reload binding runs through nu) are passed explicitly.

def main []: nothing -> nothing {
  let template = "plocate --ignore-case --limit 100 -r {q:1} {q:2} {q:3} {q:4} {q:5} {q:6} {q:7} {q:8} {q:9}"

  # --phony disables the initial unnecessary search upon entering fzf;
  # sleep debounces the query so we don't search on every single letter typed.
  # try/catch: fzf exits non-zero on Esc/Ctrl-C -> treat as "no selection".
  let out = (try {
    null | fzf --with-shell 'nu -c' --style full --height 40% --layout=reverse --border --bind $"change:reload-sync\(sleep 100ms; ($template)\)" --phony --print-query --header 'Search - plocate'
  } catch { '' })

  # --print-query output: line 0 = query, rest = selections
  let selections = ($out | lines | skip 1)
  if ($selections | is-empty) { return }

  let p = $selections.0
  if ($p | path type) == 'dir' {
    ya emit cd $p
  } else {
    ya emit reveal $p
  }
}
