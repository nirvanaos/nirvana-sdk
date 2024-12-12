if [[ $# -ge 1 ]]; then
	platform=$1
else
	platform="x64"
fi

if [[ $# -ge 2 ]]; then
	config=$2
else
	config="debug"
fi

set -e

dest_dir="$PWD/sdk"
build_dir="$PWD/build-libcxx-$platform-$config"
llvm_root="$PWD/llvm-project"
libc_config="$PWD/libc"

if [[ "$platform" == "x64" ]]; then
triple="x86_64-pc-none-elf"
cpu_features="AVX;AVX2;FMA;SSE2;SSE4_2"
else
triple="i686-pc-none-elf"
cpu_features="MMX;SSE"
fi

nirvana="$(pwd -W)/nirvana"

set -x

cpp_flags="-fsized-deallocation\
 --target=$triple\
 -I"$nirvana/library/Include"\
 -I"$nirvana/library/Include/CRTL"\
 -I"$nirvana/orb/Include"\
 -D_LIBCPP_PROVIDES_DEFAULT_RUNE_TABLE"

# -DLIBCXX_HAS_PTHREAD_API=ON                          \
# Threads are temporary disabled

# -DLIBCXXABI_ADDITIONAL_COMPILE_FLAGS="$cpp_flags"    \

cmake -G Ninja -S "$llvm_root/runtimes" -B $build_dir \
 -DCMAKE_C_COMPILER=clang                             \
 -DCMAKE_CXX_COMPILER=clang++                         \
 -DCMAKE_C_COMPILER_FORCED=ON                         \
 -DCMAKE_CXX_COMPILER_FORCED=ON                       \
 -DLLVM_ENABLE_LLD=OFF                                \
 -DLLVM_USE_LINKER="c:/0work/Nirvana/Work/sdk/sdk/windows/bin/ld.lld.exe" \
 -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind"  \
 -DCMAKE_INSTALL_PREFIX="$dest_dir"                   \
 -DLIBCXX_INSTALL_LIBRARY_DIR="$dest_dir/$config"     \
 -DLIBCXXABI_INSTALL_LIBRARY_DIR="$dest_dir/$config"  \
 -DLIBUNWIND_INSTALL_LIBRARY_DIR="$dest_dir/$config"  \
 -DCMAKE_STATIC_LIBRARY_SUFFIX_CXX="-$platform.a"     \
 -DCMAKE_STATIC_LIBRARY_SUFFIX_C="-$platform.a"       \
 -DLIBCXX_INSTALL_HEADERS=OFF                         \
 -DLIBCXX_ENABLE_SHARED=OFF                           \
 -DLIBCXXABI_ENABLE_SHARED=OFF                        \
 -DLIBUNWIND_ENABLE_SHARED=OFF                        \
 -DLIBUNWIND_HIDE_SYMBOLS=ON                          \
 -DLIBCXX_ENABLE_FILESYSTEM=OFF                       \
 -DCMAKE_CXX_FLAGS="$cpp_flags" \
 -DCMAKE_C_FLAGS="$cpp_flags" \
 -DLIBCXX_ENABLE_THREADS=OFF                          \
 -DLIBCXXABI_ENABLE_THREADS=OFF                       \
 -DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON                \
 -DLLVM_DEFAULT_TARGET_TRIPLE=$triple                 \
 -DCMAKE_SYSTEM_NAME=Generic

ninja -C $build_dir cxx cxxabi unwind
#ninja -C $build_dir check-cxx check-cxxabi check-unwind
ninja -C $build_dir install-cxx install-cxxabi install-unwind

#dest_path="$dest_dir/$config"
#mkdir -p $dest_path
#set -x
#cp "$build_dir/lib/libc++.a" "$dest_path/libc++-$platform.a"
#cp "$build_dir/lib/libc++abi.a" "$dest_path/libc++abi-$platform.a"
#cp "$build_dir/lib/libunwind.a" "$dest_path/libunwind-$platform.a"
