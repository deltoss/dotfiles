#!/usr/bin/env nu

const status_dir = ($nu.home-dir | path join ".agents" "statuses")

def now-ms []: nothing -> int {
  (date now | into int) // 1_000_000
}

def read-status [path: string] {
  try {
    let status = open $path
    if ($status | describe | str starts-with "record") {
      $status
    }
  } catch {
    null
  }
}

def dead-reason [status: record, live_pids: list<int>, now_ms: int] {
  let pid = $status.pid?
  let expires_at = $status.expiresAt?

  if $pid != null and $pid not-in $live_pids {
    "process exited"
  } else if $expires_at != null and $expires_at <= $now_ms {
    "lease expired"
  }
}

def main [] {
  if not ($status_dir | path exists) {
    return []
  }

  let live_pids = ps | get pid
  let now_ms = now-ms

  ls $status_dir
  | where type == file and name ends-with ".json"
  | each {|entry|
      let status = read-status $entry.name

      if $status != null {
        let reason = dead-reason $status $live_pids $now_ms

        if $reason != null {
          rm --force $entry.name
          {
            path: $entry.name
            reason: $reason
          }
        }
      }
    }
  | compact
}
