# Nirvana SDK build CMake toolchain file

set (clang_lib lib/clang/21) # Required CLang version

set (llvm $ENV{LLVM_PATH})
#if (NOT EXISTS "${llvm}/${clang_lib}")
#  set (llvm $ENV{ProgramFiles}/LLVM)
#endif ()

if (NOT EXISTS "${llvm}/lib/clang/21")
  message (FATAL_ERROR "CLang 21 not found")
endif ()

cmake_path (NORMAL_PATH llvm)
set (llvm_bin ${llvm}/bin)
find_program (CLANG "clang++" PATHS ${llvm_bin})
if (NOT CLANG)
  message (FATAL_ERROR "CLang compiler not found in " ${llvm_bin})
endif ()

set (CMAKE_CXX_COMPILER ${llvm_bin}/clang++.exe)
set (CMAKE_CXX_COMPILER_WORKS ON)
set (CMAKE_CXX_COMPILE_FEATURES
  cxx_std_98
  cxx_template_template_parameters
  cxx_std_11
  cxx_alias_templates
  cxx_alignas
  cxx_alignof
  cxx_attributes
  cxx_auto_type
  cxx_constexpr
  cxx_decltype
  cxx_decltype_incomplete_return_types
  cxx_default_function_template_args
  cxx_defaulted_functions
  cxx_defaulted_move_initializers
  cxx_delegating_constructors
  cxx_deleted_functions
  cxx_enum_forward_declarations
  cxx_explicit_conversions
  cxx_extended_friend_declarations
  cxx_extern_templates
  cxx_finalcxx_func_identifier
  cxx_generalized_initializers
  cxx_inheriting_constructors
  cxx_inline_namespaces
  cxx_lambdas
  cxx_local_type_template_args
  cxx_long_long_type
  cxx_noexcept
  cxx_nonstatic_member_init
  cxx_nullptr
  cxx_override
  cxx_range_for
  cxx_raw_string_literals
  cxx_reference_qualified_functions
  cxx_right_angle_brackets
  cxx_rvalue_references
  cxx_sizeof_member
  cxx_static_assert
  cxx_strong_enums
  cxx_thread_local
  cxx_trailing_return_types
  cxx_unicode_literals
  cxx_uniform_initialization
  cxx_unrestricted_unions
  cxx_user_literals
  cxx_variadic_macros
  cxx_variadic_templates
  cxx_std_14
  cxx_aggregate_default_initializers
  cxx_attribute_deprecated
  cxx_binary_literals
  cxx_contextual_conversions
  cxx_decltype_auto
  cxx_digit_separators
  cxx_generic_lambdas
  cxx_lambda_init_captures
  cxx_relaxed_constexpr
  cxx_return_type_deduction
  cxx_variable_templates
  cxx_std_17
  cxx_std_20
  cxx_std_23
  cxx_std_26
)

set (CMAKE_C_COMPILER ${llvm_bin}/clang.exe)
set (CMAKE_C_COMPILER_WORKS ON)
set (CMAKE_ASM_COMPILER ${llvm_bin}/clang.exe)
set (CMAKE_RC_COMPILER ${llvm_bin}/llvm-rc.exe)

set (CMAKE_CXX_STANDARD_LIBRARIES "")

set (c_compile_flags "-fshort-wchar -mlong-double-80\
 -fno-ms-compatibility -fno-ms-extensions\
 -Wno-character-conversion -fsjlj-exceptions"
)

string (CONCAT cpp_compile_flags ${c_compile_flags} " -fsized-deallocation")

set (CMAKE_CXX_FLAGS_INIT ${cpp_compile_flags})
set (CMAKE_C_FLAGS_INIT ${c_compile_flags})

set (debug_flags "-gdwarf-4")
set (release_flags "-fno-builtin")

set (CMAKE_CXX_FLAGS_DEBUG_INIT ${debug_flags})
set (CMAKE_C_FLAGS_DEBUG_INIT ${debug_flags})
set (CMAKE_ASM_FLAGS_DEBUG_INIT ${debug_flags})

set (CMAKE_CXX_FLAGS_RELEASE_INIT ${release_flags})
set (CMAKE_C_FLAGS_RELEASE_INIT ${release_flags})

list (APPEND CMAKE_MODULE_PATH "${llvm}/lib/cmake/clang")
