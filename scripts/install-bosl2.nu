#!/usr/bin/env nu

def main [] {
  let target = ("~/.local/share/OpenSCAD/libraries/BOSL2" | path expand)

  if ($target | path exists) {
    print $"(ansi yellow)✓ BOSL2 is already installed, nothing to do.(ansi reset)"
    return
  }

  print $"(ansi cyan)→ Cloning BOSL2…(ansi reset)"
  mkdir ($target | path dirname)
  git clone https://github.com/BelfrySCAD/BOSL2.git $target

  print $"(ansi green)✓ BOSL2 installed!(ansi reset)"
}

main
