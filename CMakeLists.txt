cmake_minimum_required(VERSION 3.28)
include(cmake/build-guard.cmake)

project(
    x_PROJECT_NAME_x
    DESCRIPTION "TODO Add few words describing the project here"
    HOMEPAGE_URL "TODO Add project homepage URL here"
    LANGUAGES C CXX
    # By default, the version is set from Git tags, but you can override it here:
    # VERSION 1.2.3
)
set(CPACK_PACKAGE_VENDOR "TODO Add your organization or name here")

include(cmake/version.cmake)
if(NOT PROJECT_VERSION)
    # Set the default release branch of your project here (builds from other branches will be
    # noted in the version info output):
    x_NAME_x_set_project_version_from_git_tag(DEFAULT_BRANCH "main")
endif()
message(STATUS
    "[x_NAME_x] Project version: ${PROJECT_VERSION_FULL_STRING} "
    "(numeric: ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH})"
)

if(PROJECT_IS_TOP_LEVEL)
    # Set ON if you want this project to build possible libraries as shared libraries by default,
    # and set OFF if you prefer static libraries instead.
    option(BUILD_SHARED_LIBS "Build shared libraries" ON)
endif()

include(cmake/options.cmake)
include(cmake/target-properties.cmake)
x_NAME_x_setup_options()
x_NAME_x_apply_options_before_dependencies()
include(dependencies.cmake)

# Project Sources #############################################################

add_subdirectory(src)
add_subdirectory(src/examplelib)

# Documentation ###############################################################

find_package(Doxygen QUIET)
if(Doxygen_FOUND)
    set(DOXYGEN_FILE_PATTERNS *.c *.cpp *.cxx *.h *.hpp *.hxx *.md)
    set(DOXYGEN_EXCLUDE_PATTERNS */build/* */build-*/ */cmake/*)
    set(DOXYGEN_USE_MDFILE_AS_MAINPAGE "${PROJECT_SOURCE_DIR}/README.md")
    doxygen_add_docs(doc
        ${PROJECT_SOURCE_DIR}
        COMMENT "Generate documentation with Doxygen"
    )
endif()

###############################################################################

if(PROJECT_IS_TOP_LEVEL)
    include("${PROJECT_SOURCE_DIR}/systemd/systemd.cmake" OPTIONAL)
    include(CPack)
else()
    # Bail out here before even looking at tests if used as a subproject.
    return()
endif()

include(cmake/tests.cmake)
x_NAME_x_setup_tests()
