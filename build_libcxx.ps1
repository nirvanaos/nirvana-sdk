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

$dest_dir = "$sdk_dir\lib\$platform\$config"
$build_dir = "$PWD\build\$platform\libcxx\$config"
$llvm_root = "$PWD\llvm-project"
$platform_inc = "$sdk_dir\include\clang"
$nirvana_dir = "$PWD\nirvana"
$triple = "$arch-$system"

$c_flags = "-nostdinc -fshort-wchar -fsized-deallocation" +
" -Wno-user-defined-literals" +
" -Wno-covered-switch-default" +
" -Wno-typedef-redefinition" +
" -Wno-nonportable-include-path" +
" -Wno-nullability-completeness" +
" -Wno-covered-switch-default" +
" -Wno-unused-function" +
" -fno-ms-compatibility" +
" -fno-ms-extensions" +
" -fsjlj-exceptions" +
" --target=$triple" +
" -I`"$platform_inc`"" +
" -I`"$PWD\nirvana\library\include\CRTL`"" +
" -I`"$sdk_dir\include`"" +
" -I`"$PWD\nirvana\library\include`"" +
" -I`"$PWD\build\nirvana\library\include`"" +
" -I`"$PWD\nirvana\orb\include`"" +
" -I`"$PWD\build\nirvana\orb\include`"" +
" -D_NATIVE_WCHAR_T_DEFINED"

$extra_defines = "_LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS;" +
"_LIBCPP_HAS_CLOCK_GETTIME"

$cxx_flags = "-includeNirvana/force_include.h;-U_WIN32;-U__MINGW32__;-Wno-cast-qual"

$cxxabi_flags = "-U_WIN32;-U__MINGW32__;-D_LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS"
$unwind_flags = "-Wno-format;-Wno-gnu-include-next;-D_LIBUNWIND_REMEMBER_STACK_ALLOC"

cmake -G Ninja -S "$llvm_root\runtimes" -B $build_dir --toolchain "$PWD\toolchain.cmake" `
 -DBUILD_SHARED_LIBS=OFF                              `
 -DCMAKE_BUILD_TYPE="$config"                         `
 -DCMAKE_C_FLAGS="$c_flags"                           `
 -DCMAKE_C_FLAGS_DEBUG="-gdwarf-4"                    `
 -DCMAKE_C_FLAGS_RELEASE="-fno-builtin"               `
 -DCMAKE_CXX_FLAGS="$c_flags"                         `
 -DCMAKE_CXX_FLAGS_DEBUG="-gdwarf-4"                  `
 -DCMAKE_CXX_FLAGS_RELEASE="-fno-builtin"             `
 -DCMAKE_CXX_STANDARD="20"                            `
 -DCMAKE_INSTALL_PREFIX="$dest_dir"                   `
 -DCMAKE_PREFIX_PATH="$tools_dir"                     `
 -DCMAKE_POLICY_DEFAULT_CMP0177=NEW                   `
 -DCMAKE_STATIC_LIBRARY_SUFFIX_C=".lib"               `
 -DCMAKE_STATIC_LIBRARY_SUFFIX_CXX=".lib"             `
 -DCMAKE_SYSTEM_NAME=Generic                          `
 -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind"  `
 -DLLVM_TARGET_TRIPLE="$triple"                       `
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
 -DLIBUNWIND_ADDITIONAL_COMPILE_FLAGS="$unwind_flags" `
 -DLIBUNWIND_ENABLE_SHARED=OFF                        `
 -DLIBUNWIND_ENABLE_STATIC=ON                         `
 -DLIBUNWIND_INSTALL_LIBRARY_DIR="$dest_dir"          `
 -DLIBUNWIND_INSTALL_HEADERS=OFF                      `
 -DLIBUNWIND_HIDE_SYMBOLS=ON                          `
 -DLIBUNWIND_SHARED_OUTPUT_NAME="unwind-shared"       `
 -DLIBUNWIND_USE_COMPILER_RT=ON                       `
 -D_LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS=ON          `
 -DLIBUNWIND_WEAK_PTHREAD_LIB=ON

cmake --build $build_dir

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

cmake --install $build_dir
exit $LASTEXITCODE
