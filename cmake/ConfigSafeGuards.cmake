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
# Using the base ConfigSafeGuards.cmake from:
#   CppProject - Template For C++ Projects -  - https://github.com/franneck94/CppProjectTemplate
# with some modifications, thus the copyright note.

if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(
        FATAL_ERROR
            "In-source builds not allowed. Please make a build directory.")
endif()

if(NOT CMAKE_BUILD_TYPE)
    message(STATUS "**** No build type selected. This is expected for multi-config generators during the configure/generate step.")
    message(STATUS "**** Just in case, setting it to Release")
    set(CMAKE_BUILD_TYPE "Release")
else()
    message(STATUS "**** Build type: ${CMAKE_BUILD_TYPE}")
endif()
