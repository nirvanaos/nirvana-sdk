if (NIRVANA_IDL)

find_program (NIDL2CPP nidl2cpp PATHS
  ${CMAKE_SOURCE_DIR}/build/x64/vcpkg_installed/x64-windows/tools/nidl2cpp
  ${CMAKE_SOURCE_DIR}/build/x86/vcpkg_installed/x64-windows/tools/nidl2cpp
REQUIRED)

set (idl_options
	-I "${CMAKE_CURRENT_SOURCE_DIR}/orb/Include"
	-I "${CMAKE_CURRENT_SOURCE_DIR}/library/Include"
	-inc_cpp "../../pch/pch.h"
	-D CCM_NOEVENT -D CCM_LW
)

endif ()

function (idl_generate)

	set (options)
	set (one_args OUT_VAR)
	set (multi_args IDL_FILES OPTIONS)
	cmake_parse_arguments( PARSE_ARGV 0 arg "${options}" "${one_args}" "${multi_args}")

  set (gen_dir ${CMAKE_SOURCE_DIR}/build/idl)
  set (out_all)
	foreach (f IN LISTS arg_IDL_FILES)
    cmake_path (ABSOLUTE_PATH f NORMALIZE OUTPUT_VARIABLE idl)
    cmake_path (RELATIVE_PATH idl BASE_DIRECTORY "${CMAKE_SOURCE_DIR}/nirvana" OUTPUT_VARIABLE r_path)
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

if (${NIRVANA_BUILD})

add_library (nirvana STATIC)

target_precompile_headers (nirvana PRIVATE 
	$<$<COMPILE_LANGUAGE:CXX>:${CMAKE_CURRENT_SOURCE_DIR}/pch/pch.h>)

elseif (${NIRVANA_IDL})

add_custom_target (nirvana ALL)

endif ()

add_subdirectory (library)
add_subdirectory (orb)

add_dependencies (nirvana nirvana_idl corba_idl)
