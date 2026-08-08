#!/usr/bin/env nu

# Set default apps via xdg-mime, so xdg-open (and anything else that respects
# XDG mime defaults, e.g. Yazi's builtin "play" opener) resolves consistently
# instead of falling back to mimeinfo.cache's alphabetical registration order.
#
# Mimetypes come from the system mime database rather than the app's declared
# MimeType= list, which lags behind the canonical names files actually resolve
# to (e.g. mpv.desktop misses audio/x-opus+ogg, vlc.desktop misses
# video/matroska).
#
# Idempotent: re-running just re-asserts the same defaults.

def main [] {
  if (which xdg-mime | is-empty) {
    print $"(ansi yellow)xdg-mime not found, skipping default app setup(ansi reset)"
    return
  }

  print $"(ansi green_bold)Setting default applications...(ansi reset)"
  set-default "mpv.desktop" "audio"
  set-default "vlc.desktop" "video"
  set-default "yazi.desktop" "inode/directory"
}

# Sets `desktop` as the xdg-mime default for either one exact mimetype or every
# mimetype in a top-level category from the system mime database.
def set-default [desktop: string, category_or_mimetype: string] {
  if not ($"/usr/share/applications/($desktop)" | path exists) {
    print $"  (ansi yellow)($desktop) not found, skipping(ansi reset)"
    return
  }

  let mimetypes = if ($category_or_mimetype | str contains "/") {
    [$category_or_mimetype]
  } else {
    glob $"/usr/share/mime/($category_or_mimetype)/*.xml"
    | path parse
    | get stem
    | each { |type| $"($category_or_mimetype)/($type)" }
  }

  print $"  ($desktop) -> ($mimetypes | length) MIME entries"
  ^xdg-mime default $desktop ...$mimetypes
}
