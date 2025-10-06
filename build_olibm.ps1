$ErrorActionPreference = "Stop"
$sdk_dir = "$PWD\out\sdk"
$tools_dir = "$PWD\out\tools-windows-x64"

if ($args.count -ge 1) {
	$platform = $args[0]
} else {
	$platform = "x64"
}

$dest_dir = "$sdk_dir\lib\$platform"
$build_dir = "$PWD\build\libm\$platform"
$libm_root = "$PWD\openlibm"
$nirvana_dir = "$PWD\nirvana"

$c_flags = "-Wno-reserved-identifier"

$Env:NIRVANA_TARGET_PLATFORM = "$platform"

cmake -G "Ninja Multi-Config" -S "$libm_root" -B $build_dir --toolchain "$PWD\toolchain.cmake" `
 -DBUILD_SHARED_LIBS=OFF                `
 -DCMAKE_SYSTEM_NAME=Generic            `
 -DC_ASM_COMPILE_FLAGS="$c_flags"       `
 -DOPENLIBM_SUPPRESS_WARNINGS=ON

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

cmake --build $build_dir --config Debug
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

cmake --build $build_dir --config Release
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

$lib_name = "libopenlibm.a"

if (!(Test-Path "$dest_dir\Debug")) {
	mkdir $dest_dir\Debug
}
Copy-Item "$build_dir\Debug\$lib_name" "$dest_dir\Debug\libm.a" -Force

if (!(Test-Path "$dest_dir\Release")) {
	mkdir $dest_dir\Release
}
Copy-Item "$build_dir\Release\$lib_name" "$dest_dir\Release\libm.a" -Force
