& "$PSScriptRoot\vsdevshell.ps1"

#dest_dir="$PWD/sdk"
$build_dir = "./build/libm"
$libm_root = "./openlibm"

cmake -G Ninja -S "$libm_root" -B $build_dir -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
cmake --build $build_dir
