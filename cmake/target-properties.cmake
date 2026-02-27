# This function applies some target properties according to set project options.
# Parameter is_test should be set ON for targets that build unit tests and similar.
function(x_NAME_x_apply_target_properties target)
    set_target_properties(${target} PROPERTIES CXX_EXTENSIONS ${x_NAME_x_CXX_EXTENSIONS})
    if(x_NAME_x_SA_CLANG_TIDY)
        x_NAME_x_enable_clang_tidy(${target})
    endif()
    if(x_NAME_x_SA_CPPCHECK)
        x_NAME_x_enable_cppcheck(${target})
    endif()
    if(x_NAME_x_SA_IWYU)
        x_NAME_x_enable_iwyu(${target})
    endif()
endfunction()

# Similar to apply_target_properties, but this function should be used when the target builds
# unit tests or for similar testing targets.
function(x_NAME_x_apply_test_target_properties target)
    set_target_properties(${target} PROPERTIES CXX_EXTENSIONS ${x_NAME_x_CXX_EXTENSIONS})
    if(x_NAME_x_SA_IWYU)
        x_NAME_x_enable_iwyu(${target})
    endif()
    # clang-tidy and cppcheck are skipped here for unit tests since many unit testing frameworks
    # don't really adhere too well to many rules...
endfunction()

# This function enables clang-tidy static analysis for the given target.
function(x_NAME_x_enable_clang_tidy target)
    find_program(CLANG_TIDY_EXE NAMES clang-tidy REQUIRED)
    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/.clang-tidy")
        message(FATAL_ERROR
            "[x_PROJECT_NAME_x] clang-tidy configuration does not exist for this project! "
            "Please create to: ${CMAKE_SOURCE_DIR}/.clang-tidy"
        )
    endif()
    set(CLANG_TIDY_OPT "${CLANG_TIDY_EXE}")
    list(APPEND CLANG_TIDY_OPT
        "--config-file=${CMAKE_SOURCE_DIR}/.clang-tidy"
        # Exclude FetchContent dependencies and /usr/local/ headers from analysis
        "--exclude-header-filter=(/_deps/|/usr/local/)"
        # Suppress warnings about unknown/ignored command line options passed to clang-tidy
        "--extra-arg=-Wno-unknown-warning-option"
        "--extra-arg=-Wno-ignored-optimization-argument"
        "--extra-arg=-Wno-unused-command-line-argument"
        # Enable colored output
        "--use-color"
    )
    if(x_NAME_x_WARNINGS_AS_ERRORS)
        list(APPEND CLANG_TIDY_OPT "--warnings-as-errors=*")
    endif()
    set_target_properties(${target} PROPERTIES
        CXX_CLANG_TIDY "${CLANG_TIDY_OPT}"
        C_CLANG_TIDY "${CLANG_TIDY_OPT}"
    )
endfunction()

# This function enables cppcheck static analysis for the given target.
function(x_NAME_x_enable_cppcheck target)
    find_program(CPPCHECK_EXE NAMES cppcheck REQUIRED)
    set(CPPCHECK_OPT "${CPPCHECK_EXE}")
    list(APPEND CPPCHECK_OPT
        # Exclude FetchContent dependencies from analysis
        "--suppress=*:*_deps/*"
        # Enable various checks
        "--enable=warning,style,performance,portability"
        # Enable even inconclusive checks
        "--inconclusive"
        # Allow inline suppression comments in the code
        "--inline-suppr"
    )
    if(x_NAME_x_WARNINGS_AS_ERRORS)
        list(APPEND CPPCHECK_OPT "--error-exitcode=2")
    endif()
    if(x_NAME_x_SA_CPPCHECK_EXH)
        list(APPEND CPPCHECK_OPT "--check-level=exhaustive")
    else()
        if(x_NAME_x_WARNINGS_AS_ERRORS)
            # Normal check level can output notices that branches have been limited, and we don't
            # want those to be treated as errors, so in this case we suppress that warning.
            list(APPEND CPPCHECK_OPT "--suppress=normalCheckLevelMaxBranches")
        endif()
    endif()
    set_target_properties(${target} PROPERTIES
        CXX_CPPCHECK "${CPPCHECK_OPT}"
        C_CPPCHECK "${CPPCHECK_OPT}"
    )
endfunction()

# This function enables include-what-you-use static analysis for the given target.
function(x_NAME_x_enable_iwyu target)
    find_program(IWYU_EXE NAMES include-what-you-use REQUIRED)
    set(IWYU_OPT "${IWYU_EXE}")
    list(APPEND IWYU_OPT
        # Suppress warnings about unknown/ignored command line options passed to IWYU
        "-Wno-unknown-warning-option"
        "-Wno-ignored-optimization-argument"
        "-Wno-unused-command-line-argument"
    )
    if(x_NAME_x_WARNINGS_AS_ERRORS)
        list(APPEND IWYU_OPT "-Xiwyu" "--error=3")
    endif()
    set_target_properties(${target} PROPERTIES
        CXX_INCLUDE_WHAT_YOU_USE "${IWYU_OPT}"
        C_INCLUDE_WHAT_YOU_USE "${IWYU_OPT}"
    )
endfunction()
