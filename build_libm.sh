set -e

dest_dir="$PWD/sdk"
build_dir="$PWD/build/libm"
libm_root="$PWD/openlibm"

cmake -G Ninja -S "$libm_root" -B $build_dir
cmake --build $build_dir
