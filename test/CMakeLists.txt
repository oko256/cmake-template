# Try to find new enough Catch2 via find_package first, and if not found, fetch it.
find_package(Catch2 3.12.0 QUIET)
if(NOT Catch2_FOUND)
    message(STATUS "[x_PROJECT_NAME_x] System-installed Catch2 not found or too old, using FetchContent")
    include(FetchContent)
    FetchContent_Declare(
        Catch2
        GIT_REPOSITORY https://github.com/catchorg/Catch2.git
        GIT_TAG v3.12.0
    )
    set(FETCHCONTENT_UPDATES_DISCONNECTED_Catch2 ON) # No need to check for updates remotely
    FetchContent_MakeAvailable(Catch2)
else()
    message(STATUS "[x_PROJECT_NAME_x] Using system-installed Catch2")
endif()

# List all test sources for the test executable here:
add_executable(x_NAME_x-test
    main.test.cpp
    ExampleMultiplier.test.cpp
    examplelib/ExampleConcat.test.cpp
)
# List possible extra include directories for the test executable here:
target_include_directories(x_NAME_x-test PRIVATE
    .
)

set_property(TARGET x_NAME_x-test PROPERTY OUTPUT_NAME test_x_PROJECT_NAME_x)
target_compile_features(x_NAME_x-test PUBLIC cxx_std_23)
target_link_libraries(x_NAME_x-test PRIVATE x_NAME_x-common examplelib)
x_NAME_x_apply_options(x_NAME_x-test)
x_NAME_x_apply_test_target_properties(x_NAME_x-test)
x_NAME_x_set_code_coverage_target(x_NAME_x-test coverage)
# Link with Catch2
target_link_libraries(x_NAME_x-test PRIVATE Catch2::Catch2)

include(Catch)
catch_discover_tests(x_NAME_x-test)
