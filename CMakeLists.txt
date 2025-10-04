cmake_minimum_required (VERSION 3.25)
set (CMAKE_CXX_SCAN_FOR_MODULES 0)
cmake_policy (SET CMP0010 NEW)
cmake_policy (SET CMP0053 NEW)
cmake_policy (SET CMP0071 NEW)

set (CMAKE_CXX_STANDARD 20)
set (CMAKE_CXX_STANDARD_REQUIRED ON)

set (CMAKE_C_STANDARD 11)
set (CMAKE_C_STANDARD_REQUIRED ON)

set (CMAKE_CONFIGURATION_TYPES Debug Release)

project (nirvana-sdk CXX C ASM)

option (NIRVANA_IDL "Compile IDL" ON)
option (NIRVANA_BUILD "Build" ON)

if (${NIRVANA_BUILD})

include (CTest)

set (NIRVANA_LIB_DIR "${CMAKE_SOURCE_DIR}/out/sdk/lib/${NIRVANA_TARGET_PLATFORM}")
set (mockhost_DIR "${CMAKE_SOURCE_DIR}/build/${NIRVANA_TARGET_PLATFORM}/vcpkg_installed/${NIRVANA_TARGET_PLATFORM}-windows/share/mockhost")

# We need to specify --sysroot to avoid searching mingw32 possible installed.
# Without the --sysroot CLang search mingw32 library paths.
# If mingw32 is installed (GitHub) this causes library collisions.
add_link_options (-fuse-ld=lld -nodefaultlibs "--sysroot=${LLVM_PATH}"
"LINKER:SHELL:/incremental:no /opt:ref /nodefaultlib /noimplib /section:olfbind,r /merge:.eh_frame=.rdata\
 /machine:${NIRVANA_TARGET_PLATFORM} '-L$<TARGET_FILE_DIR:crtl>'\
$<$<CONFIG:Debug>: /debug:dwarf>")

if (${NIRVANA_TARGET_PLATFORM} STREQUAL "x86")
  add_link_options ("LINKER:/safeseh:no")
endif ()

include_directories ("${CMAKE_SOURCE_DIR}/out/sdk/include/c++/v1")

# Do not undefine _WIN64 because this breaks the code

add_compile_options (
	"-U_WIN32"
  "-fno-ms-compatibility"
  "-fno-ms-extensions"
)

link_libraries (
	${NIRVANA_LIB_DIR}/$<CONFIG>/libc++.a
	${NIRVANA_LIB_DIR}/$<CONFIG>/libc++experimental.a
	${NIRVANA_LIB_DIR}/$<CONFIG>/libm.a
	${NIRVANA_LIB_DIR}/$<CONFIG>/libc++abi.a
	${NIRVANA_LIB_DIR}/$<CONFIG>/libunwind.a
)

endif ()

add_subdirectory (nirvana)

if (NIRVANA_BUILD)

add_subdirectory (googletest)

endif ()
