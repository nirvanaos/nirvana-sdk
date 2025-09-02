$ErrorActionPreference = "Stop"
$sdk_dir = "$PWD\out\sdk"

$failed = $false

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

$inc_dir = "$sdk_dir\include"
$inc_src = "$PWD\build\x64\libcxx\Debug\include"
xcopy $inc_src $inc_dir /s /y
