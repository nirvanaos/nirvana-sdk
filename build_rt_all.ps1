$ErrorActionPreference = "Stop"

& .\run_platforms.ps1 ".\build_rt.ps1"
if ($LASTEXITCODE -ne 0) {
	Write-Host "Failed: " $LASTEXITCODE
  exit $LASTEXITCODE
}
