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
