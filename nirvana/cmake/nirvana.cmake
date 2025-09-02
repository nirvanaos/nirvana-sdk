# Nirvana CMake toolchain file

set (clang_lib lib/clang/21) # Required CLang version

set (llvm $ENV{LLVM_PATH})
if (NOT EXISTS "${llvm}/${clang_lib}")
  set (llvm $ENV{ProgramFiles}/LLVM)
  if (NOT EXISTS "${llvm}/lib/clang/21")
    message (FATAL_ERROR "Please, install LLVM from https://github.com/llvm/llvm-project/releases/download/llvmorg-21.1.0/LLVM-21.1.0-win64.exe")
  endif ()
endif ()

cmake_path (NORMAL_PATH llvm)
set (llvm_bin ${llvm}/bin)
find_program (CLANG "clang++" PATHS ${llvm_bin} REQUIRED)
if (NOT CLANG)
  message (FATAL_ERROR "CLang compiler not found in " ${llvm_bin})
endif ()

set (CMAKE_CXX_COMPILER ${llvm_bin}/clang++.exe)
set (CMAKE_CXX_COMPILER_WORKS ON)
set (CMAKE_C_COMPILER ${llvm_bin}/clang.exe)
set (CMAKE_C_COMPILER_WORKS ON)
set (CMAKE_ASM_COMPILER ${llvm_bin}/clang.exe)
set (CMAKE_RC_COMPILER ${llvm_bin}/llvm-rc.exe)
set (CMAKE_CXX_STANDARD_LIBRARIES "")
set (CMAKE_SYSTEM_NAME Generic)
list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")
