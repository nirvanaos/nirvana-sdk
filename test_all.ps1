$failed = $false

& .\test.ps1 x64 Debug
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed" $LASTEXITCODE
  $failed = $true
}

& .\test.ps1 x64 Release
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed" $LASTEXITCODE
  $failed = $true
}

& .\test.ps1 x86 Debug
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed" $LASTEXITCODE
  $failed = $true
}

& .\test.ps1 x86 Release
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed" $LASTEXITCODE
  $failed = $true
}

if ($failed) {
  Write-Host "Failed"  
  exit -1;
}
