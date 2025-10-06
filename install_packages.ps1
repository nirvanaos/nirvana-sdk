$ErrorActionPreference = "Stop"
$core_sdk_dir = "$PWD\out\core-sdk\windows"
$tools_dir = "$PWD\out\tools\windows"

if ($args.count -ge 1) {
	$platform = $args[0]
} else {
	$platform = "x64"
}

switch ($platform) {
	"x64" {
		$vcpkg_triplet = "x64-windows"
	}
	"x86" {
		$vcpkg_triplet = "x86-windows"
	}
	default {
		Write-Host "Unknown platform"
		Exit -1
	}
}

$install_root = "$PWD\build\$platform\vcpkg_installed"
vcpkg install --triplet=$vcpkg_triplet --x-install-root="$install_root"

xcopy "$install_root\$vcpkg_triplet\lib\mockhost.lib" "$core_sdk_dir\lib\$platform\Release\" /y
xcopy "$install_root\$vcpkg_triplet\debug\lib\mockhost.lib" "$core_sdk_dir\lib\$platform\Debug\" /y

xcopy "$install_root\$vcpkg_triplet\bin\mockhost.dll" "$core_sdk_dir\bin\$platform\Release\" /y
xcopy "$install_root\$vcpkg_triplet\debug\bin\mockhost.dll" "$core_sdk_dir\bin\$platform\Debug\" /y

xcopy "$install_root\$vcpkg_triplet\tools\nidl2cpp\nidl2cpp.exe" "$tools_dir\$platform\" /y
