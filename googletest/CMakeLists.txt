add_library(googletest-nirvana STATIC
	googletest/googletest/src/gtest-all.cc
	googletest/googletest/src/gtest_main.cc
)
target_include_directories(googletest-nirvana
	PUBLIC googletest/googletest/include
	PRIVATE googletest/googletest
)
target_link_libraries(googletest-nirvana PUBLIC nirvana)
if(MSVC)
target_compile_options(googletest-nirvana PRIVATE "/FI Nirvana/Nirvana.h")
else()
target_compile_options(googletest-nirvana PRIVATE "-includeNirvana/Nirvana.h")
endif()
