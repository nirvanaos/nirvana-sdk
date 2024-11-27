#vcpkg_from_github(
#    OUT_SOURCE_PATH SOURCE_PATH
#    REPO nirvanaos/nidl2cpp
#    REF e5215fa610f5abbfcd88434947745e445369fa42
#    SHA512 caffda90097cb06dd45f7d671031b07df4b913cde3168f4cdea84b43f7730d8aca6fa44a83c79c55849cb2e76e9da599bf2319734fb2f5587ad6649cf5171b70
#    HEAD_REF develop
#)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "https://github.com/nirvanaos/nidl2cpp"
    REF "539d19c5a6b2745b8457fe5317bced20222696a2"
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME ${PORT})
vcpkg_copy_tools(TOOL_NAMES ${PORT} AUTO_CLEAN)

file(INSTALL "${SOURCE_PATH}/license-lgpl.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

