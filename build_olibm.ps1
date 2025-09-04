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
if ($args.count -ge 3) {
	$system = $args[2]
} else {
#	$system = "pc-win32"
	$system = "unknown-windows-gnu"
}

switch ($platform) {
	"x64" {
		$arch = "x86_64"
	}
	"x86" {
		$arch = "i686"
	}
	default {
		Write-Host "Unknown platform"
		Exit -1
	}
}

$dest_dir = "$sdk_dir\lib\$platform\$config"
$build_dir = "$PWD\build\$platform\libm\$config"
$libm_root = "$PWD\openlibm"
$nirvana_dir = "$PWD\nirvana"

$triple = "$arch-$system"
$lib_name = "openlibm.lib"

$c_flags = "-Wno-reserved-identifier;--target=$triple"

cmake -G Ninja -S "$libm_root" -B $build_dir --toolchain "$PWD\toolchain.cmake" `
 -DBUILD_SHARED_LIBS=OFF                `
 -DCMAKE_SYSTEM_NAME=Generic            `
 -DCMAKE_SYSTEM_PROCESSOR="$arch"       `
 -DCMAKE_BUILD_TYPE="$config"           `
 -DC_ASM_COMPILE_FLAGS="$c_flags"       `
 -DCMAKE_STATIC_LIBRARY_PREFIX_C=""     `
 -DCMAKE_STATIC_LIBRARY_SUFFIX_C=".lib" `
 -DOPENLIBM_SUPPRESS_WARNINGS=ON

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

cmake --build $build_dir

if (!(Test-Path $dest_dir)) {
	mkdir $dest_dir
}

Copy-Item "$build_dir\$lib_name" "$dest_dir\libm.lib" -Force
