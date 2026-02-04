# This macro is only called if we are building the project as the top-level project.
# It sets up the building of tests.
macro(x_NAME_x_setup_tests)
    # Building tests is enabled by default if either global BUILD_TESTING=ON or
    # we are in developer mode.
    if(BUILD_TESTING OR x_NAME_x_DEVELOPER_MODE)
        set(x_NAME_x_BUILD_TESTING_DEFAULT ON)
    else()
        set(x_NAME_x_BUILD_TESTING_DEFAULT OFF)
    endif()
    option(x_NAME_x_BUILD_TESTING "Build tests for x_NAME_x" ${x_NAME_x_BUILD_TESTING_DEFAULT})
    if(x_NAME_x_BUILD_TESTING)
        message(STATUS "[x_NAME_x] Tests enabled")
        include(CTest)
        add_subdirectory(test)
    endif()
endmacro()
