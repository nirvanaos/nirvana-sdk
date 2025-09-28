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

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

ctest --preset=$platform-debug

$dest_dir = "$lib_dir\$config"

xcopy "$build_dir\nirvana\Debug\*.*" "$dest_dir\Debug\" /y
xcopy "$build_dir\nirvana\library\CoreImport\Debug\*.*" "$dest_dir\Debug\" /y
xcopy "$build_dir\nirvana\library\CRTL\Debug\*.*" "$dest_dir\Debug\" /y
xcopy "$build_dir\googletest\Debug\*.*" "$dest_dir\Debug\" /y

$core_lib_dir = "$core_sdk_dir\lib\$platform\$config"

xcopy "$build_dir\nirvana\library\CRTL\Source\impl\win\Debug\*.*" "$core_lib_dir\Debug\" /y
xcopy "$build_dir\nirvana\library\Mock\Debug\*.*" "$core_lib_dir\Debug\" /y
