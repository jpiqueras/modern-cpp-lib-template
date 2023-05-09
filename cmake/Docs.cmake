
# Find Doxygen
find_package(Doxygen)

# The call to doxygen_add_docs generates the Doxyfile configuration file
# and configuration variables listed in Doxygen documentation such "CALL_GRAPH"
# are set-up to the value of the corresponding DOXYGEN_* variables.
# See: https://cmake.org/cmake/help/latest/module/FindDoxygen.html
#      https://www.doxygen.nl/manual/config.html


# Modern theme look with Doxygen Awesome CSS
# Check https://github.com/jothepro/doxygen-awesome-css
include(FetchContent)
FetchContent_Declare(
    doxygen-awesome-css
    GIT_REPOSITORY
    https://github.com/jothepro/doxygen-awesome-css.git
    GIT_TAG
    v2.2.0
)    
FetchContent_MakeAvailable(doxygen-awesome-css)

set(DOXYGEN_HTML_EXTRA_STYLESHEET
${doxygen-awesome-css_SOURCE_DIR}/doxygen-awesome.css 
${doxygen-awesome-css_SOURCE_DIR}/doxygen-awesome-sidebar-only.css)

set(DOXYGEN_GENERATE_TREEVIEW  YES)
set(DOXYGEN_HTML_COLORSTYLE    LIGHT)
set(DOXYGEN_FULL_SIDEBAR       NO)
set(DOXYGEN_DISABLE_INDEX      NO)



set(DOXYGEN_GENERATE_HTML YES)
set(DOXYGEN_HTML_OUTPUT   ${PROJECT_BINARY_DIR}/html_docs)
set(DOXYGEN_HAVE_DOT YES)
set(DOXYGEN_DOT_IMAGE_FORMAT svg)
set(DOXYGEN_DOT_TRANSPARENT YES)
set(DOXYGEN_EXTRACT_PRIVATE YES)
set(DOXYGEN_CALL_GRAPH YES)



set(DOXYGEN_PROJECT_BRIEF "Modern C++ template")
set(DOXYGEN_USE_MDFILE_AS_MAINPAGE index.md)


# Add a target to generate the Doxygen documentation
# In doxygen, files are processed in the order you put them in the list
# so I put them manually to set the order.
doxygen_add_docs(
    doc
    ${PROJECT_SOURCE_DIR}/docs/index.md
    ${PROJECT_SOURCE_DIR}/README.md
    ${PROJECT_SOURCE_DIR}/docs/tools.md
    ${PROJECT_SOURCE_DIR}/docs/workflow.md
    ${PROJECT_SOURCE_DIR}/docs/configuring.md
    ${PROJECT_SOURCE_DIR}/docs/cicd.md
    ${PROJECT_SOURCE_DIR}/docs/dependencies.md
    ${PROJECT_SOURCE_DIR}/docs/releases.md
    ${PROJECT_SOURCE_DIR}/docs/faq.md
    ${PROJECT_SOURCE_DIR}/${LIB_NAME}
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    COMMENT "Generate HTML documentation"
)

