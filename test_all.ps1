& .\run_platforms.ps1 ".\test.ps1"
if ($LASTEXITCODE -ne 0) {
	Write-Host "Failed: " $LASTEXITCODE
}
exit $LASTEXITCODE
