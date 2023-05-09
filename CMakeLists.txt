cmake_minimum_required(VERSION 3.25)

# The following options can be used to customize the build

# - LIB_OPTION_LIBRARY:
# Deactivating this options is useful if you want to build only the documentation.
# In that case, you should desactivate the other options as well (tests, benchmarks, etc.), 
# as they depend on the library.

# - LIB_OPTION_WARNINGS:
# Enable/disable compiler warnings. The warnings are defined as flags for MSVC, GCC and Clang in
# the Warnings.cmake file

# - LIB_OPTION_WARNINGS_AS_ERRORS:
# Treat warnings as error in the compiler, clang-tidy and cppcheck

# - BUILD_TESTING:
# Variable set to ON by CMake when calling include(CTest). However, we control
# the tests from conan, which uses the same variable. If BUILD_TESTING is not set to OFF
# (that is ON or not set), the tests will be built. TODO: Use another variable?

# - LIB_OPTION_COVERAGE:
# Create a coverage target. It also add the -fkeep-inline-functions flag to tests, 
# which might be problematic in the future.

# - LIB_OPTION_INCLUDE_WHAT_YOU_USE:
# Not working right now.

# - LIB_OPTION_CLANG_TIDY:
# Add a target for running clang-tidy. 
# Not necessary if you use the clang-tidy ingegration in your IDE (eg. VSCode)

# - LIB_OPTION_CPPCHECK:
# Add a target to use cppcheck. 
# Not necessary if you run cppcheck from the command line or through your IDE.

# - LIB_OPTION_SANITIZE_ADDR:
# Enable address sanitizer. Only works on Unix systems.

# - LIB_OPTION_SANITIZE_UNDEF:
# Enable undefined behavior sanitizer. Only works on Unix systems.

# - LIB_OPTION_LTO:
# Enable Link Time Optimization.

# - LIB_OPTION_DOCS:
# Add a 'doc' target to build documentation.


set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # Create a compile_commands.json file for clang-tidy and cppcheck 

option(LIB_OPTION_LIBRARY              "Include the Library"                           ON  )
option(LIB_OPTION_LTO                  "Enable Link Time Optimization."                OFF )
option(LIB_OPTION_DOCS                 "Add a 'doc' target to build documentation."    OFF )
option(LIB_OPTION_WARNINGS             "Add warnings to targets."                      ON  )
option(LIB_OPTION_WARNINGS_AS_ERRORS   "Treat warnings as errors."                     OFF )

option(LIB_OPTION_COVERAGE             "Enable a Code Coverage build."                 OFF )
option(LIB_OPTION_INCLUDE_WHAT_YOU_USE "Add iwyu to targets."                          OFF ) # Broken right now
option(LIB_OPTION_CLANG_TIDY           "Enable to add clang tidy."                     OFF )
option(LIB_OPTION_CPPCHECK             "Add cppcheck."                                 OFF ) 
option(LIB_OPTION_SANITIZE_ADDR        "Enable to sanitize address (Unix only)."       OFF )
option(LIB_OPTION_SANITIZE_UNDEF       "Enable to sanitize undefined (Unix only)."     OFF )




project(
    "modern-cpp-lib-template"
    VERSION ${CONAN_PROJECT_VERSION}
    LANGUAGES CXX)



# Set the C++ stanadard globally
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)



# CMake target names
set(LIB_NAME "my_lib")
set(TEST_TARGET_NAME "tests")
set(BENCHMARK_TARGET_NAME "benchmarks")


# CMAKE MODULES
message(STATUS "PROJECT_SOURCE_DIR: ${PROJECT_SOURCE_DIR}")
message(STATUS "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")
message(STATUS "CMAKE_SOURCE_DIR: ${CMAKE_SOURCE_DIR}")

set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/)


include(Warnings)
include(Tools)
include(LTO)
include(ConfigSafeGuards)



if(LIB_OPTION_SANITIZE_ADDR OR LIB_OPTION_SANITIZE_UNDEF)
    include(Sanitizer)
    add_sanitizer_flags()
endif()

if(LIB_OPTION_COVERAGE)
    include(CodeCoverage)
    append_coverage_compiler_flags()
endif()

if(LIB_OPTION_LTO)
    find_lto(CXX)
endif()



# LIBRARY
if (LIB_OPTION_LIBRARY)
    add_subdirectory(my_lib)
endif()

# DOCS
if(LIB_OPTION_DOCS)
    # Include "Docs.cmake" to add the target "doc"
    include(Docs)
endif()

# TESTS
if (NOT BUILD_TESTING STREQUAL OFF)
    enable_testing() #TODO: Not sure if necessary
    add_subdirectory(test)
endif()

# No installation. I don't know how to do it with cmake.
# But using conan works fine.
