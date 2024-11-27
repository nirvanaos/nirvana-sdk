add_library(nirvana STATIC)
target_include_directories(nirvana PRIVATE
	library/Include
	orb/Include
)

set(IDL_OPTIONS
	-I "${CMAKE_CURRENT_SOURCE_DIR}/orb/Include"
	-I "${CMAKE_CURRENT_SOURCE_DIR}/library/Include"
	-inc_cpp "../../pch/pch.h"
	-D CCM_NOEVENT -D CCM_LW
)

add_subdirectory(library)
add_subdirectory(orb)
