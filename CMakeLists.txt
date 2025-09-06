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

include (CTest)

set (NIRVANA_LIB_DIR "${CMAKE_SOURCE_DIR}/out/sdk/lib/${NIRVANA_TARGET_PLATFORM}")
set (mockhost_DIR "${CMAKE_SOURCE_DIR}/build/${NIRVANA_TARGET_PLATFORM}/vcpkg_installed/${NIRVANA_TARGET_PLATFORM}-windows/share/mockhost")

set (NIRVANA_LINK_FLAGS "/incremental:no /opt:ref /nodefaultlib /machine:${NIRVANA_TARGET_PLATFORM}")

if (${NIRVANA_TARGET_PLATFORM} STREQUAL "x86")
  string (CONCAT NIRVANA_LINK_FLAGS ${NIRVANA_LINK_FLAGS} " /safeseh:no")
endif ()

set (CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_LINKER> ${NIRVANA_LINK_FLAGS} <LINK_FLAGS> <OBJECTS> /out:<TARGET> <LINK_LIBRARIES>")
set (CMAKE_C_LINK_EXECUTABLE "<CMAKE_LINKER> ${NIRVANA_LINK_FLAGS} <LINK_FLAGS> <OBJECTS> /out:<TARGET> <LINK_LIBRARIES>")

add_link_options ($<$<CONFIG:Debug>:/debug>)

include_directories (
	"${CMAKE_SOURCE_DIR}/out/sdk/include/c++/v1"
)

# Do not undefine _WIN64 because this breaks the code

add_compile_options (
	"-U_WIN32"
)

# ? Is it really need?
add_compile_definitions (
  _LIBUNWIND_REMEMBER_STACK_ALLOC
)

if (NIRVANA_IDL)

find_program (NIDL2CPP nidl2cpp PATHS
  ${CMAKE_SOURCE_DIR}/build/x64/vcpkg_installed/x64-windows/tools/nidl2cpp
  ${CMAKE_SOURCE_DIR}/build/x86/vcpkg_installed/x64-windows/tools/nidl2cpp
REQUIRED)

set (idl_options
	-I "${CMAKE_CURRENT_SOURCE_DIR}/nirvana/orb/Include"
	-I "${CMAKE_CURRENT_SOURCE_DIR}/nirvana/library/Include"
	-inc_cpp "../../pch/pch.h"
	-D CCM_NOEVENT -D CCM_LW
)

endif ()

function (idl_generate)

	set (options)
	set (one_args OUT_VAR)
	set (multi_args IDL_FILES OPTIONS)
	cmake_parse_arguments( PARSE_ARGV 0 arg "${options}" "${one_args}" "${multi_args}")

  set (gen_dir ${CMAKE_SOURCE_DIR}/build)
  set (out_all)
	foreach (f IN LISTS arg_IDL_FILES)
    cmake_path (ABSOLUTE_PATH f NORMALIZE OUTPUT_VARIABLE idl)
    cmake_path (RELATIVE_PATH idl BASE_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE r_path)
    set (out_path ${gen_dir}/${r_path})
    cmake_path (GET out_path PARENT_PATH out_dir)
		cmake_path (REMOVE_EXTENSION out_path OUTPUT_VARIABLE out_path)
    set (out)
		list (APPEND out ${out_path}.h)
		list (APPEND out ${out_path}_s.h)
		list (APPEND out ${out_path}.cpp)

    if (NIRVANA_IDL)
      add_custom_command (
        OUTPUT ${out}
        COMMAND ${NIDL2CPP} ARGS ${idl_options} ${arg_OPTIONS} -no_proxy -out ${out_dir} ${idl}
        DEPENDS ${idl}
        VERBATIM
      )
    endif ()

    list (APPEND out_all ${out})
  endforeach ()

	set (${arg_OUT_VAR} ${out_all} PARENT_SCOPE)

endfunction ()

add_subdirectory (nirvana)

if (NIRVANA_BUILD)

add_subdirectory (googletest)

endif ()
