$ErrorActionPreference = "Stop"
$sdk_dir = "$PWD\out\sdk"

& .\run_platforms.ps1 ".\build_libcxx.ps1"
if ($LASTEXITCODE -ne 0) {
	Write-Host "Failed: " $LASTEXITCODE
  exit $LASTEXITCODE
}

$inc_dir = "$sdk_dir\include\c++\v1\"
$inc_src = "$PWD\build\libcxx\x64\include\c++"

# Remove concurrency support headers
Remove-Item "$inc_src\condition_variable"
Remove-Item "$inc_src\future"
# Remove-Item "$inc_src\mutex" <mutex> is used in internal headers, leave it
Remove-Item "$inc_src\semaphore"
Remove-Item "$inc_src\shared_mutex"
Remove-Item "$inc_src\thread"

xcopy $inc_src $inc_dir /s /y
$inc_src = "$PWD\build\libcxx\x64\include\c++abi"
xcopy $inc_src $inc_dir /s /y
