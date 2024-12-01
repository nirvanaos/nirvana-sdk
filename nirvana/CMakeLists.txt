add_library(nirvana STATIC)
target_include_directories(nirvana PUBLIC
	library/Include
	orb/Include
)

target_precompile_headers(nirvana PRIVATE 
	$<$<COMPILE_LANGUAGE:CXX>:${CMAKE_CURRENT_SOURCE_DIR}/pch/pch.h>)

set(IDL_OPTIONS
	-I "${CMAKE_CURRENT_SOURCE_DIR}/orb/Include"
	-I "${CMAKE_CURRENT_SOURCE_DIR}/library/Include"
	-inc_cpp "../../pch/pch.h"
	-D CCM_NOEVENT -D CCM_LW
)

function(idl_target tgt_name)

	set(options)
	set(one_args)
	set(multi_args IDL_FILES OPTIONS)
	cmake_parse_arguments(PARSE_ARGV 1 arg "${options}" "${one_args}" "${multi_args}")

	foreach(f IN LISTS arg_IDL_FILES)
		list(APPEND idl_idl ${CMAKE_CURRENT_SOURCE_DIR}/${f})
		cmake_path(REMOVE_EXTENSION f OUTPUT_VARIABLE f_no_ext)
		list(APPEND idl_h ${CMAKE_CURRENT_SOURCE_DIR}/${f_no_ext}.h)
		list(APPEND idl_h ${CMAKE_CURRENT_SOURCE_DIR}/${f_no_ext}_s.h)
		cmake_path(GET f STEM name)
		list(APPEND idl_cpp ${CMAKE_CURRENT_BINARY_DIR}/${name}.cpp)
	endforeach()

	add_custom_command(
		OUTPUT ${idl_h} ${idl_cpp}
		COMMAND ${NIDL2CPP} ARGS ${IDL_OPTIONS} ${arg_OPTIONS} -no_proxy -out_cpp ${CMAKE_CURRENT_BINARY_DIR} ${idl_idl}
		DEPENDS ${idl_idl}
		COMMENT "Compile IDL..."
		VERBATIM
	)

	add_custom_target(${tgt_name} DEPENDS ${idl_h} ${idl_cpp})

endfunction()

add_subdirectory(library)
add_subdirectory(orb)
