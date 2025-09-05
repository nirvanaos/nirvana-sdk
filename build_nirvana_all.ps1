$ErrorActionPreference = "Stop"
$sdk_dir = "$PWD\out\sdk"

$failed = $false

& .\build_nirvana.ps1 x64
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed" $LASTEXITCODE
  $failed = $true
}

& .\build_nirvana.ps1 x86
if ($LASTEXITCODE -ne 0) {
  Write-Host "Failed" $LASTEXITCODE
  $failed = $true
}

if ($failed) {
  Write-Host "Failed"  
  exit -1;
}

$inc_dir = "$sdk_dir\include"
$nirvana_dir = "$PWD\nirvana"

xcopy nirvana\library\Include\*.h $inc_dir\ /y /s
xcopy nirvana\library\Include\*.idl $inc_dir\ /y /s
xcopy nirvana\library\Include\*.inl $inc_dir\ /y /s
xcopy build\nirvana\library\Include\*.h $inc_dir\ /y /s

xcopy nirvana\orb\include\*.h $inc_dir\ /y /s
xcopy nirvana\orb\include\*.idl $inc_dir\ /y /s
xcopy nirvana\orb\include\*.inl $inc_dir\ /y /s
xcopy build\nirvana\orb\include\*.h $inc_dir\ /y /s

xcopy nirvana\library\CRTL\Include\*.h $inc_dir\ /y /s
xcopy nirvana\library\CRTL\Include\*. $inc_dir\ /y /s

xcopy $PWD\googletest\googletest\googletest\include\gtest\*.* $inc_dir\gtest\ /y /s

xcopy nirvana\cmake\* $sdk_dir\cmake\ /y /s
