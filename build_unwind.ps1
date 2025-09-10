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
$build_dir = "$PWD\build\$platform\libunwind\$config"
$llvm_root = "$PWD\llvm-project"

$win_sdk_inc_dir = "${env:WindowsSdkDir}Include\${env:WindowsSDKVersion}"
$msvc_inc_dir = "${env:VCToolsInstallDir}include"

$win_inc = "-isystem${msvc_inc_dir};" +
"-isystem${win_sdk_inc_dir}um;" +
"-isystem${win_sdk_inc_dir}shared;" +
"-DWIN32_LEAN_AND_MEAN"

$c_flags = "-fms-compatibility;-fms-extensions;-fms-compatibility-version=19.44.35215;" +
"$win_inc;" +
"-D_MSC_FULL_VER=194435215;-D_MSC_VER=1944;-D_MSVC_LANG=__cplusplus;-D_MSC_EXTENSIONS=1;" +
"-D_M_HYBRID=0;" +
"-D_LIBUNWIND_REMEMBER_STACK_ALLOC;" +
"-D_LIBUNWIND_IS_NATIVE_ONLY;" +
"-D_LIBUNWIND_HAS_NO_THREADS;" +
"-D_LIBUNWIND_SUPPORT_SEH_UNWIND;"
# +
#"-D_LIBUNWIND_BUILD_SJLJ_APIS;"

if ($platform -eq "x64") {
  $arch = "-D_M_AMD64;-D_M_X64"
} elseif ($platform -eq "x86") {
  $arch = "-D_M_IX86"
} elseif ($platform -eq "arm") {
  $arch = "-D_M_ARM"
} elseif ($platform -eq "arm64") {
  $arch = "-D_M_ARM64"
}

$c_flags += "$arch;"

$c_flags += "-Wno-user-defined-literals;" + 
"-Wno-covered-switch-default;" +
"-Wno-typedef-redefinition;" +
"-Wno-nullability-completeness;" +
"-Wno-covered-switch-default;" +
"-Wno-unused-function;" +
"-Wno-format;" +
"-Wno-cast-qual;" +
"-Wno-language-extension-token;" +
"-Wno-reserved-macro-identifier;" +
"-Wno-reserved-identifier;" +
"-Wno-nonportable-include-path;" +
"-Wno-c++98-compat-extra-semi;" +
"-Wno-ignored-attributes;" +
"-Wno-non-virtual-dtor;" +
"-Wno-ignored-pragma-intrinsic;" +
"-Wno-unknown-pragmas;" +
"-Wno-c11-extensions;" +
"-Wno-pragma-pack"

# Tell the SDK toolchain about the target platform.
$Env:NIRVANA_TARGET_PLATFORM = "$platform"
# $Env:NIRVANA_CLANG_CL = "1"

# -DCMAKE_SYSTEM_NAME=Generic                          `

cmake -G Ninja -S "$llvm_root\runtimes" -B $build_dir --toolchain "$PWD\toolchain.cmake" `
 -DBUILD_SHARED_LIBS=OFF                              `
 -DCMAKE_BUILD_TYPE="$config"                         `
 -DCMAKE_CXX_STANDARD="20"                            `
 -DCMAKE_INSTALL_PREFIX="$dest_dir"                   `
 -DCMAKE_PREFIX_PATH="$tools_dir"                     `
 -DCMAKE_POLICY_DEFAULT_CMP0177=NEW                   `
 -DLLVM_ENABLE_RUNTIMES="libunwind"                   `
 -DLIBUNWIND_ADDITIONAL_COMPILE_FLAGS="$c_flags"      `
 -DLIBUNWIND_ENABLE_SHARED=OFF                        `
 -DLIBUNWIND_ENABLE_STATIC=ON                         `
 -DLIBUNWIND_INSTALL_LIBRARY_DIR="$dest_dir"          `
 -DLIBUNWIND_INSTALL_HEADERS=OFF                      `
 -DLIBUNWIND_HIDE_SYMBOLS=ON                          `
 -DLIBUNWIND_SHARED_OUTPUT_NAME="unwind-shared"       `
 -DLIBUNWIND_USE_COMPILER_RT=ON                       `
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
