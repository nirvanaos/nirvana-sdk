$ErrorActionPreference = "Stop"
$sdk_dir = "$PWD\out\sdk"
$core_sdk_dir = "$PWD\out\core-sdk"

& .\run_platforms.ps1 ".\build_nirvana.ps1"
if ($LASTEXITCODE -ne 0) {
	Write-Host "Failed: " $LASTEXITCODE
  exit $LASTEXITCODE
}

$inc_dir = "$sdk_dir\include"
$core_inc_dir = "$core_sdk_dir\include"
$nirvana_dir = "$PWD\nirvana"

xcopy nirvana\library\Include\*.h $inc_dir\ /y /s
xcopy nirvana\library\Include\*.idl $inc_dir\ /y /s
xcopy nirvana\library\Include\*.inl $inc_dir\ /y /s
xcopy build\idl\library\Include\*.h $inc_dir\ /y /s

xcopy nirvana\orb\include\*.h $inc_dir\ /y /s
xcopy nirvana\orb\include\*.idl $inc_dir\ /y /s
xcopy nirvana\orb\include\*.inl $inc_dir\ /y /s
xcopy build\idl\orb\Include\*.h $inc_dir\ /y /s

xcopy nirvana\library\CRTL\Include\*.h $inc_dir\ /y /s
xcopy nirvana\library\CRTL\Include\*. $inc_dir\ /y /s

xcopy nirvana\library\Mock\Include\*.h $core_inc_dir\ /y /s

xcopy $PWD\googletest\googletest\googletest\include\gtest\*.* $inc_dir\gtest\ /y /s

xcopy nirvana\cmake\* $sdk_dir\cmake\ /y /s
