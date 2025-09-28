$ErrorActionPreference = "Stop"
$sdk_dir = "$PWD\out\sdk"
$core_sdk_dir = "$PWD\out\core-sdk\windows"

if ($args.count -ge 1) {
	$platform = $args[0]
} else {
	$platform = "x64"
}

$lib_dir = "$sdk_dir\lib\$platform"
$build_dir = "$PWD\build\$platform\nirvana"

cmake --preset=$platform
cmake --build --preset=$platform-debug
cmake --build --preset=$platform-release

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

$dest_dir = "$lib_dir\$config"
$core_lib_dir = "$core_sdk_dir\lib\$platform"

xcopy "$build_dir\nirvana\Debug\*.*" "$dest_dir\Debug\" /y
xcopy "$build_dir\nirvana\library\CoreImport\Debug\*.*" "$dest_dir\Debug\" /y
xcopy "$build_dir\nirvana\library\CRTL\Debug\*.*" "$dest_dir\Debug\" /y
xcopy "$build_dir\googletest\Debug\*.*" "$dest_dir\Debug\" /y

xcopy "$build_dir\nirvana\library\CRTL\Source\impl\win\Debug\*.*" "$core_lib_dir\Debug\" /y
xcopy "$build_dir\nirvana\library\Mock\Debug\*.*" "$core_lib_dir\Debug\" /y

xcopy "$build_dir\nirvana\Release\*.*" "$dest_dir\Release\" /y
xcopy "$build_dir\nirvana\library\CoreImport\Release\*.*" "$dest_dir\Release\" /y
xcopy "$build_dir\nirvana\library\CRTL\Release\*.*" "$dest_dir\Release\" /y
xcopy "$build_dir\googletest\Release\*.*" "$dest_dir\Release\" /y

xcopy "$build_dir\nirvana\library\CRTL\Source\impl\win\Release\*.*" "$core_lib_dir\Release\" /y
xcopy "$build_dir\nirvana\library\Mock\Release\*.*" "$core_lib_dir\Release\" /y
