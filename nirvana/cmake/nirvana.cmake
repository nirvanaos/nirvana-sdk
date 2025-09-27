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

set (CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set (CMAKE_CXX_COMPILER ${llvm_bin}/clang++.exe)
set (CMAKE_C_COMPILER ${llvm_bin}/clang.exe)
set (CMAKE_ASM_COMPILER ${llvm_bin}/clang.exe)
set (CMAKE_RC_COMPILER ${llvm_bin}/llvm-rc.exe)
set (CMAKE_LINKER ${llvm_bin}/lld-link.exe)

set (CMAKE_CXX_STANDARD_LIBRARIES "")
set (CMAKE_SYSTEM_NAME Generic)

list (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")
include (NirvanaTargetPlatform)

set (c_compile_flags "-nostdinc -fshort-wchar -fdwarf-exceptions -mlong-double-64\
 -fno-ms-compatibility -fno-ms-extensions -U_WIN32 -U__MINGW__ -U__MINGW32__ -U__MINGW64__\
 -Wno-character-conversion --target=${NIRVANA_TARGET_TRIPLE}"
)

if (${NIRVANA_TARGET_PLATFORM} STREQUAL "x64")
	string (CONCAT c_compile_flags ${c_compile_flags} " -mlzcnt -m64 -msse2 -mfpmath=sse")
elseif (${NIRVANA_TARGET_PLATFORM} STREQUAL "x86")
	string (CONCAT c_compile_flags ${c_compile_flags} " -m32 -msse2 -mfpmath=sse")
endif ()

string (CONCAT cpp_compile_flags ${c_compile_flags} " -fsized-deallocation")

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

file (TO_CMAKE_PATH $ENV{NIRVANA_SDK} NIRVANA_SDK_DIR)
include_directories (SYSTEM
	${NIRVANA_SDK_DIR}/include/c++/v1
  "${llvm}/${clang_lib}/include"
	${NIRVANA_SDK_DIR}/include
)

set (NIRVANA_LINK_FLAGS "/incremental:no /opt:ref /nodefaultlib /debug:dwarf /section:olfbind,r\
 /machine:${NIRVANA_TARGET_PLATFORM}")

if (${NIRVANA_TARGET_PLATFORM} STREQUAL "x86")
  string (CONCAT NIRVANA_LINK_FLAGS ${NIRVANA_LINK_FLAGS} " /safeseh:no")
endif ()

add_link_options (-fuse-ld=lld -nodefaultlibs
"LINKER:SHELL:/incremental:no /opt:ref /nodefaultlib /noimplib /section:olfbind,r /merge:.eh_frame=.rdata\
 /machine:${NIRVANA_TARGET_PLATFORM} /libpath:'${NIRVANA_SDK_DIR}/lib/${NIRVANA_TARGET_PLATFORM}/$<CONFIG>'")

#link_directories ("${NIRVANA_SDK_DIR}/lib/${NIRVANA_TARGET_PLATFORM}/$<CONFIG>")

if (${NIRVANA_TARGET_PLATFORM} STREQUAL "x86")
  add_link_options ("LINKER:/safeseh:no")
endif ()

add_link_options ("$<$<CONFIG:Debug>:LINKER:/debug:dwarf>")

set (NIRVANA_STANDARD_LIBRARIES "-lc++ -lc++experimental -lc++abi -lcrtl -lnirvana -lm -lunwind")
set (CMAKE_C_STANDARD_LIBRARIES ${NIRVANA_STANDARD_LIBRARIES})
set (CMAKE_CXX_STANDARD_LIBRARIES ${NIRVANA_STANDARD_LIBRARIES})
