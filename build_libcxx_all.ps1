$ErrorActionPreference = "Stop"
$sdk_dir = "$PWD\out\sdk"

$failed = $false

& .\vsdevshell.ps1
Enter-VsDevShell -VsInstallPath:"$visualStudioPath" -SkipAutomaticLocation -HostArch amd64 -Arch amd64

& .\build_libcxx.ps1 x64 Debug
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed" $LASTEXITCODE
  $failed = $true
}

#& .\build_libcxx.ps1 x64 Release
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed" $LASTEXITCODE
  $failed = $true
}

& .\build_libcxx.ps1 x86 Debug
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed" $LASTEXITCODE
  $failed = $true
}

#& .\build_libcxx.ps1 x86 Release
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed" $LASTEXITCODE
  $failed = $true
}

if ($failed) {
  Write-Host "Failed"
  exit -1;
}

$inc_dir = "$sdk_dir\include\c++\v1\"
$inc_src = "$PWD\build\x64\libcxx\Debug\include\c++"

# Remove concurrency support headers
Remove-Item "$inc_src\condition_variable"
Remove-Item "$inc_src\future"
# Remove-Item "$inc_src\mutex" <mutex> is used in internal headers, leave it
Remove-Item "$inc_src\semaphore"
Remove-Item "$inc_src\shared_mutex"
Remove-Item "$inc_src\thread"

xcopy $inc_src $inc_dir /s /y
$inc_src = "$PWD\build\x64\libcxx\Debug\include\c++abi"
xcopy $inc_src $inc_dir /s /y
