$ErrorActionPreference = "Stop"

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
	$system = "windows-gnu"
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

$build_dir = "$PWD\build\$platform\nirvana\$config"

cmake -G Ninja -S . -B $build_dir --toolchain "$PWD\toolchain.cmake" -DNIRVANA_BUILD=OFF
cmake --build $build_dir
