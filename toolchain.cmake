# Nirvana SDK build CMake toolchain file

set (clang_lib lib/clang/21) # Required CLang version

set (llvm $ENV{LLVM_PATH})

if (NOT EXISTS "${llvm}/${clang_lib}")
  message (FATAL_ERROR "CLang 21 not found")
endif ()

cmake_path (NORMAL_PATH llvm)
set (llvm_bin ${llvm}/bin)
find_program (CLANG "clang++" PATHS ${llvm_bin})
if (NOT CLANG)
  message (FATAL_ERROR "CLang compiler not found in " ${llvm_bin})
endif ()

set (CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/nirvana/cmake")
include (NirvanaTargetPlatform)
set (LLVM_DEFAULT_TARGET_TRIPLE ${NIRVANA_TARGET_TRIPLE} CACHE STRING "" FORCE)

# Do not undefine _WIN64 because this breaks the unwind code

set (c_compile_flags "-nostdinc -fshort-wchar -mlong-double-80 -fdwarf-exceptions\
 -Wno-character-conversion\
 -U__MINGW__ -U__MINGW32__ -U__MINGW64__\
 --target=${NIRVANA_TARGET_TRIPLE}"
)

if (${NIRVANA_TARGET_PLATFORM} STREQUAL "x64")
	string (CONCAT c_compile_flags ${c_compile_flags} " -mlzcnt -m64 -msse2 -mfpmath=sse")
elseif (${NIRVANA_TARGET_PLATFORM} STREQUAL "x86")
	string (CONCAT c_compile_flags ${c_compile_flags} " -m32 -msse2 -mfpmath=sse")
endif ()

set (LLVM_DIR "${llvm}/lib/cmake/llvm")
set (Clang_DIR "${llvm}/lib/cmake/clang")

set (CMAKE_CXX_COMPILER ${llvm_bin}/clang++.exe)
set (CMAKE_C_COMPILER ${llvm_bin}/clang.exe)
set (CMAKE_ASM_COMPILER ${llvm_bin}/clang.exe)

string (CONCAT cpp_compile_flags ${c_compile_flags} " -nostdinc++ -fsized-deallocation")

set (CMAKE_CXX_FLAGS_INIT ${cpp_compile_flags})
set (CMAKE_C_FLAGS_INIT ${c_compile_flags})
set (CMAKE_ASM_FLAGS_INIT ${c_compile_flags})

set (debug_flags "-gdwarf-4")
#set (debug_flags "-gcodeview")
set (release_flags "-fno-builtin")

set (CMAKE_CXX_FLAGS_DEBUG_INIT ${debug_flags})
set (CMAKE_C_FLAGS_DEBUG_INIT ${debug_flags})
set (CMAKE_ASM_FLAGS_DEBUG_INIT ${debug_flags})

set (CMAKE_CXX_FLAGS_RELEASE_INIT ${release_flags})
set (CMAKE_C_FLAGS_RELEASE_INIT ${release_flags})

include_directories (SYSTEM
  "${llvm}/${clang_lib}/include"
	"${CMAKE_CURRENT_LIST_DIR}/nirvana/library/CRTL/Include"
	"${CMAKE_CURRENT_LIST_DIR}/out/sdk/include"
	"${CMAKE_CURRENT_LIST_DIR}/nirvana/library/Include"
	"${CMAKE_CURRENT_LIST_DIR}/build/nirvana/library/Include"
	"${CMAKE_CURRENT_LIST_DIR}/nirvana/orb/Include"
	"${CMAKE_CURRENT_LIST_DIR}/build/nirvana/orb/Include"
)

set (CMAKE_RC_COMPILER ${llvm_bin}/llvm-rc.exe)
set (CMAKE_LINKER ${llvm_bin}/lld-link.exe)
set (CMAKE_CXX_STANDARD_LIBRARIES "")
