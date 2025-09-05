$ErrorActionPreference = "Stop"
$sdk_dir = "$PWD\out\sdk"
$tools_dir = "$PWD\out\tools-windows-x64"

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

$dest_dir = "$sdk_dir\lib\$platform\$config"
$build_dir = "$PWD\build\$platform\libm\$config"
$libm_root = "$PWD\openlibm"
$nirvana_dir = "$PWD\nirvana"

$c_flags = "-Wno-reserved-identifier"

$Env:NIRVANA_TARGET_PLATFORM = "$platform"

cmake -G Ninja -S "$libm_root" -B $build_dir --toolchain "$PWD\toolchain.cmake" `
 -DBUILD_SHARED_LIBS=OFF                `
 -DCMAKE_SYSTEM_NAME=Generic            `
 -DCMAKE_BUILD_TYPE="$config"           `
 -DC_ASM_COMPILE_FLAGS="$c_flags"       `
 -DOPENLIBM_SUPPRESS_WARNINGS=ON

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

cmake --build $build_dir

if (!(Test-Path $dest_dir)) {
	mkdir $dest_dir
}

$lib_name = "libopenlibm.a"
Copy-Item "$build_dir\$lib_name" "$dest_dir\libm.a" -Force
