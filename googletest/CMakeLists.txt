add_library (googletest-nirvana STATIC
	googletest/googletest/src/gtest-all.cc
	googletest/googletest/src/gtest_main.cc
)

target_include_directories (googletest-nirvana
	PUBLIC googletest/googletest/include
	PRIVATE googletest/googletest
)

target_link_libraries (googletest-nirvana PUBLIC nirvana)

target_compile_definitions (googletest-nirvana PUBLIC GTEST_HAS_POSIX_RE=0 GTEST_HAS_SEH=0)

if (MSVC)
	target_compile_options(googletest-nirvana PRIVATE "/FI Nirvana/force_include.h")
else ()
	target_compile_options(googletest-nirvana PRIVATE "-includeNirvana/force_include.h")
endif ()

