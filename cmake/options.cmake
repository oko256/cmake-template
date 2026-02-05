include(CMakeDependentOption)

# This macro sets up all configurable options for the project.
macro(x_NAME_x_setup_options)
    if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
        message(STATUS "[x_NAME_x] No build type selected, defaulting to Debug")
        set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Choose the type of build" FORCE)
        set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
            "Debug" "Release" "RelWithDebInfo" "MinSizeRel")
    endif()

    if(PROJECT_IS_TOP_LEVEL)
        option(x_NAME_x_DEVELOPER_MODE "Enable developer mode" OFF)

        # compile_commands.json is required for external tools
        set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL
            "Generate compile_commands.json for use by external tools" FORCE)
    endif()

    option(x_NAME_x_HARDENING "Enable hardening compiler options" ON)
    cmake_dependent_option(
        x_NAME_x_HARDENING_GLOBALLY
        "Attempt to push hardening options to built dependencies"
        ON
        x_NAME_x_HARDENING
        OFF
    )

    # Default CXX extensions to OFF, but allow toggling via presets or by user.
    # Applied to targets with functions in target-properties.cmake.
    option(x_NAME_x_CXX_EXTENSIONS "Enable compiler specific C++ extensions (like gnu++)" OFF)

    # Default IPO/LTO to OFF for now as it can increase build times significantly and may cause
    # issues with some dependencies. Can be enabled manually if desired.
    option(x_NAME_x_IPO "Enable interprocedural optimization (IPO/LTO)" OFF)

    # Sanitizer options
    option(x_NAME_x_SANITIZER_ADDRESS    "Enable AddressSanitizer"                   OFF)
    option(x_NAME_x_SANITIZER_LEAK       "Enable LeakSanitizer"                      OFF)
    option(x_NAME_x_SANITIZER_UNDEFINED  "Enable UndefinedBehaviorSanitizer"         OFF)
    option(x_NAME_x_SANITIZER_THREAD     "Enable ThreadSanitizer"                    OFF)

    # These options only appear in developer mode:
    cmake_dependent_option(x_NAME_x_WARNINGS_AS_ERRORS  "Treat warnings as errors"
        ON x_NAME_x_DEVELOPER_MODE OFF)
    cmake_dependent_option(x_NAME_x_SA_CLANG_TIDY      "Enable clang-tidy static analysis"
        ON x_NAME_x_DEVELOPER_MODE OFF)
    cmake_dependent_option(x_NAME_x_SA_CPPCHECK        "Enable cppcheck static analysis"
        ON x_NAME_x_DEVELOPER_MODE OFF)
    cmake_dependent_option(x_NAME_x_SA_CPPCHECK_EXH    "Enable cppcheck's exhaustive check level"
        OFF x_NAME_x_DEVELOPER_MODE OFF)
    cmake_dependent_option(x_NAME_x_SA_IWYU            "Enable include-what-you-use static analysis"
        ON x_NAME_x_DEVELOPER_MODE OFF)

    # Enable Ccache in developer mode if Ccache is available.
    find_program(CCACHE_PROGRAM ccache)
    if(CCACHE_PROGRAM)
        cmake_dependent_option(x_NAME_x_CCACHE "Enable Ccache for faster rebuilds"
            ON x_NAME_x_DEVELOPER_MODE OFF)
    endif()

    option(x_NAME_x_UNITY_BUILD "Enable unity build" OFF)

    option(x_NAME_x_COVERAGE "Enable code coverage reporting" OFF)
    set(x_NAME_x_COVERAGE_EXCLUDES "test/*;/usr/*;*/autogen-version/*" CACHE STRING
        "Glob patterns to exclude from code coverage, separated by ';'")

    if(NOT PROJECT_IS_TOP_LEVEL)
        # When used as a subproject, mark most options as advanced to reduce clutter.
        mark_as_advanced(
            x_NAME_x_IPO
            x_NAME_x_SANITIZER_ADDRESS
            x_NAME_x_SANITIZER_LEAK
            x_NAME_x_SANITIZER_UNDEFINED
            x_NAME_x_SANITIZER_THREAD
            x_NAME_x_WARNINGS_AS_ERRORS
            x_NAME_x_SA_CLANG_TIDY
            x_NAME_x_SA_CPPCHECK
            x_NAME_x_CCACHE
        )
    endif()
endmacro()

# This macro applies options that need to be set before dependencies are built.
# These are options that affect the build as a whole (i.e. globally set options).
macro(x_NAME_x_apply_options_before_dependencies)
    # Enable global compiler hardening if requested.
    if(x_NAME_x_HARDENING AND x_NAME_x_HARDENING_GLOBALLY)
        include("${PROJECT_SOURCE_DIR}/cmake/hardening.cmake")
        x_NAME_x_enable_hardening(unused ON)
    endif()

    # Enable global IPO/LTO if requested.
    if(x_NAME_x_IPO)
        include(CheckIPOSupported)
        check_ipo_supported(RESULT ipo_supported OUTPUT ipo_check_output)
        if(ipo_supported)
            message(STATUS "[x_NAME_x] IPO/LTO enabled")
            set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)
        else()
            message(FATAL_ERROR
                "[x_NAME_x] IPO/LTO requested, but not supported: ${ipo_check_output}")
        endif()
    endif()

    # Enable code coverage compiler flags if requested.
    if(x_NAME_x_COVERAGE)
        if(NOT CMAKE_BUILD_TYPE MATCHES "Debug")
            message(FATAL_ERROR
                "[x_NAME_x] Code coverage can only be enabled for Debug builds since it is the "
                "most accurate without optimizations and with debug symbols.")
        endif()
        include("${PROJECT_SOURCE_DIR}/cmake/CodeCoverage.cmake")
        message(STATUS
            "[x_NAME_x] Code coverage enabled (disables optimization and forces debug symbols)")
        append_coverage_compiler_flags()
        add_compile_options(-O0 -g)
    endif()
endmacro()

# This function applies various options to the given target. This should be called for all
# targets of this project that is desired to follow the custom project options.
function(x_NAME_x_apply_options target)
    message(STATUS "[x_NAME_x] Applying options for target: ${target}")
    include("${PROJECT_SOURCE_DIR}/cmake/warnings.cmake")
    x_NAME_x_enable_warnings(${target} ${x_NAME_x_WARNINGS_AS_ERRORS})

    # Enable compiler hardening for local targets if requested.
    if(x_NAME_x_HARDENING AND NOT x_NAME_x_HARDENING_GLOBALLY)
        include("${PROJECT_SOURCE_DIR}/cmake/hardening.cmake")
        x_NAME_x_enable_hardening(${target} OFF)
    endif()

    include("${PROJECT_SOURCE_DIR}/cmake/sanitizers.cmake")
    x_NAME_x_enable_sanitizers(
        ${target}
        ${x_NAME_x_SANITIZER_ADDRESS}
        ${x_NAME_x_SANITIZER_LEAK}
        ${x_NAME_x_SANITIZER_UNDEFINED}
        ${x_NAME_x_SANITIZER_THREAD}
    )

    if(x_NAME_x_SA_CLANG_TIDY)
        message(STATUS "[x_NAME_x] - Enabling clang-tidy static analysis")
        # This is actually configured per-target. See target-properties.cmake.
    endif()
    if(x_NAME_x_SA_CPPCHECK)
        message(STATUS "[x_NAME_x] - Enabling cppcheck static analysis")
        # This is actually configured per-target. See target-properties.cmake.
    endif()

    if(x_NAME_x_CCACHE)
        find_program(CCACHE_PROGRAM ccache)
        if(CCACHE_PROGRAM)
            message(STATUS "[x_NAME_x] - Ccache enabled")
            set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
            set(CMAKE_C_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
        else()
            message(FATAL_ERROR
                "[x_NAME_x] Ccache option is enabled but Ccache could not be found!")
        endif()
    endif()

    set_target_properties(${target} PROPERTIES UNITY_BUILD ${x_NAME_x_UNITY_BUILD})
    if(x_NAME_x_UNITY_BUILD)
        message(STATUS "[x_NAME_x] - Unity build enabled")
    endif()
endfunction()

# This function uses given 'test_target' as the executable target to generate code coverage.
# Code coverage is provided as a separate target named 'coverage_target'.
# Example: x_NAME_x_set_code_coverage_target(my-program-test coverage)
#          $ make coverage
function(x_NAME_x_set_code_coverage_target test_target coverage_target)
    if(x_NAME_x_COVERAGE)
        include("${PROJECT_SOURCE_DIR}/cmake/CodeCoverage.cmake")
        message(STATUS
            "[x_NAME_x] Target '${test_target}' provides code coverage target '${coverage_target}'")
        setup_target_for_coverage_lcov(
            NAME ${coverage_target}
            EXECUTABLE ${test_target}
            EXCLUDE "${x_NAME_x_COVERAGE_EXCLUDES}"
            LCOV_ARGS --ignore-errors unused # Do not fail if some exclude patterns are unused
        )
    endif()
endfunction()
