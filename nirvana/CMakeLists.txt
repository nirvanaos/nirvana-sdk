if (${NIRVANA_BUILD})

add_library (nirvana STATIC)

set (include_dir "${CMAKE_SOURCE_DIR}/out/sdk/include")
target_include_directories (nirvana PUBLIC
	"${include_dir}/c++/v1"
)

# Do not undefine _WIN64 because this breaks the code

target_compile_options (nirvana PUBLIC
	"-U_WIN32"
)

target_compile_definitions (nirvana PUBLIC
  _LIBUNWIND_REMEMBER_STACK_ALLOC
)

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
