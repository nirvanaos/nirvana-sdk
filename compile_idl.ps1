$ErrorActionPreference = "Stop"

$build_dir = "$PWD\build\compile_idl"

cmake -G Ninja -S . -B $build_dir --toolchain "$PWD\toolchain.cmake" -DNIRVANA_BUILD=OFF
cmake --build $build_dir
