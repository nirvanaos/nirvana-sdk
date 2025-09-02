$ErrorActionPreference = "Stop"
$sdk_dir = "$PWD\out\sdk"
$core_sdk_dir = "$PWD\out\core-sdk\windows"

if ($args.count -ge 1) {
	$platform = $args[0]
} else {
	$platform = "x64"
}

& "$PSScriptRoot\vsdevshell.ps1"

switch ($platform) {
	"x64" {
		$vcpkg_triplet = "x64-windows"
		Enter-VsDevShell -VsInstallPath:"$visualStudioPath" -SkipAutomaticLocation -HostArch amd64 -Arch amd64
	}
	"x86" {
		$vcpkg_triplet = "x86-windows"
		Enter-VsDevShell -VsInstallPath:"$visualStudioPath" -SkipAutomaticLocation -HostArch amd64 -Arch x86
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
