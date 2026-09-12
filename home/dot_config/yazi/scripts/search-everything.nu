# Standalone Everything search for yazi. Run with: nu -n <this file>
# Requires: es (Everything CLI), fzf, and a running yazi instance (YAZI_ID is
# set by yazi for its child processes; `ya emit` uses it to reach the instance).
# No dependency on the nushell profile: fzf opts (incl. --with-shell so the
# reload binding runs through nu) are passed explicitly.

def main []: nothing -> nothing {
  let template = "es count:100 -p -r {q:1} -r {q:2} -r {q:3} -r {q:4} -r {q:5} -r {q:6} -r {q:7} -r {q:8} -r {q:9}"

  # --phony disables the initial unnecessary search upon entering fzf;
  # sleep debounces the query so we don't search on every single letter typed.
  # try/catch: fzf exits non-zero on Esc/Ctrl-C -> treat as "no selection".
  let out = (try {
    null | fzf --with-shell 'nu -c' --style full --height 40% --layout=reverse --border --bind $"change:reload-sync\(sleep 100ms; ($template)\)" --phony --print-query --header 'Search - Everything'
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
