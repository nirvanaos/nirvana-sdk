$ErrorActionPreference = "Stop"

$sdk_dir = "$PWD\out\sdk"
$clang_lib = "lib\clang\21"

$llvm = "$env:LLVM_PATH"
if (-not (Test-Path "$llvm\$clang_lib")) {

  $llvm = "$env:ProgramFiles\LLVM"
  if (-not (Test-Path "$llvm\$clang_lib")) {
    $llvm = "$PWD\llvm-release"
    $llvm_root = "$PWD\llvm-project"

    & "$PSScriptRoot\vsdevshell.ps1"
    Enter-VsDevShell -VsInstallPath:"$visualStudioPath" -SkipAutomaticLocation -HostArch amd64 -Arch amd64

    cmake -G Ninja -S "$llvm_root\llvm" -B $llvm `
      -DLLVM_ENABLE_PROJECTS="clang;lld"         `
      -DCMAKE_BUILD_TYPE=Release

    cmake --build $llvm
  }
}
xcopy "$llvm\$clang_lib\include\*.h" "$sdk_dir\include\clang" /y /i /s
