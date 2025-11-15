if ($args.count -ge 1) {
	$platform = $args[0]
} else {
	$platform = "x64"
}

$sdk_dir = "$PWD\out\sdk"
$llvm_root = "$PWD\llvm-project"
$build_dir = "$PWD\build\compiler-rt\$platform"
$dest_dir = "$sdk_dir\lib\$platform"

# -DCRT_CFLAGS
# Tell the SDK toolchain about the target platform.
$Env:NIRVANA_TARGET_PLATFORM = "$platform"

cmake -G "Ninja Multi-Config" -S "$llvm_root\compiler-rt" -B $build_dir --toolchain "$PWD\toolchain.cmake" `
 -DBUILD_SHARED_LIBS=OFF                              `
 -DCMAKE_INSTALL_PREFIX="$dest_dir"                   `
 -DCOMPILER_RT_BAREMETAL_BUILD=ON                     `
 -DCOMPILER_RT_BUILTINS_ENABLE_PIC=OFF                `
 -DCOMPILER_RT_INSTALL_LIBRARY_DIR="$dest_dir/$<CONFIG>" `
 -DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON                `
 -DCOMPILER_RT_USE_LLVM_UNWINDER=ON                   `
 -DCOMPILER_RT_ENABLE_STATIC_UNWINDER=ON              `
 -DSANITIZER_USE_STATIC_CXX_ABI=ON                    `
 -DSANITIZER_USE_STATIC_LLVM_UNWINDER=ON              `
 -DCRT_CFLAGS="-U_WIN32"                              `
 -DCMAKE_SYSTEM_NAME=Generic

$Env:NIRVANA_TARGET_PLATFORM = ""

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

cmake --install $build_dir --config Debug
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

cmake --install $build_dir --config Release
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
