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
	$system = "windows-gnu"
}

switch ($platform) {
	"x64" {
		$arch = "x86_64"
		$arch_folder = "x86_64"
	}
	"x86" {
		$arch = "i686"
		$arch_folder = "x86"
	}
	default {
		Write-Host "Unknown platform"
		Exit -1
	}
}

$dest_dir = "$sdk_dir\lib\$platform\$config"
$build_dir = "$PWD\build\$platform\libm\$config"
$libm_root = "$PWD\openlibm"
$platform_inc = "$sdk_dir\include\clang"
$nirvana_dir = "$PWD\nirvana"

$triple = "$arch-$system"
$lib_name = "openlibm.lib"

$include="$platform_inc;$nirvana_dir\library\include;$nirvana_dir\library\include\CRTL;$nirvana_dir\orb\include"
$c_flags = "-Wno-reserved-identifier" +
" -fno-ms-compatibility" + 
" -fno-ms-extensions" +
" -nostdinc" +
" --target=$triple"

$args = "-G Ninja -S ""$libm_root"" -B ""$build_dir"" --toolchain ""$PWD\toolchain.cmake"""  +
"	-DBUILD_SHARED_LIBS=OFF" +
" -DCMAKE_SYSTEM_NAME=Generic" +
" -DCMAKE_BUILD_TYPE=$config" +
#" -DCMAKE_MT=mt" +
" -DCMAKE_C_FLAGS=""$c_flags""" +
" -DCMAKE_STATIC_LIBRARY_PREFIX_C=""""" +
" -DCMAKE_STATIC_LIBRARY_SUFFIX_C=.lib" +
" -DOPENLIBM_ARCH_FOLDER=""$arch_folder""" +
" -DOPENLIBM_INCLUDE_DIRS=""$include""" +
" -DOPENLIBM_SUPPRESS_WARNINGS=ON"

#Write-Host "$args"
$process = Start-Process cmake -NoNewWindow -PassThru -Wait -ArgumentList $args
if (0 -ne $process.ExitCode) {
  exit $process.ExitCode
}

cmake --build $build_dir

if (!(Test-Path $dest_dir)) {
	mkdir $dest_dir
}

Copy-Item "$build_dir\$lib_name" "$dest_dir\libm.lib" -Force
