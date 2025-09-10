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
$build_dir = "$PWD\build\$platform\libcxx\$config"
$llvm_root = "$PWD\llvm-project"

$common_flags = "-Wno-user-defined-literals;" +
"-Wno-covered-switch-default;" +
"-Wno-typedef-redefinition;" +
"-Wno-nullability-completeness;" +
"-Wno-covered-switch-default;" +
"-Wno-unused-function"

$cpp_with_containers = $common_flags + ";-includeNirvana/force_include.h;-fno-ms-compatibility;-fno-ms-extensions"

# If we keep _WIN32 defined in libc++ it includes Windows.h and other Windows stuff.
# We mustn't depend on any Windows things so we undefine _WIN32 in libc++.
# Do not undefine _WIN64 because this breaks the code.
#$cxx_flags = $cpp_with_containers + ";-U_WIN32;-D__FreeBSD__"
$cxx_flags = $cpp_with_containers + ";-U_WIN32"

$extra_defines = "_LIBCPP_HAS_CLOCK_GETTIME"

# If we undefine _WIN32 in libc++abi it uses wrong calling convention.
# So we keep _WIN32 defined in libc++abi build.
$cxxabi_flags = $cpp_with_containers

# Tell the SDK toolchain about the target platform.
$Env:NIRVANA_TARGET_PLATFORM = "$platform"

cmake -G Ninja -S "$llvm_root\runtimes" -B $build_dir --toolchain "$PWD\toolchain.cmake" `
 -DBUILD_SHARED_LIBS=OFF                              `
 -DCMAKE_BUILD_TYPE="$config"                         `
 -DCMAKE_CXX_STANDARD="20"                            `
 -DCMAKE_INSTALL_PREFIX="$dest_dir"                   `
 -DCMAKE_PREFIX_PATH="$tools_dir"                     `
 -DCMAKE_POLICY_DEFAULT_CMP0177=NEW                   `
 -DCMAKE_SYSTEM_NAME=Generic                          `
 -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi"            `
 -D_LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS=ON          `
 -DLIBCXX_ABI_FORCE_ITANIUM=ON                        `
 -DLIBCXX_ABI_VERSION=2                               `
 -DLIBCXX_ADDITIONAL_COMPILE_FLAGS="$cxx_flags"       `
 -DLIBCXX_CXX_ABI="libcxxabi"                         `
 -DLIBCXX_ENABLE_FILESYSTEM=OFF                       `
 -DLIBCXX_ENABLE_MONOTONIC_CLOCK=ON                   `
 -DLIBCXX_ENABLE_SHARED=OFF                           `
 -DLIBCXX_ENABLE_STATIC=ON                            `
 -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON                `
 -DLIBCXX_EXTRA_SITE_DEFINES="$extra_defines"         `
 -DLIBCXX_HAS_EXTERNAL_THREAD_API=ON                  `
 -DLIBCXX_HERMETIC_STATIC_LIBRARY=ON                  `
 -DLIBCXX_INSTALL_LIBRARY_DIR="$dest_dir"             `
 -DLIBCXX_INSTALL_HEADERS=OFF                         `
 -DLIBCXX_INSTALL_MODULES=OFF                         `
 -DLIBCXX_NO_VCRUNTIME=1                              `
 -DLIBCXX_SHARED_OUTPUT_NAME="c++-shared"             `
 -DLIBCXX_TYPEINFO_COMPARISON_IMPLEMENTATION=1        `
 -DLIBCXXABI_ADDITIONAL_COMPILE_FLAGS="$cxxabi_flags" `
 -DLIBCXXABI_ENABLE_SHARED=OFF                        `
 -DLIBCXXABI_HAS_EXTERNAL_THREAD_API=ON               `
 -DLIBCXXABI_HERMETIC_STATIC_LIBRARY=ON               `
 -DLIBCXXABI_INSTALL_LIBRARY_DIR="$dest_dir"          `
 -DLIBCXXABI_INSTALL_HEADERS=OFF                      `
 -DLIBCXXABI_SHARED_OUTPUT_NAME="c++abi-shared"       `
 -DLIBCXXABI_USE_LLVM_UNWINDER=ON                     `
 -DLIBUNWIND_WEAK_PTHREAD_LIB=ON

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

cmake --build $build_dir

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

cmake --install $build_dir
exit $LASTEXITCODE
