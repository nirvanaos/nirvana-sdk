include_guard ()

file (TO_CMAKE_PATH $ENV{NIRVANA_SDK} NIRVANA_SDK_DIR)
file (TO_CMAKE_PATH $ENV{NIRVANA_TOOLS} NIRVANA_TOOLS_DIR)
set (NIDL2CPP ${NIRVANA_TOOLS_DIR}/nidl2cpp.exe)

function (nirvana_compile_idl target)

	set (multi_args IDL_FILES OPTIONS OUT_H IDL_ROOT)
	cmake_parse_arguments (arg "" "" "${multi_args}" ${ARGN})

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

  set (idl_out_dir "${CMAKE_CURRENT_BINARY_DIR}/${target}.generated")
	if (arg_OUT_H)
		set (idl_out_h ${arg_OUT_H})
	else ()
		set (idl_out_h ${idl_out_dir})
	endif ()
	set (idl_out_cpp ${idl_out_dir})
	set (idl_out_proxy ${idl_out_dir})
  if (client_h OR server)
    target_include_directories (${target} PUBLIC ${idl_out_h})
  endif ()

	if (arg_IDL_ROOT)
		cmake_path (ABSOLUTE_PATH arg_IDL_ROOT NORMALIZE OUTPUT_VARIABLE idl_root)
	else ()
		set (idl_root ${CMAKE_CURRENT_SOURCE_DIR})
	endif ()

	foreach (f IN LISTS arg_IDL_FILES)
		cmake_path (GET f STEM f_name)

    cmake_path (ABSOLUTE_PATH f BASE_DIRECTORY ${idl_root} NORMALIZE OUTPUT_VARIABLE a_path)
		cmake_path (IS_PREFIX idl_root ${a_path} is_prefix)
		if (NOT is_prefix)
			message (WARNING "${f} is not in ${idl_root} tree")
			cmake_path (GET f FILENAME r_path)
		else ()
    	cmake_path (RELATIVE_PATH a_path BASE_DIRECTORY ${idl_root} OUTPUT_VARIABLE r_path)
		endif ()

    set (out_h "${idl_out_h}/${r_path}")
    cmake_path (GET out_h PARENT_PATH out_h)

    set (out_cpp "${idl_out_cpp}/${r_path}")
    cmake_path (GET out_cpp PARENT_PATH out_cpp)

    set (out_proxy "${idl_out_proxy}/${r_path}")
    cmake_path (GET out_proxy PARENT_PATH out_proxy)

    set (out_files)
		set (out_options)
  	if (client_h OR server OR arg_OUT_H)
			set (out_options -out_h ${out_h})
		endif ()

    if (${client_h})
      list (APPEND out_files "${out_h}/${f_name}.h")
    endif ()
    if (${server})
      list (APPEND out_files "${out_h}/${f_name}_s.h")
    endif ()
    if (${client_cpp})
      list (APPEND out_files "${out_cpp}/${f_name}.cpp")
			list (APPEND out_options -out_cpp ${out_cpp})
    endif ()
    if (${proxy})
      list (APPEND out_files "${out_proxy}/${f_name}_p.cpp")
			list (APPEND out_options -out_proxy ${out_proxy})
    endif ()

    add_custom_command (
      OUTPUT ${out_files}
      COMMAND ${NIDL2CPP} ARGS ${arg_OPTIONS} -I ${NIRVANA_SDK_DIR}/include ${out_options} ${a_path}
      DEPENDS ${a_path}
      VERBATIM
    )

    list (APPEND idl_generated ${out_files})

	endforeach ()

  target_sources (${target} PRIVATE ${idl_generated})

endfunction ()

function (nirvana_module module_name)

	set (one_args MODULE_TYPE)
	set (multi_args IDL_FILES OPTIONS)
	cmake_parse_arguments (arg "" "${one_args}" "${multi_args}" ${ARGN})

  add_executable (${module_name})
  target_link_libraries (${module_name} PRIVATE libCoreImport.a)
  target_link_options (${module_name} PRIVATE "LINKER:/noentry,/dll,/dynamicbase")

  set (idl_options ${arg_OPTIONS})
  
  if ("${arg_MODULE_TYPE}" STREQUAL "MODULE" OR "${arg_MODULE_TYPE}" STREQUAL "")
    target_compile_definitions (${module_name} PRIVATE NIRVANA_MODULE)
  elseif ("${arg_MODULE_TYPE}" STREQUAL "SINGLETON")
    target_compile_definitions (${module_name} PRIVATE NIRVANA_SINGLETON)
  elseif ("${arg_MODULE_TYPE}" STREQUAL "PROCESS")
    target_compile_definitions (${module_name} PRIVATE NIRVANA_PROCESS)
    list (APPEND idl_options "-client")
  else ()
    message (FATAL_ERROR "Unknown module type ${arg_MODULE_TYPE}")
  endif ()

  set_target_properties (${module_name} PROPERTIES PREFIX "")
  if ("${arg_MODULE_TYPE}" STREQUAL "PROCESS")
    set_target_properties (${module_name} PROPERTIES SUFFIX ".nex")
  else ()
    set_target_properties (${module_name} PROPERTIES SUFFIX ".olf")
  endif ()

  if (arg_IDL_FILES)
    nirvana_compile_idl (${module_name} IDL_FILES ${arg_IDL_FILES} OPTIONS ${idl_options})
  endif ()

endfunction ()

function (nirvana_singleton module_name)
	set (multi_args IDL_FILES)
	cmake_parse_arguments (arg "" "" "${multi_args}" ${ARGN})
  nirvana_module (${module_name} MODULE_TYPE SINGLETON IDL_FILES ${arg_IDL_FILES})
endfunction ()

function (nirvana_process module_name)
	set (multi_args IDL_FILES)
	cmake_parse_arguments (arg "" "" "${multi_args}" ${ARGN})
  nirvana_module (${module_name} MODULE_TYPE PROCESS IDL_FILES ${arg_IDL_FILES})
endfunction ()

function (nirvana_test module_name)
	set (multi_args IDL_FILES)
	cmake_parse_arguments (arg "" "" "${multi_args}" ${ARGN})
  nirvana_process (${module_name} IDL_FILES ${arg_IDL_FILES})
  target_link_libraries (${module_name} PRIVATE libgoogletest-nirvana.a)
  target_compile_definitions (${module_name} PRIVATE GTEST_HAS_POSIX_RE=0 GTEST_HAS_SEH=0)
endfunction ()
