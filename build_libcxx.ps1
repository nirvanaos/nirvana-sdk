$llvm_root = "./llvm-project"
$build_dir = "./build"
cmake -G Ninja -S "$llvm_root/runtimes" -B $build_dir -DLLVM_ENABLE_PROJECTS="clang" `
    -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi"