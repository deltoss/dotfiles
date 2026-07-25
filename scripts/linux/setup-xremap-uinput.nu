#!/usr/bin/env nu

# Grants xremap access to /dev/uinput without sudo: a udev rule that fixes the
# group/permissions on the uinput node, plus adding the user to the `input` group.
# Idempotent - only appends the rule if its marker isn't already in the file,
# gpasswd is a no-op if already a member.
# See https://github.com/xremap/xremap/blob/master/doc/running_without_sudo.md

const marker = "# For xremap - Do not remove this marker"
const rules_file = "/etc/udev/rules.d/99-input.rules"

def main [] {
  print "Configuring uinput access for xremap..."

  let already_present = (
    ($rules_file | path exists)
    and (open $rules_file | str contains $marker)
  )

  if not $already_present {
    $"($marker)
KERNEL==\"uinput\", GROUP=\"input\", TAG+=\"uaccess\", MODE:=\"0660\", OPTIONS+=\"static_node=uinput\"
" | sudo tee --append $rules_file
  }

  sudo gpasswd -a $env.USER input

  print "Done. Re-boot for the input group and xremap to work correctly."
}