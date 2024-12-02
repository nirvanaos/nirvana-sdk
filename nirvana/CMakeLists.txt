add_library(nirvana STATIC)
target_include_directories(nirvana PUBLIC
	library/Include
	orb/Include
)

target_precompile_headers(nirvana PRIVATE 
	$<$<COMPILE_LANGUAGE:CXX>:${CMAKE_CURRENT_SOURCE_DIR}/pch/pch.h>)

add_subdirectory(library)
add_subdirectory(orb)
