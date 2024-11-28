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

if(MSVC)
	add_compile_options("/Zc:__cplusplus")
	set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
else()
	add_compile_options("-mlzcnt" "-fshort-wchar")
endif()
add_compile_definitions(__STDC_WANT_LIB_EXT1__=1)

file(GLOB installed_tools LIST_DIRECTORIES true ${VCPKG_INSTALLED_DIR}/*/tools/nidl2cpp)
find_program(NIDL2CPP nidl2cpp PATHS ${installed_tools} REQUIRED)
add_subdirectory(nirvana)
