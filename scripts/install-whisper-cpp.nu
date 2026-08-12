#!/usr/bin/env nu

use ./helpers/require.nu

def main [] {
  require git
  require cmake

  let work_dir = (mktemp --directory --tmpdir whisper-cpp.XXXXXXXX)
  let source_dir = ($work_dir | path join "source")
  let build_dir = ($work_dir | path join "build")
  let bin_dir = ($nu.home-dir | path join ".local" "bin")
  let executable = if (sys host).name == "Windows" {
    "whisper-cli.exe"
  } else {
    "whisper-cli"
  }
  let built_executable = if (sys host).name == "Windows" {
    $build_dir | path join "bin" "Release" $executable
  } else {
    $build_dir | path join "bin" $executable
  }
  let installed_executable = ($bin_dir | path join $executable)

  try {
    print $"(ansi cyan)→ Cloning whisper.cpp…(ansi reset)"
    git clone --depth 1 https://github.com/ggml-org/whisper.cpp.git $source_dir
    if $env.LAST_EXIT_CODE != 0 {
      error make { msg: "Failed to clone whisper.cpp" }
    }

    print $"(ansi cyan)→ Building whisper.cpp…(ansi reset)"
    cmake -S $source_dir -B $build_dir \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=OFF \
      -DWHISPER_BUILD_TESTS=OFF \
      -DWHISPER_BUILD_SERVER=OFF
    if $env.LAST_EXIT_CODE != 0 {
      error make { msg: "Failed to configure whisper.cpp" }
    }

    cmake --build $build_dir --config Release --parallel --target whisper-cli
    if $env.LAST_EXIT_CODE != 0 {
      error make { msg: "Failed to build whisper.cpp" }
    }

    mkdir $bin_dir
    cp --force $built_executable $installed_executable
  } catch {|error|
    rm --recursive --force $work_dir
    error make { msg: $error.msg }
  }

  rm --recursive --force $work_dir
  print $"(ansi green)✓ whisper.cpp installed!(ansi reset)"
  print $"Binary: ($installed_executable)"
}
