# Nirvana SDK build CMake toolchain file

set (clang_lib lib/clang/21) # Required CLang version

set (llvm $ENV{LLVM_PATH})
if (NOT EXISTS "${llvm}/${clang_lib}")
  set (llvm $ENV{ProgramFiles}/LLVM)
endif ()

if (NOT EXISTS "${llvm}/lib/clang/21")
  message (FATAL_ERROR "CLang 21 not found")
endif ()

cmake_path (NORMAL_PATH llvm)
set (llvm_bin ${llvm}/bin)
find_program (CLANG "clang++" PATHS ${llvm_bin})
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
