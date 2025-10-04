$ErrorActionPreference = "Stop"
$tools_dir = "$PWD\out\tools-windows-x64"
$core_sdk_dir = "$PWD\out\core-sdk"

$failed = $false

& .\install_packages.ps1 x64
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed" $LASTEXITCODE
  $failed = $true
}

& .\install_packages.ps1 x86
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed" $LASTEXITCODE
  $failed = $true
}

if ($failed) {
  Write-Host "Failed"  
  exit -1;
}

xcopy "$PWD\build\x64\vcpkg_installed\x64-windows\tools\nidl2cpp\nidl2cpp.exe" "$tools_dir\" /y
