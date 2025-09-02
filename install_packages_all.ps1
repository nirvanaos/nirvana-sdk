$ErrorActionPreference = "Stop"
$tools_dir = "$PWD\out\tools-windows-x64"
$core_sdk_dir = "$PWD\out\core-sdk"

$failed = $false

$process = Start-Process powershell -NoNewWindow -UseNewEnvironment -PassThru -Wait -ArgumentList ".\install_packages.ps1 x64"
if (0 -ne $process.ExitCode) {
  Write-Host "Failed: " $process.ExitCode
  $failed = $true
}

$process = Start-Process powershell -NoNewWindow -UseNewEnvironment -PassThru -Wait -ArgumentList ".\install_packages.ps1 x86"
if (0 -ne $process.ExitCode) {
  Write-Host "Failed: " $process.ExitCode
  $failed = $true
}

if ($failed) {
  Write-Host "Failed"  
  exit -1;
}

xcopy "$PWD\build\x64\vcpkg_installed\x64-windows\tools\nidl2cpp\nidl2cpp.exe" "$tools_dir\" /y
xcopy "$PWD\build\x64\vcpkg_installed\x64-windows\include\mockhost\*.*" "$core_sdk_dir\include\mockhost\" /y
