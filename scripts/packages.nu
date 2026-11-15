const REPO_ROOT = path self ..
const PACKAGE_TYPES = [
  commands pacman aur flatpak winget mise cargo cargo-binstall
  npm uv dotnet brew scoop choco pip
]

def validate-package-type [package_type: string]: nothing -> nothing {
  if $package_type != "" and $package_type not-in $PACKAGE_TYPES {
    error make {
      msg: $"Unknown package type: ($package_type). Choose from: ($PACKAGE_TYPES | str join ', ')"
    }
  }
}

def machine-package-scope [data: record]: nothing -> string {
  if $data.osid != windows and not ($data.osid | str starts-with linux) {
    error make {msg: $"Unsupported OS: ($data.osid)"}
  }
  if $data.osid == windows { "windows" } else { "linux" }
}

def package-matches-machine [package: record, data: record]: nothing -> bool {
  if $data.osid == windows { return true }
  let distros = $package.distros? | default [all]
  "all" in $distros or ($data.osid == linux-cachyos and "cachyos" in $distros)
}

# Select full package entries for installs or updates, OS-specific entries first.
export def select-packages [
  data: record # Merged chezmoi data, including packages, osid and computerPurpose.
  --type(-t): string = "" # Select one package type.
]: nothing -> list<record> {
  validate-package-type $type
  let scope = machine-package-scope $data
  ($data.packages | get $scope) ++ $data.packages.common
  | where {|package| "all" in $package.tags or $data.computerPurpose in $package.tags }
  | where {|package| $type == "" or $package.package_type == $type }
  | where {|package| package-matches-machine $package $data }
}

# Read this repository's manifests merged with the current machine's chezmoi data.
export def read-machine-data []: nothing -> record {
  let result = ^chezmoi --source $REPO_ROOT data --format json | complete
  if $result.exit_code != 0 {
    error make {msg: $"Cannot read chezmoi data: ($result.stderr)"}
  }
  $result.stdout | from json
}
