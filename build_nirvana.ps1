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

# ctest --preset=$platform-debug

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

$dest_dir = "$lib_dir\$config"

xcopy "$build_dir\nirvana\Debug\libnirvana.a" "$dest_dir\Debug\" /y
xcopy "$build_dir\nirvana\library\CoreImport\Debug\libcoreimport.a" "$dest_dir\Debug\" /y
xcopy "$build_dir\nirvana\library\CRTL\Debug\libcrtl.a" "$dest_dir\Debug\" /y
xcopy "$build_dir\googletest\Debug\libgoogletest-nirvana.a" "$dest_dir\Debug\" /y

$core_lib_dir = "$core_sdk_dir\lib\$platform\$config"

xcopy "$build_dir\nirvana\library\CRTL\Source\impl\win\Debug\libcrtl-main.a" "$core_lib_dir\Debug\" /y
xcopy "$build_dir\nirvana\library\Mock\Debug\libmockimport.a" "$core_lib_dir\Debug\" /y
