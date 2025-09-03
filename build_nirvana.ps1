$ErrorActionPreference = "Stop"
$sdk_dir = "$PWD\out\sdk"
$core_sdk_dir = "$PWD\out\core-sdk\windows"

if ($args.count -ge 1) {
	$platform = $args[0]
} else {
	$platform = "x64"
}
if ($args.count -ge 2) {
	$config = $args[1]
} else {
	$config = "Debug"
}
if ($args.count -ge 3) {
	$system = $args[2]
} else {
	$system = "unknown-windows-gnu"
}

switch ($platform) {
	"x64" {
		$arch = "x86_64"
		$vcpkg_triplet = "x64-windows"
	}
	"x86" {
		$arch = "i686"
		$vcpkg_triplet = "x86-windows"
	}
	default {
		Write-Host "Unknown platform"
		Exit -1
	}
}

$lib_dir = "$sdk_dir\lib\$platform"
$build_dir = "$PWD\build\$platform\nirvana\$config"
$triple = "$arch-$system"

${Env:CMAKE_PREFIX_PATH}="$PWD\build\$platform\vcpkg_installed\$vcpkg_triplet\share"

cmake -G Ninja -S . -B $build_dir --toolchain "$PWD\toolchain.cmake" `
 -DCMAKE_BUILD_TYPE="$config"                         `
 -DCMAKE_SYSTEM_PROCESSOR="$platform"                 `
 -DNIRVANA_LIB_DIR="$lib_dir"                         `
 -DNIRVANA_IDL=ON                                     `
 -DNIRVANA_BUILD=ON                                   `
 -DBUILD_TESTING=ON

cmake --build $build_dir

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

#ctest --test-dir "$build_dir"

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

$dest_dir = "$lib_dir\$config"

xcopy "$build_dir\nirvana\nirvana.lib" "$dest_dir\" /y
xcopy "$build_dir\nirvana\library\CoreImport\coreimport.lib" "$dest_dir\" /y
xcopy "$build_dir\nirvana\library\CRTL\crtl.lib" "$dest_dir\" /y
xcopy "$build_dir\googletest\googletest-nirvana.lib" "$dest_dir\" /y

$core_lib_dir = "$core_sdk_dir\lib\$platform\$config"

xcopy "$build_dir\nirvana\library\CRTL\impl\win\crtl-main.lib" "$core_lib_dir\" /y
xcopy "$build_dir\nirvana\library\Mock\mockimport.lib" "$core_lib_dir\" /y
