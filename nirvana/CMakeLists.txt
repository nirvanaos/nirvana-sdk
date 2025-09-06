if (${NIRVANA_BUILD})

add_library (nirvana STATIC)

target_precompile_headers (nirvana PRIVATE 
	$<$<COMPILE_LANGUAGE:CXX>:${CMAKE_CURRENT_SOURCE_DIR}/pch/pch.h>)

target_link_libraries (nirvana PUBLIC
	${NIRVANA_LIB_DIR}/$<CONFIG>/libc++.a
	${NIRVANA_LIB_DIR}/$<CONFIG>/libc++experimental.a
	${NIRVANA_LIB_DIR}/$<CONFIG>/libm.a
	${NIRVANA_LIB_DIR}/$<CONFIG>/libc++abi.a
	${NIRVANA_LIB_DIR}/$<CONFIG>/libunwind.a
)

elseif (${NIRVANA_IDL})

add_custom_target (nirvana ALL)

endif ()

add_subdirectory (library)
add_subdirectory (orb)

add_dependencies (nirvana nirvana_idl corba_idl)
