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

xcopy nirvana\library\include\*.h $inc_dir\ /y

xcopy nirvana\library\include\CRTL\*.h $inc_dir\ /y /s
xcopy nirvana\library\include\CRTL\*. $inc_dir\ /y /s

xcopy nirvana\library\include\Nirvana\*.h $inc_dir\Nirvana\ /y /s
xcopy build\nirvana\library\include\Nirvana\*.h $inc_dir\Nirvana\ /y /s
xcopy nirvana\library\include\Nirvana\*.idl $inc_dir\Nirvana\ /y /s
xcopy nirvana\library\include\Nirvana\*.inl $inc_dir\Nirvana\ /y /s

xcopy nirvana\orb\include\CORBA\*.h $inc_dir\CORBA\ /y /s
xcopy build\nirvana\orb\include\CORBA\*.h $inc_dir\CORBA\ /y /s
xcopy nirvana\orb\include\CORBA\*.idl $inc_dir\CORBA\ /y /s
xcopy nirvana\orb\include\CORBA\*.inl $inc_dir\CORBA\ /y /s

xcopy $PWD\googletest\googletest\googletest\include\gtest\*.* $inc_dir\gtest\ /y /s

xcopy nirvana\cmake\* $sdk_dir\cmake\ /y /s
