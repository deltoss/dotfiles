#!/usr/bin/env nu

use scripts/packages.nu [read-machine-data select-packages]

const REPO_ROOT = path self .
const SKIPPED_EXIT_CODE = 42
const WINGET_NO_UPGRADE_EXIT_CODE = -1978335189
const FLATPAK_MAX_RETRIES = 5

def render-external-command [argv: list<string>]: nothing -> string {
  $"run-external ...($argv | to nuon)"
}

def render-installed-guard [condition: string]: nothing -> string {
  ['if not (' $condition ') { print "Not installed, skipping"; exit 42 }']
  | str join
}

def render-membership-guard [name: string, query: list<string>]: nothing -> string {
  let condition = [($name | to nuon) ' in (' ($query | str join ' | ') ')']
    | str join
  render-installed-guard $condition
}

def cargo-package-name [package: record]: nothing -> string {
  if "--git" in ($package.args? | default []) {
    $package.tool
  } else {
    $package.id | split row '@' | first
  }
}

def build-cargo-update [package: record]: nothing -> record {
  let args = $package.args? | default []
  let check = render-membership-guard (cargo-package-name $package) [
    'cargo install --list'
    'lines'
    'parse --regex "^(?<id>[^ ]+) v"'
    'get -o id'
    'default []'
  ]
  let argv = if $package.package_type == cargo {
    [cargo install --locked ...$args $package.id]
  } else {
    [cargo binstall --no-confirm ...$args $package.id]
  }
  {checks: [$check], argv: $argv}
}

def build-mise-update [package: record]: nothing -> record {
  let args = $package.args? | default []
  let tool = $package.id | str replace --regex '@[^@]+$' '' | to nuon
  let check = render-installed-guard $'mise ls --global --installed --json ($tool) | from json | is-not-empty'
  {checks: [$check], argv: [mise upgrade --global ...$args $package.id]}
}

def build-npm-update [package: record]: nothing -> record {
  let args = $package.args? | default []
  let check = render-membership-guard $package.id [
    'npm list --global --depth=0 --json'
    'from json'
    'get -o dependencies'
    'default {}'
    'columns'
  ]
  {checks: [$check], argv: [npm update --global ...$args $package.id]}
}

def build-dotnet-update [package: record]: nothing -> record {
  let args = $package.args? | default []
  let check = render-membership-guard ($package.id | str lowercase) [
    'dotnet tool list --global'
    'lines'
    'parse --regex "^(?<id>[^ ]+) +[0-9]"'
    'get -o id'
    'default []'
    'str lowercase'
  ]
  {checks: [$check], argv: [dotnet tool update --global ...$args $package.id]}
}

def normalize-python-requirement [requirement: string]: nothing -> string {
  $requirement
  | str replace --regex '[\[<>=!~].*$' ''
  | str lowercase
  | str replace --all --regex '[-_.]+' '-'
}

def build-pip-update [package: record]: nothing -> record {
  let args = $package.args? | default []
  let check = render-membership-guard (normalize-python-requirement $package.id) [
    'pip3 list --format=json'
    'from json'
    'get name'
    'str lowercase'
    'str replace --all --regex "[-_.]+" "-"'
  ]
  {checks: [$check], argv: [pip3 install --upgrade ...$args $package.id]}
}

def build-uv-upgrade-with-saved-settings [package: record]: nothing -> record {
  let name = $package.id | split row '[' | first
  {checks: [], argv: [uv tool upgrade $name]}
}

def build-native-update [package: record]: nothing -> record {
  let id = $package.id
  let args = $package.args? | default []
  match $package.package_type {
    mise => { build-mise-update $package }
    cargo | cargo-binstall => { build-cargo-update $package }
    npm => { build-npm-update $package }
    uv => { build-uv-upgrade-with-saved-settings $package }
    dotnet => { build-dotnet-update $package }
    pip => { build-pip-update $package }
    brew => { {checks: [], argv: [brew upgrade ...$args $id]} }
    scoop => {
      {checks: [(render-external-command [scoop update])], argv: [scoop update $id]}
    }
    choco => { {checks: [], argv: [gsudo choco upgrade --yes --skip-if-not-installed ...$args $id]} }
    flatpak => { {checks: [], argv: [flatpak update --noninteractive --no-static-deltas ...$args $id]} }
    winget => { {checks: [], argv: [winget upgrade --id $id --exact ...$args]} }
    _ => { error make {msg: $"Unsupported package type: ($package.package_type)"} }
  }
}

# Render one package's update script without executing it or checking installation.
@example "Render custom update commands" {
  update package-update {package_type: commands, commands: ["print ready"]}
} --result "print ready"
@category system
@search-terms packages preview script
export def package-update [
  package: record # A package entry from the chezmoi manifests.
]: nothing -> string {
  if "update_commands" in $package {
    return ($package.update_commands | str join (char nl))
  }
  if $package.package_type == commands {
    return ($package.commands | str join (char nl))
  }
  let update = build-native-update $package
  $update.checks
  | append (render-external-command $update.argv)
  | str join (char nl)
}

def package-has-update-action [package: record]: nothing -> bool {
  $package.package_type not-in [pacman aur] or "update_commands" in $package
}

def package-skip-reason [package: record, script: string]: nothing -> string {
  if $package.version? != null { return $"Pinned to ($package.version)" }
  if $script == "" { return "Updates disabled (update_commands = [])" }
  ""
}

def guard-package-tool [package: record, script: string]: nothing -> string {
  if $script == "" or $package.tool? == null { return $script }
  let tool = $package.tool | to nuon
  [(render-installed-guard $'which ($tool) | is-not-empty') $script]
  | str join (char nl)
}

def package-update-retry-limit [package: record]: nothing -> int {
  if $package.package_type == flatpak and "update_commands" not-in $package {
    $FLATPAK_MAX_RETRIES
  } else {
    0
  }
}

def plan-package-update [package: record]: nothing -> record {
  let script = if $package.version? == null { package-update $package } else { "" }
  {
    name: ($package.name? | default $package.id? | default "Unknown")
    package_type: $package.package_type
    script: (guard-package-tool $package $script)
    reason: (package-skip-reason $package $script)
    max_retries: (package-update-retry-limit $package)
  }
}

# Select this machine's packages and build a side-effect-free update plan.
@example "Preview a pinned package's skip reason" {
  update update-plan {
    osid: windows
    computerPurpose: personal
    packages: {
      windows: [{package_type: winget, id: example, version: "1.0", tags: [all]}]
      common: []
    }
  } | get reason
} --result ["Pinned to 1.0"]
@category system
@search-terms packages preview plan
export def update-plan [
  data: record # Merged chezmoi data, including packages, osid and computerPurpose.
  --type(-t): string = "" # Select one package type.
]: nothing -> list<record> {
  select-packages $data --type $type
  | where {|package| package-has-update-action $package }
  | each {|package| plan-package-update $package }
}

def classify-update-exit [exit_code: int]: nothing -> string {
  if $exit_code in [$SKIPPED_EXIT_CODE $WINGET_NO_UPGRADE_EXIT_CODE] {
    "skipped"
  } else {
    "failed"
  }
}

def report-update-error [entry: record, failure: record]: nothing -> record {
  let exit_code = $env.LAST_EXIT_CODE
  let status = classify-update-exit $exit_code
  if $status == failed {
    print -e $"FAILED ($entry.name): ($failure.msg); exit code: ($exit_code)"
  }
  {name: $entry.name, status: $status}
}

def run-update-attempt [entry: record]: nothing -> record {
  $env.LAST_EXIT_CODE = 0
  try {
    ^nu --no-config-file --commands $entry.script
    {name: $entry.name, status: ok}
  } catch {|failure|
    report-update-error $entry $failure
  }
}

def run-update-with-retries [entry: record]: nothing -> record {
  let max_retries = $entry.max_retries? | default 0
  mut result = {name: $entry.name, status: failed}
  for attempt in 0..$max_retries {
    $result = run-update-attempt $entry
    if $result.status != failed { break }
    if $attempt < $max_retries {
      print -e $"Retrying ($entry.name): retry ($attempt + 1)/($max_retries)"
    }
  }
  $result
}

def run-update-entry [entry: record]: nothing -> record {
  if $entry.reason != "" {
    print $"SKIP ($entry.name): ($entry.reason)"
    return {name: $entry.name, status: skipped}
  }
  print $"\nUpdating ($entry.name)..."
  run-update-with-retries $entry
}

# Execute an update plan with bounded retries and isolated Nu processes.
# This command performs updates. Use update-plan to inspect a plan without running it.
@example "Report a skipped entry without running an update" {
  update run-updates [{name: example, script: "", reason: "Disabled"}]
} --result [{name: example, status: skipped}]
@category system
@search-terms packages execute maintenance
export def run-updates [
  plan: list<record> # Validated update-plan entries; max_retries defaults to zero.
]: nothing -> list<record> {
  $plan | each {|entry| run-update-entry $entry }
}

def validate-update-plan [plan: list<record>]: nothing -> nothing {
  for entry in ($plan | where reason == "") {
    if not ($entry.script | nu-check) {
      error make {msg: $"Invalid update commands for ($entry.name). Nothing was upgraded."}
    }
  }
}

def print-update-plan [plan: list<record>]: nothing -> nothing {
  for entry in $plan {
    print $"\n# ($entry.name) [($entry.package_type)]"
    print (if $entry.reason == "" { $entry.script } else { $"# SKIP: ($entry.reason)" })
  }
}

def report-update-failures [results: list<record>]: nothing -> nothing {
  let failures = $results | where status == failed | get -o name | default []
  if ($failures | is-not-empty) {
    error make {msg: $"Updates failed: ($failures | str join ', ')"}
  }
}

def run-machine-updates [plan: list<record>, data: record]: nothing -> nothing {
  cd $REPO_ROOT
  $env.CHEZMOI_SOURCEDIR = $REPO_ROOT
  $env.CHEZMOI_COMPUTERPURPOSE = $data.computerPurpose
  let results = run-updates $plan
  print $results
  report-update-failures $results
}

# Upgrade packages selected by this machine's chezmoi data.
@example "Preview all selected packages without running updates" { nu update.nu --dry-run }
@example "Preview only mise tools" { nu update.nu --dry-run --type mise }
@category system
@search-terms packages update maintenance
export def main [
  --dry-run(-n) # Print the plan without executing checks or updates.
  --type(-t): string = "" # Limit updates to one package type.
]: nothing -> nothing {
  let data = read-machine-data
  let plan = update-plan $data --type $type
  validate-update-plan $plan
  if $dry_run {
    print-update-plan $plan
  } else {
    run-machine-updates $plan $data
  }
}