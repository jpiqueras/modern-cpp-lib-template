# ----------------------------------------------------------------------------------------------------------
# Copyright 2022, Jan Schaffranek.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or substantial
# portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# 
# ----------------------------------------------------------------------------------------------------------
#
# Using the base Tools.cmake from:
#   CppProject - Template For C++ Projects -  - https://github.com/franneck94/CppProjectTemplate
# with some modifications, thus the copyright note.

# Clang-tidy
function(add_clang_tidy_to_target target)
    if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        message(
            "==> Cppcheck, IWYU and Clang-Tidy Targets do not work with MSVC")
        return()
    endif()    
    get_target_property(TARGET_SOURCES ${target} SOURCES)
    list(
        FILTER
        TARGET_SOURCES
        INCLUDE
        REGEX
        ".*.(cc|h|cpp|hpp)")

    # Try to find specific versions of clang-tidy starting from 16, if not, check "clang-tidy"
    find_program(CLANG_TIDY_EXE NAMES clang-tidy-16 clang-tidy-15 clang-tidy)
    if(CLANG_TIDY_EXE)
        # Check version of clang-tidy. It should be >=14
        execute_process(
            COMMAND ${CLANG_TIDY_EXE} --version
            OUTPUT_VARIABLE CLANG_TIDY_VERSION_OUTPUT
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        string(REGEX REPLACE ".*version ([0-9]+\\.[0-9]+\\.[0-9]+).*" "\\1"
        CLANG_TIDY_VERSION "${CLANG_TIDY_VERSION_OUTPUT}")
 
        if(CLANG_TIDY_VERSION VERSION_LESS "14.0")
            message(WARNING "clang-tidy version 14 or higher is required. Found version ${CLANG_TIDY_VERSION}.")
            return()
        endif()

        # Exit with error if warnings found and if LIB_OPTION_WARNINGS_AS_ERRORS is set
        if(LIB_OPTION_WARNINGS_AS_ERRORS)
        set(CLANG_TIDY_WARNING_AS_ERRORS --warnings-as-errors=*)
        else()
        set(CLANG_TIDY_WARNING_AS_ERRORS )
        endif()

        message("==> Added Clang Tidy version ${CLANG_TIDY_VERSION} for Target: ${target}")
        set(CLANG_TIDY_COMMAND "${CLANG_TIDY_EXE}" "-checks=-*,modernize-*")
        add_custom_target(
            ${target}_clangtidy
            COMMAND
                clang-tidy
                --config-file ${CMAKE_SOURCE_DIR}/.clang-tidy
                --extra-arg-before=-std=${CMAKE_CXX_STANDARD}
                --header-filter=.*
                ${CLANG_TIDY_WARNING_AS_ERRORS}
                -p ${CMAKE_BINARY_DIR}
                ${TARGET_SOURCES}
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            USES_TERMINAL)
    else()
        message("==> CLANGTIDY NOT FOUND")
    endif()  
endfunction()

#iwyu
function(add_iwyu_to_target target)
    if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        message(
            "==> Cppcheck, IWYU and Clang-Tidy Targets do not work with MSVC")
        return()
    endif()

    if(LIB_OPTION_INCLUDE_WHAT_YOU_USE)
        if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            find_program(INCLUDE_WHAT_YOU_USE include-what-you-use)
            if(INCLUDE_WHAT_YOU_USE)
                add_custom_target(
                    ${target}_iwyu
                    COMMAND
                        ${Python3_EXECUTABLE}
                        ${CMAKE_SOURCE_DIR}/tools/iwyu_tool.py -p
                        ${CMAKE_BINARY_DIR} ${TARGET_SOURCES}
                    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
            else()
                message("==> INCLUDE_WHAT_YOU_USE NOT FOUND")
            endif()
        else()
            message("==> INCLUDE_WHAT_YOU_USE NEEDS CLANG COMPILER")
        endif()
    endif()
endfunction()
