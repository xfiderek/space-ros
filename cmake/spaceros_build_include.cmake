# TODO LICENSE

# The content of this file will be injected into `CMakeLists.txt` files of dependent packages
# The location of this file is meant to be passed as `CMAKE_PROJECT_INCLUDE` argument during spaceros build
# https://cmake.org/cmake/help/v3.16/variable/CMAKE_PROJECT_INCLUDE.html


# Add all spaceros linters and static code analysis tools
if(BUILD_TESTING)
    # register `ament_lint_auto` extension that hooks into `ament_package` extension
    find_package(ament_lint_auto REQUIRED)

    # register linting extensions that hook into `ament_lint_auto` extension
    find_package(ament_cmake_clang_tidy REQUIRED)
    find_package(ament_cmake_cobra REQUIRED)
    find_package(ament_cmake_copyright REQUIRED)
    find_package(ament_cmake_cppcheck REQUIRED)
    find_package(ament_cmake_cpplint REQUIRED)
    find_package(ament_cmake_ikos REQUIRED)
    find_package(ament_cmake_flake8 REQUIRED)
    find_package(ament_cmake_lint_cmake REQUIRED)
    find_package(ament_cmake_pep257 REQUIRED)
    find_package(ament_cmake_uncrustify REQUIRED)
    find_package(ament_cmake_xmllint REQUIRED)
endif()
