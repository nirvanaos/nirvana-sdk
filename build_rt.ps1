$ErrorActionPreference = "Stop"
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
# -DCOMPILER_RT_COMMON_CFLAGS
# Tell the SDK toolchain about the target platform.
$Env:NIRVANA_TARGET_PLATFORM = "$platform"

cmake -G "Ninja Multi-Config" -S "$llvm_root\compiler-rt" -B $build_dir --toolchain "$PWD\toolchain.cmake" `
 -DBUILD_SHARED_LIBS=OFF                              `
 -DCOMPILER_RT_BAREMETAL_BUILD=ON                     `
 -DCOMPILER_RT_BUILD_BUILTINS=ON                      `
 -DCOMPILER_RT_BUILD_LIBFUZZER=OFF                    `
 -DCOMPILER_RT_BUILD_MEMPROF=OFF                      `
 -DCOMPILER_RT_BUILD_PROFILE=OFF                      `
 -DCOMPILER_RT_BUILD_CTX_PROFILE=OFF                  `
 -DCOMPILER_RT_BUILD_SANITIZERS=OFF                   `
 -DCOMPILER_RT_BUILD_XRAY=OFF                         `
 -DCOMPILER_RT_BUILD_ORC=OFF                          `
 -DCOMPILER_RT_BUILD_CRT=OFF                          `
 -DCOMPILER_RT_BUILTINS_ENABLE_PIC=OFF                `
 -DCOMPILER_RT_COMMON_CFLAGS="-U_WIN32"               `
 -DCOMPILER_RT_CXX_LIBRARY="libcxx"                   `
 -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON                 `
 -DCOMPILER_RT_ENABLE_STATIC_UNWINDER=ON              `
 -DCOMPILER_RT_INSTALL_PATH="$build_dir/install"      `
 -DCOMPILER_RT_INSTALL_LIBRARY_DIR="$dest_dir/$<CONFIG>" `
 -DCOMPILER_RT_STATIC_CXX_LIBRARY=ON                  `
 -DCOMPILER_RT_USE_ATOMIC_LIBRARY=ON                  `
 -DCOMPILER_RT_USE_BUILTINS_LIBRARY=ON                `
 -DCOMPILER_RT_USE_LLVM_UNWINDER=ON                   `
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
Move-Item -Path "$dest_dir\Debug\libclang_rt.builtins-*.a" -Destination "$dest_dir\Debug\libclang_rt.builtins.a" -Force
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

cmake --install $build_dir --config Release
Move-Item -Path "$dest_dir\Release\libclang_rt.builtins-*.a" -Destination "$dest_dir\Release\libclang_rt.builtins.a" -Force
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
