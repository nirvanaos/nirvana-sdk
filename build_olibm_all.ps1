$ErrorActionPreference = "Stop"
$sdk_dir = "$PWD\out\sdk"
$libm_root = "$PWD\openlibm"

$failed = $false

& .\build_olibm.ps1 x64 Debug
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed" $LASTEXITCODE
  $failed = $true
}

& .\build_olibm.ps1 x64 Release
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed" $LASTEXITCODE
  $failed = $true
}

& .\build_olibm.ps1 x86 Debug
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed" $LASTEXITCODE
  $failed = $true
}

& .\build_olibm.ps1 x86 Release
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed" $LASTEXITCODE
  $failed = $true
}

if ($failed) {
  Write-Host "Failed"
  exit -1;
}

$inc_dir = "$sdk_dir\include"

if (!(Test-Path $inc_dir)) {
	mkdir $inc_dir
}

Copy-Item "$libm_root\include\openlibm_math.h" "$inc_dir\math.h" -Force
Copy-Item "$libm_root\include\openlibm_fenv.h" "$inc_dir\fenv.h" -Force
Copy-Item "$libm_root\include\openlibm_complex.h" "$inc_dir\complex.h" -Force

xcopy "$libm_root\include\openlibm_defs.h" "$inc_dir\" /y
xcopy "$libm_root\include\openlibm_fenv_amd64.h" "$inc_dir\" /y
xcopy "$libm_root\include\openlibm_fenv_arm.h" "$inc_dir\" /y
xcopy "$libm_root\include\openlibm_fenv_i387.h" "$inc_dir\" /y
xcopy "$libm_root\include\openlibm_fenv_loongarch64.h" "$inc_dir\" /y
xcopy "$libm_root\include\openlibm_fenv_mips.h" "$inc_dir\" /y
xcopy "$libm_root\include\openlibm_fenv_powerpc.h" "$inc_dir\" /y
xcopy "$libm_root\include\openlibm_fenv_riscv.h" "$inc_dir\" /y
xcopy "$libm_root\include\openlibm_fenv_s390.h" "$inc_dir\" /y

xcopy "$libm_root\src\types-compat.h" "$inc_dir\" /y
xcopy "$libm_root\src\fpmath.h" "$inc_dir\" /y
xcopy "$libm_root\src\aarch64_fpmath.h" "$inc_dir\" /y
xcopy "$libm_root\src\amd64_fpmath.h" "$inc_dir\" /y
xcopy "$libm_root\src\amd64_fpmath.h" "$inc_dir\" /y
xcopy "$libm_root\src\i386_fpmath.h" "$inc_dir\" /y
xcopy "$libm_root\src\loongarch64_fpmath.h" "$inc_dir\" /y
xcopy "$libm_root\src\loongarch64_fpmath.h" "$inc_dir\" /y
xcopy "$libm_root\src\mips_fpmath.h" "$inc_dir\" /y
xcopy "$libm_root\src\powerpc_fpmath.h" "$inc_dir\" /y
xcopy "$libm_root\src\riscv_fpmath.h" "$inc_dir\" /y
xcopy "$libm_root\src\s390_fpmath.h" "$inc_dir\" /y
