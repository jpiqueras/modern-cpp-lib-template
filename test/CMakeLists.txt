

set(TEST_SOURCES 
      "${CMAKE_CURRENT_SOURCE_DIR}/mytest1.cpp"
      "${CMAKE_CURRENT_SOURCE_DIR}/mytest2.cpp"
)

set(TEST_HEADERS "")

#Tests need Catch2
find_package(Catch2 REQUIRED)

# Create the target "tests_lib". This target only includes the library and prints info
# It is useful for cppcheck to avoid warnings with Catch2
add_executable(${TEST_TARGET_NAME}_lib "${CMAKE_CURRENT_SOURCE_DIR}/lib_info_test.cpp")
target_link_libraries(${TEST_TARGET_NAME}_lib PRIVATE ${LIB_NAME})

#Create the target "tests" 
add_executable(${TEST_TARGET_NAME} ${TEST_SOURCES} ${TEST_HEADERS})

#Link with the lib and catch2
target_link_libraries(${TEST_TARGET_NAME} PRIVATE ${LIB_NAME})
target_link_libraries(${TEST_TARGET_NAME} PRIVATE Catch2::Catch2WithMain)

target_set_warnings(
  TARGET
  ${TEST_TARGET_NAME}
  ENABLE
  ${LIB_OPTION_WARNINGS}
  AS_ERRORS
  ${LIB_OPTION_WARNINGS_AS_ERRORS})

target_set_warnings(
    TARGET
    ${TEST_TARGET_NAME}_lib
    ENABLE
    ${LIB_OPTION_WARNINGS}
    AS_ERRORS
    ${LIB_OPTION_WARNINGS_AS_ERRORS})
  




if (LIB_OPTION_CLANG_TIDY)
  add_clang_tidy_to_target(${TEST_TARGET_NAME})
endif()

if (LIB_OPTION_INCLUDE_WHAT_YOU_USE)
  add_iwyu_to_target(${TEST_TARGET_NAME})
endif()

# CTEST add a lot of targets for CI/CD?, by setting this property we avoid that.
set_property(GLOBAL PROPERTY CTEST_TARGETS_ADDED 1)

include(CTest) #TODO: Is it really necessary to use CTest?
include(Catch)
catch_discover_tests(${TEST_TARGET_NAME})

if(LIB_OPTION_COVERAGE)
  set(COVERAGE_MAIN "coverage")
  set(COVERAGE_EXCLUDES
      "${PROJECT_SOURCE_DIR}/benchmarks/*"
      "${PROJECT_SOURCE_DIR}/cmake/*"
      "${PROJECT_SOURCE_DIR}/docs/*"
      "${PROJECT_SOURCE_DIR}/external/*"
      "${PROJECT_SOURCE_DIR}/test/*"
      "${PROJECT_SOURCE_DIR}/build/*"
      "/usr/include/*"
      "11/*"
      )
      
  # Using this flag to avoid member function to be inlined and not reported in codecov
  # It works in this example but seems to break things... 
  # See: https://stackoverflow.com/questions/9666800/getting-useful-gcov-results-for-header-only-libraries
  target_compile_options(${TEST_TARGET_NAME} PRIVATE -fkeep-inline-functions)


  setup_target_for_coverage_lcov(
      NAME ${COVERAGE_MAIN}
      EXECUTABLE ${TEST_TARGET_NAME}
      DEPENDENCIES ${TEST_TARGET_NAME})
endif()


#CPPCHECK
if (LIB_OPTION_CPPCHECK)
    if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        message(
            "==> Cppcheck, IWYU and Clang-Tidy Targets do not work with MSVC")
        return()
    endif()
    find_program(CPPCHECK cppcheck)

    # Exit with error if warnings found and if LIB_OPTION_WARNINGS_AS_ERRORS is set
    if(LIB_OPTION_WARNINGS_AS_ERRORS)
      set(CPP_CHECK_WARNING_AS_ERRORS --error-exitcode=1)
    else()
      set(CPP_CHECK_WARNING_AS_ERRORS )
    endif()
    
    if(CPPCHECK)
        message("==> Added Cppcheck for Target:${TEST_TARGET_NAME}_lib")
        add_custom_target(
          ${TEST_TARGET_NAME}_lib_cppcheck
            COMMAND
                ${CPPCHECK} --project=${CMAKE_BINARY_DIR}/compile_commands.json
                --enable=all
                --suppress=unusedFunction --suppress=unmatchedSuppression
                --suppress=missingIncludeSystem --suppress=toomanyconfigs                
                -i${CMAKE_BINARY_DIR}/ -i${CMAKE_SOURCE_DIR}/external/
                # Supress test files manually if you find bad warnings.
                --suppress=*:${CMAKE_CURRENT_SOURCE_DIR}/mytest1.cpp
                ${CPP_CHECK_WARNING_AS_ERRORS}
            USES_TERMINAL)
    else()
        message("==> CPPCHECK NOT FOUND")
    endif()  
endif()