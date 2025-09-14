$ErrorActionPreference = "Stop"
$sdk_dir = "$PWD\out\sdk"

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
$nirvana_dir = "$PWD\nirvana"

$common_flags = "-Wno-user-defined-literals;" +
"-Wno-covered-switch-default;" +
"-Wno-typedef-redefinition;" +
"-Wno-nullability-completeness;" +
"-Wno-covered-switch-default;" +
"-Wno-unused-function"

$cpp_with_containers = $common_flags + ";-includeNirvana/force_include.h"

# If we keep _WIN32 defined in libc++ it includes Windows.h and other Windows stuff.
# We mustn't depend on any Windows things so we undefine _WIN32 in libc++.
# Do not undefine _WIN64 because this breaks the code.
#$cxx_flags = $cpp_with_containers + ";-U_WIN32;-D__FreeBSD__"
$cxx_flags = $cpp_with_containers + ";-U_WIN32"

$extra_defines = "_LIBCPP_HAS_CLOCK_GETTIME"

# Windows flags
# For x86 we use SJLJ exceptions. For other platforms - SEH.
if ($platform -ne "x86") {

  $win_sdk_inc_dir = "${env:WindowsSdkDir}Include\${env:WindowsSDKVersion}"
  $msvc_inc_dir = "${env:VCToolsInstallDir}include"

  $win_inc = "-isystem${msvc_inc_dir};" +
  "-isystem${win_sdk_inc_dir}um;" +
  "-isystem${win_sdk_inc_dir}shared"

  $windows_flags = ";-fms-compatibility;-fms-extensions;-fms-compatibility-version=19.44.35215;" +
  "-D_MSC_FULL_VER=194435215;-D_MSC_VER=1944;" +
  "-D_MSVC_LANG=__cplusplus;-D_MSC_EXTENSIONS=1;" +
  "-Wno-nonportable-include-path;-Wno-switch;" +
  "$win_inc"

  if ($platform -eq "x64") {
    $arch = ";-D_M_AMD64;-D_M_X64"
  } elseif ($platform -eq "x86") {
    $arch = ";-D_M_IX86;-D_INTEGRAL_MAX_BITS=64"
  } elseif ($platform -eq "arm") {
    $arch = ";-D_M_ARM"
  } elseif ($platform -eq "arm64") {
    $arch = ";-D_M_ARM64"
  }

  $windows_flags += $arch
} else {
  $windows_flags = ""
}

# If we undefine _WIN32 in libc++abi it uses wrong calling convention.
# So we keep _WIN32 defined in libc++abi build.
$cxxabi_flags = $cpp_with_containers + $windows_flags

$unwind_flags += $common_flags + $windows_flags + ";-D_LIBUNWIND_REMEMBER_STACK_ALLOC;-Wno-format"

# Tell the SDK toolchain about the target platform.
$Env:NIRVANA_TARGET_PLATFORM = "$platform"

cmake -G Ninja -S "$llvm_root\runtimes" -B $build_dir --toolchain "$PWD\toolchain.cmake" `
 -DBUILD_SHARED_LIBS=OFF                              `
 -DCMAKE_BUILD_TYPE="$config"                         `
 -DCMAKE_CXX_STANDARD="20"                            `
 -DCMAKE_INSTALL_PREFIX="$dest_dir"                   `
 -DCMAKE_POLICY_DEFAULT_CMP0177=NEW                   `
 -DCMAKE_SYSTEM_NAME=Generic                          `
 -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind"  `
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
 -DLIBCXX_INSTALL_INCLUDE_DIR="$build_dir/include/c++" `
 -DLIBCXX_INSTALL_INCLUDE_TARGET_DIR="$build_dir/include/c++" `
 -DLIBCXX_INSTALL_LIBRARY_DIR="$dest_dir"             `
 -DLIBCXX_INSTALL_HEADERS=ON                          `
 -DLIBCXX_INSTALL_MODULES=OFF                         `
 -DLIBCXX_NO_VCRUNTIME=1                              `
 -DLIBCXX_SHARED_OUTPUT_NAME="c++-shared"             `
 -DLIBCXX_TYPEINFO_COMPARISON_IMPLEMENTATION=1        `
 -DLIBCXXABI_ADDITIONAL_COMPILE_FLAGS="$cxxabi_flags" `
 -DLIBCXXABI_ENABLE_SHARED=OFF                        `
 -DLIBCXXABI_HAS_EXTERNAL_THREAD_API=ON               `
 -DLIBCXXABI_HERMETIC_STATIC_LIBRARY=ON               `
 -DLIBCXXABI_INSTALL_LIBRARY_DIR="$dest_dir"          `
 -DLIBCXXABI_INSTALL_INCLUDE_DIR="$build_dir/include/c++abi" `
 -DLIBCXXABI_INSTALL_INCLUDE_TARGET_DIR="$build_dir/include/c++abi" `
 -DLIBCXXABI_INSTALL_HEADERS=ON                       `
 -DLIBCXXABI_SHARED_OUTPUT_NAME="c++abi-shared"       `
 -DLIBCXXABI_USE_LLVM_UNWINDER=ON                     `
 -DLIBUNWIND_ADDITIONAL_COMPILE_FLAGS="$unwind_flags" `
 -DLIBUNWIND_ENABLE_SHARED=OFF                        `
 -DLIBUNWIND_ENABLE_STATIC=ON                         `
 -DLIBUNWIND_ENABLE_THREADS=ON                        `
 -DLIBUNWIND_HIDE_SYMBOLS=ON                          `
 -DLIBUNWIND_INSTALL_LIBRARY_DIR="$dest_dir"          `
 -DLIBUNWIND_INSTALL_INCLUDE_DIR="$build_dir/include/unwind" `
 -DLIBUNWIND_INSTALL_HEADERS=OFF                      `
 -DLIBUNWIND_IS_BAREMETAL=ON                          `
 -DLIBUNWIND_SHARED_OUTPUT_NAME="unwind-shared"       `
 -DLIBUNWIND_USE_COMPILER_RT=ON                       `
 -D_LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS=ON          `
 -DLIBUNWIND_WEAK_PTHREAD_LIB=ON

$Env:NIRVANA_TARGET_PLATFORM = ""

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

cmake --build $build_dir
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

cmake --install $build_dir
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

# For SEH we need Kernel32 library
if ($platform -ne "x86") {
  xcopy "${env:WindowsSdkDir}Lib\${env:WindowsSDKLibVersion}um\$platform\kernel32.Lib" "$sdk_dir\lib\$platform\" /y /f
}
