include_guard ()
include (NirvanaTargetPlatform)

file (TO_CMAKE_PATH $ENV{NIRVANA_SDK} NIRVANA_SDK_DIR)
file (TO_CMAKE_PATH $ENV{NIRVANA_TOOLS} NIRVANA_TOOLS_DIR)
set (NIDL2CPP ${NIRVANA_TOOLS_DIR}/nidl2cpp.exe)

set (platform_flags " --target=${NIRVANA_TARGET_TRIPLE}")
if (${NIRVANA_TARGET_PLATFORM} STREQUAL "x64")
  string (CONCAT platform_flags ${platform_flags} " -mlzcnt")
endif ()

string (CONCAT CMAKE_C_FLAGS ${CMAKE_C_FLAGS} ${platform_flags})
string (CONCAT CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} ${platform_flags})

set (NIRVANA_LINK_FLAGS "/incremental:no /opt:ref /nodefaultlib /debug:dwarf /section:olfbind,r\
 /machine:${NIRVANA_TARGET_PLATFORM}")

if (${NIRVANA_TARGET_PLATFORM} STREQUAL "x86")
  string (CONCAT NIRVANA_LINK_FLAGS ${NIRVANA_LINK_FLAGS} " /safeseh:no")
endif ()

set (CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_LINKER> ${NIRVANA_LINK_FLAGS} <LINK_FLAGS> <OBJECTS> /out:<TARGET> <LINK_LIBRARIES>")

set (NIRVANA_LIB_DIR "${NIRVANA_SDK_DIR}/lib/${NIRVANA_TARGET_PLATFORM}")

link_libraries (
	${NIRVANA_LIB_DIR}/$<CONFIG>/nirvana.lib
	${NIRVANA_LIB_DIR}/$<CONFIG>/crtl.lib
	${NIRVANA_LIB_DIR}/$<CONFIG>/libm.lib
	${NIRVANA_LIB_DIR}/$<CONFIG>/libc++.lib
	${NIRVANA_LIB_DIR}/$<CONFIG>/libc++abi.lib
	${NIRVANA_LIB_DIR}/$<CONFIG>/libc++experimental.lib
	${NIRVANA_LIB_DIR}/$<CONFIG>/libunwind.lib
)

function (nirvana_module_idl)

	set (options)
	set (one_args MODULE_NAME)
	set (multi_args IDL_FILES OPTIONS)
	cmake_parse_arguments (PARSE_ARGV 0 arg "${options}" "${one_args}" "${multi_args}")

  set (client_h 1)
  set (client_cpp 1)
  set (server 1)
  set (proxy 1)

 	foreach (opt IN LISTS arg_OPTIONS)
    if (${opt} STREQUAL "-client")
      set (client_h 1)
      set (client_cpp 1)
      set (server 0)
      set (proxy 0)
    elseif (${opt} STREQUAL "-no_client")
      set (client_h 0)
      set (client_cpp 0)
    elseif (${opt} STREQUAL "-no_client_cpp")
      set (client_cpp 0)
    elseif (${opt} STREQUAL "-server")
      set (server 1)
      set (client_h 0)
      set (client_cpp 0)
      set (proxy 0)
    elseif (${opt} STREQUAL "-no_server")
      set (server 0)
    elseif (${opt} STREQUAL "-proxy")
      set (server 0)
      set (client_h 0)
      set (client_cpp 0)
      set (proxy 1)
    elseif (${opt} STREQUAL "-no_proxy")
      set (proxy 0)
    elseif (${opt} STREQUAL "-out" OR ${opt} STREQUAL "-out_h" OR ${opt} STREQUAL "-out_cpp" OR ${opt} STREQUAL "-out_proxy"
      OR ${opt} STREQUAL "-client_suffix" OR ${opt} STREQUAL "-server_suffix" OR ${opt} STREQUAL "-proxy_suffix")
      message(FATAL_ERROR "Unsupported option: " ${opt})
    endif ()
	endforeach()

  set (idl_generated)

  set (idl_root "${CMAKE_CURRENT_BINARY_DIR}/${arg_MODULE_NAME}.generated")
  if (client_h OR server)
    target_include_directories (${arg_MODULE_NAME} PRIVATE ${idl_root})
  endif ()

	foreach (f IN LISTS arg_IDL_FILES)
		cmake_path (GET f STEM f_name)

    cmake_path (ABSOLUTE_PATH f NORMALIZE OUTPUT_VARIABLE a_path)
    cmake_path (RELATIVE_PATH f OUTPUT_VARIABLE r_path)
    cmake_path (GET r_path PARENT_PATH r_dir)

    set (out_dir "${idl_root}/${r_dir}")

    set (out_files)
    if (${client_h})
      list (APPEND out_files "${out_dir}/${f_name}.h")
    endif ()
    if (${client_cpp})
      list (APPEND out_files "${out_dir}/${f_name}.cpp")
    endif ()
    if (${server})
      list (APPEND out_files "${out_dir}/${f_name}_s.h")
    endif ()
    if (${proxy})
      list (APPEND out_files "${out_dir}/${f_name}_p.cpp")
    endif ()

    add_custom_command (
      OUTPUT ${out_files}
      COMMAND ${NIDL2CPP} ARGS ${arg_OPTIONS} -I ${NIRVANA_SDK_DIR}/include -out ${out_dir} ${f}
      DEPENDS ${f}
      VERBATIM
    )

    list (APPEND idl_generated ${out_files})

	endforeach ()

  target_sources (${arg_MODULE_NAME} PRIVATE ${idl_generated})

endfunction ()

function (nirvana_module)

	set (options)
	set (one_args MODULE_NAME MODULE_TYPE)
	set (multi_args IDL_FILES)
	cmake_parse_arguments (PARSE_ARGV 0 arg "${options}" "${one_args}" "${multi_args}")

  add_executable (${arg_MODULE_NAME})
  target_link_libraries (${arg_MODULE_NAME} PRIVATE ${NIRVANA_LIB_DIR}/$<CONFIG>/coreimport.lib)
  target_link_options (${arg_MODULE_NAME} PRIVATE /noentry /dll /dynamicbase)

  set (idl_options)
  
  if (NOT ${arg_MODULE_TYPE} OR ${arg_MODULE_TYPE} STREQUAL "MODULE")
    target_compile_definitions (${arg_MODULE_NAME} PRIVATE NIRVANA_MODULE)
  elseif (${arg_MODULE_TYPE} STREQUAL "SINGLETON")
    target_compile_definitions (${arg_MODULE_NAME} PRIVATE NIRVANA_SINGLETON)
  elseif (${arg_MODULE_TYPE} STREQUAL "PROCESS")
    target_compile_definitions (${arg_MODULE_NAME} PRIVATE NIRVANA_PROCESS)
    set (idl_options "-client")
  else ()
    message (FATAL_ERROR "Unknown module type ${arg_MODULE_TYPE}")
  endif ()

  set_target_properties (${arg_MODULE_NAME} PROPERTIES PREFIX "")
  if (${arg_MODULE_TYPE} AND ${arg_MODULE_TYPE} STREQUAL "PROCESS")
    set_target_properties (${arg_MODULE_NAME} PROPERTIES SUFFIX ".nex")
  else ()
    set_target_properties (${arg_MODULE_NAME} PROPERTIES SUFFIX ".olf")
  endif ()

  if (arg_IDL_FILES)
    nirvana_module_idl (MODULE_NAME ${arg_MODULE_NAME} IDL_FILES ${arg_IDL_FILES} OPTIONS ${idl_options})
  endif ()

endfunction ()

function (nirvana_singleton)
	set (options)
	set (one_args MODULE_NAME)
	set (multi_args IDL_FILES)
	cmake_parse_arguments (PARSE_ARGV 0 arg "${options}" "${one_args}" "${multi_args}")
  nirvana_module (MODULE_NAME ${arg_MODULE_NAME} MODULE_TYPE SINGLETON IDL_FILES ${arg_IDL_FILES})
endfunction ()

function (nirvana_process)
	set (options)
	set (one_args MODULE_NAME)
	set (multi_args IDL_FILES)
	cmake_parse_arguments (PARSE_ARGV 0 arg "${options}" "${one_args}" "${multi_args}")
  nirvana_module (MODULE_NAME ${arg_MODULE_NAME} MODULE_TYPE PROCESS IDL_FILES ${arg_IDL_FILES})
endfunction ()

function (nirvana_test)
	set (options)
	set (one_args MODULE_NAME)
	set (multi_args IDL_FILES)
	cmake_parse_arguments (PARSE_ARGV 0 arg "${options}" "${one_args}" "${multi_args}")
  nirvana_process (MODULE_NAME ${arg_MODULE_NAME} IDL_FILES ${arg_IDL_FILES})
  target_link_libraries (${arg_MODULE_NAME} PRIVATE ${NIRVANA_LIB_DIR}/$<CONFIG>/googletest-nirvana.lib)
  target_compile_definitions (${arg_MODULE_NAME} PRIVATE GTEST_HAS_POSIX_RE=0 GTEST_HAS_SEH=0)
endfunction ()
