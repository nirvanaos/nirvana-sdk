if (${NIRVANA_BUILD})

add_library (nirvana STATIC)

set (include_dir "${CMAKE_SOURCE_DIR}/out/sdk/include")

set (nirvana_includes
	"${include_dir}/c++/v1"
#	"${include_dir}/clang"
	"${CMAKE_SOURCE_DIR}/nirvana/orb/Include"
	"${CMAKE_SOURCE_DIR}/build/nirvana/orb/Include"
	"${CMAKE_SOURCE_DIR}/nirvana/library/Include"
	"${CMAKE_SOURCE_DIR}/build/nirvana/library/Include"
	"${CMAKE_SOURCE_DIR}/nirvana/library/Include/CRTL"
	"${include_dir}"
)

target_include_directories (nirvana PUBLIC ${nirvana_includes})

target_compile_options (nirvana PUBLIC
	"-U_WIN32"
	"-U_WIN64"
  "-U__MINGW__"
  "-U__MINGW32__"
  "-U__MINGW64__"
	"--target=${NIRVANA_TARGET_TRIPLE}"
)

if (${NIRVANA_TARGET_PLATFORM} STREQUAL "x64")
	target_compile_options (nirvana PUBLIC "-mlzcnt")
endif()

target_compile_definitions (nirvana PUBLIC
  _LIBUNWIND_REMEMBER_STACK_ALLOC
)

target_precompile_headers (nirvana PRIVATE 
	$<$<COMPILE_LANGUAGE:CXX>:${CMAKE_CURRENT_SOURCE_DIR}/pch/pch.h>)

target_link_libraries (nirvana PUBLIC
	${NIRVANA_LIB_DIR}/$<CONFIG>/libc++.lib
	${NIRVANA_LIB_DIR}/$<CONFIG>/libc++experimental.lib
	${NIRVANA_LIB_DIR}/$<CONFIG>/libm.lib
	${NIRVANA_LIB_DIR}/$<CONFIG>/libc++abi.lib
	${NIRVANA_LIB_DIR}/$<CONFIG>/libunwind.lib
)

set (nirvana_link_options "LINKER:SHELL:/nodefaultlib /debug:dwarf /opt:ref /machine:${NIRVANA_TARGET_PLATFORM} /section:olfbind,r /section:initonce,rw")

if (${NIRVANA_TARGET_PLATFORM} STREQUAL "x86")
  string (CONCAT nirvana_link_options ${nirvana_link_options} " /safeseh:no")
endif ()

set_target_properties(nirvana PROPERTIES
  INTERFACE_LINK_OPTIONS ${nirvana_link_options}
)

elseif (${NIRVANA_IDL})

add_custom_target (nirvana ALL)

endif ()

add_subdirectory (library)
add_subdirectory (orb)

add_dependencies (nirvana nirvana_idl corba_idl)
