$ErrorActionPreference = "Stop"
$core_sdk_dir = "$PWD\out\core-sdk"

& .\run_platforms.ps1 ".\install_packages.ps1"
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

xcopy "$PWD\build\x64\vcpkg_installed\x64-windows\include\mockhost\*.*" "$core_sdk_dir\include\mockhost\" /y
