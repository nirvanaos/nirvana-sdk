cmake_minimum_required(VERSION 3.25)
set(CMAKE_CXX_SCAN_FOR_MODULES 0)
cmake_policy(SET CMP0010 NEW)
cmake_policy(SET CMP0053 NEW)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(CMAKE_CONFIGURATION_TYPES Debug Release)

project(nirvana-sdk CXX C)

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")

	add_compile_options("/Zc:sizedDealloc" "/Zc:__cplusplus")
	set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")

	set(CMAKE_CXX_FLAGS "-stdlib=libc++")
	set(CMAKE_CXX_FLAGS_DEBUG "-g -O0 -fstandalone-debug")
	add_compile_options("-fsized-deallocation" "-Wall")

	#add_compile_options("-fshort-wchar")

	if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
		add_compile_options("-mlzcnt")
	endif()

elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")

	set(CMAKE_CXX_FLAGS_DEBUG "-g -O0")
	add_compile_options("-fsized-deallocation" "-Wall")

	#add_compile_options("-fshort-wchar")

	if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
		add_compile_options("-mlzcnt")
	endif()

endif()

add_compile_definitions(__STDC_WANT_LIB_EXT1__=1)

file(GLOB installed_tools LIST_DIRECTORIES true ${VCPKG_INSTALLED_DIR}/*/tools/nidl2cpp)
find_program(NIDL2CPP nidl2cpp PATHS ${installed_tools} REQUIRED)

set(IDL_OPTIONS
	-I "${CMAKE_CURRENT_SOURCE_DIR}/nirvana/orb/Include"
	-I "${CMAKE_CURRENT_SOURCE_DIR}/nirvana/library/Include"
	-inc_cpp "../../pch/pch.h"
	-D CCM_NOEVENT -D CCM_LW
)

function(idl_generate)

	set(options)
	set(one_args OUT_VAR)
	set(multi_args IDL_FILES OPTIONS)
	cmake_parse_arguments(PARSE_ARGV 0 arg "${options}" "${one_args}" "${multi_args}")

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
		BYPRODUCTS
	)

	set(${arg_OUT_VAR} ${idl_cpp} PARENT_SCOPE)

endfunction()

include(CTest)

add_subdirectory(nirvana)

if(BUILD_TESTING)
	add_subdirectory(googletest)
endif()
