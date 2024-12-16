& "$PSScriptRoot\vsdevshell.ps1"

$llvm_root = "./llvm-project"
$build_dir = "./build/llvm"
cmake -G Ninja -S "$llvm_root/llvm" -B $build_dir -DLLVM_ENABLE_PROJECTS="clang" `
    -DCMAKE_BUILD_TYPE=Release
#    -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi"

cmake --build $build_dir
#ninja -C $build_dir runtimes
#ninja -C $build_dir check-runtimes
#ninja -C $build_dir install-runtimes