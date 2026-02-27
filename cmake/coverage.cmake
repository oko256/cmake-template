# This function creates a new target specified with COVERAGE_TARGET argument, which generates
# code coverage report using fastcov for executable target EXEC_TARGET (can also be executable
# path). Additional arguments for executable target can be provided with EXEC_ARGS argument.
# EXCLUDE argument can be used to provide list of glob patterns to exclude from the report.
# More excludes can also be provided globally with GLOBAL_COVERAGE_EXCLUDES variable.
# Base directory defaults to PROJECT_SOURCE_DIR, but can be changed with BASE_DIR argument.
function(x_NAME_x_setup_coverage_target_fastcov)
    cmake_parse_arguments(
        arg
        "" # Options
        "COVERAGE_TARGET;BASE_DIR;EXEC_TARGET" # One-value arguments
        "EXEC_ARGS;EXCLUDE" # Multi-value arguments
        ${ARGN}
    )

    find_program(FASTCOV_PROGRAM NAMES fastcov fastcov.py)
    if(NOT FASTCOV_PROGRAM)
        message(FATAL_ERROR
            "[x_PROJECT_NAME_x] Fastcov is required for code coverage but was not found in PATH."
        )
    endif()
    find_program(GCOV_PROGRAM NAMES gcov)
    if(NOT GCOV_PROGRAM)
        message(FATAL_ERROR
            "[x_PROJECT_NAME_x] gcov is required for code coverage but was not found in PATH."
        )
    endif()
    find_program(GENHTML_PROGRAM NAMES genhtml genhtml.perl genhtml.bat)
    if(NOT GENHTML_PROGRAM)
        message(FATAL_ERROR
            "[x_PROJECT_NAME_x] genhtml is required for code coverage but was not found in PATH."
        )
    endif()

    if(arg_BASE_DIR)
        set(_base_dir "${arg_BASE_DIR}")
    else()
        set(_base_dir "${PROJECT_SOURCE_DIR}")
    endif()

    set(_excludes "")
    foreach(i_exclude ${arg_EXCLUDE} ${GLOBAL_COVERAGE_EXCLUDES})
        list(APPEND _excludes "${i_exclude}")
    endforeach()
    list(REMOVE_DUPLICATES _excludes)

    set(_genhtml_extra_args "--ignore-errors;unsupported;--demangle-cpp")

    set(_zero_cmd ${FASTCOV_PROGRAM}
        --gcov ${GCOV_PROGRAM}
        --search-directory ${_base_dir}
        --zerocounters
    )
    set(_exec_cmd ${arg_EXEC_TARGET} ${arg_EXEC_ARGS})
    set(_capture_cmd ${FASTCOV_PROGRAM}
        --gcov ${GCOV_PROGRAM}
        --search-directory ${_base_dir}
        --process-gcno
        --output ${arg_COVERAGE_TARGET}.json
        --exclude-glob ${_excludes}
    )
    set(_convert_cmd ${FASTCOV_PROGRAM}
        -C ${arg_COVERAGE_TARGET}.json
        --lcov
        --output ${arg_COVERAGE_TARGET}.info
    )
    set(_genhtml_cmd ${GENHTML_PROGRAM}
        ${_genhtml_extra_args}
        -o ${arg_COVERAGE_TARGET}
        ${arg_COVERAGE_TARGET}.info
    )

    add_custom_target(${arg_COVERAGE_TARGET}
        COMMAND ${_zero_cmd}
        COMMAND ${_exec_cmd}
        COMMAND ${_capture_cmd}
        COMMAND ${_convert_cmd}
        COMMAND ${_genhtml_cmd}
        BYPRODUCTS
            ${arg_COVERAGE_TARGET}.json
            ${arg_COVERAGE_TARGET}.info
            ${arg_COVERAGE_TARGET}/index.html
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        DEPENDS ${arg_EXEC_TARGET}
        VERBATIM
        COMMENT
        "Generating code coverage report '${arg_COVERAGE_TARGET}' for target '${arg_EXEC_TARGET}'"
    )

    add_custom_command(TARGET ${arg_COVERAGE_TARGET} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo
        "Code coverage report generated: "
        "${arg_COVERAGE_TARGET}.json ${arg_COVERAGE_TARGET}.info ${arg_COVERAGE_TARGET}/index.html"
        COMMAND ${CMAKE_COMMAND} -E echo
            "Open in browser: file://${PROJECT_BINARY_DIR}/${arg_COVERAGE_TARGET}/index.html"
    )
endfunction()
