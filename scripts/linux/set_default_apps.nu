#!/usr/bin/env nu

# Set default apps via xdg-mime, so xdg-open (and anything else that respects
# XDG mime defaults, e.g. Yazi's builtin "play" opener) resolves consistently
# instead of falling back to mimeinfo.cache's alphabetical registration order.
#
# Idempotent: re-running just re-asserts the same defaults.

def main [] {
  if (which xdg-mime | is-empty) {
    print $"(ansi yellow)xdg-mime not found, skipping default app setup(ansi reset)"
    return
  }

  print $"(ansi green_bold)Setting default applications...(ansi reset)"
  set-default "mpv.desktop" "audio/"
}

# Reads the MimeType list out of a .desktop file, keeps the ones starting with
# `prefix`, and sets `desktop` as the xdg-mime default for each.
def set-default [desktop: string, prefix: string] {
  let desktop_path = $"/usr/share/applications/($desktop)"
  if not ($desktop_path | path exists) {
    print $"  (ansi yellow)($desktop) not found, skipping(ansi reset)"
    return
  }

  let mimetypes = (
    open $desktop_path
    | lines
    | where ($it | str starts-with "MimeType=")
    | first
    | str replace "MimeType=" ""
    | split row ";"
    | where ($it | str starts-with $prefix)
  )

  print $"  ($desktop) -> ($mimetypes | length) '($prefix)*' mimetypes"
  for mime in $mimetypes {
    ^xdg-mime default $desktop $mime
  }
}
