$ErrorActionPreference = "Stop"

& "$PSScriptRoot\pull_llvm.ps1"
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

$process = Start-Process powershell -NoNewWindow -PassThru -Wait -ArgumentList ".\build_tools.ps1"
if ($process.ExitCode -ne 0) {
  exit $process.ExitCode
}

& "$PSScriptRoot\install_packages_all.ps1"
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

& "$PSScriptRoot\compile_idl.ps1"
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

& "$PSScriptRoot\build_olibm_all.ps1"
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

& "$PSScriptRoot\build_libcxx_all.ps1"
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

& "$PSScriptRoot\build_nirvana_all.ps1"
