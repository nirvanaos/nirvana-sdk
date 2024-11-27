cmake_minimum_required(VERSION 3.28)
set(CMAKE_CXX_SCAN_FOR_MODULES 0)
cmake_policy(SET CMP0010 NEW)
cmake_policy(SET CMP0053 NEW)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CONFIGURATION_TYPES Debug Release)

project(nirvana-sdk CXX C)

if(MSVC)
	add_compile_options("/Zc:__cplusplus")
	set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

find_program(NIDL2CPP nidl2cpp REQUIRED)
add_subdirectory(nirvana)
