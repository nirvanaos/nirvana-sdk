$llvm_url = "https://github.com/llvm/llvm-project.git"
$llvm_tag = "llvmorg-21.1.0"
$llvm_root = "./llvm-project"
if (!(Test-Path "$llvm_root\.git")) {
	git clone --branch $llvm_tag --depth 1 $llvm_url $llvm_root
}

cd $llvm_root
git pull --depth=1 $llvm_url $llvm_tag
cd ..
