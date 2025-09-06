$ErrorActionPreference = "Stop"

$build_dir = "$PWD\build\nirvana"

cmake -G Ninja -S . -B $build_dir --toolchain "$PWD\toolchain.cmake" -DNIRVANA_BUILD=OFF
cmake --build $build_dir
