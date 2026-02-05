# This function enables various compiler warnings for the given target.
# If warnings_as_errors is ON, it will set compiler to treat warnings as errors.
function(x_NAME_x_enable_warnings
        target
        warnings_as_errors)

    # Basic set of useful warnings that work on both GCC and Clang in both C and C++ modes:
    list(APPEND warn_compile_options_cpp
        -Wall                   # Warnings for constructs often associated with defects.
        -Wextra                 # -"-
        -Wformat                # Additional format function warnings.
        -Wformat=2              # -"-
        -Wconversion            # Implicit conversions that may lose data.
        -Wimplicit-fallthrough  # A switch case falls through.
        -Werror=format-security # Treat non-literal format strings as errors.
        -Wshadow                # A local variable shadows another.
        -Wcast-align            # Cast increases alignment requirement.
        -Wunused                # Unused variables, functions, etc.
        -Wsign-conversion       # Sign conversions.
        -Wnull-dereference      # Possible null pointer dereference.
        -Wdouble-promotion      # Implicit conversion from float to double.
    )
    if(warnings_as_errors)
        message(STATUS "[x_NAME_x] Treating warnings as errors for target: ${target}")
        list(APPEND warn_compile_options_cpp -Werror)
    endif()
    set(warn_compile_options_c ${warn_compile_options_cpp})

    # Additional warnings for C++ language that work on both GCC and Clang:
    list(APPEND warn_compile_options_cpp
        -Wnon-virtual-dtor      # A class with virtual functions has a non-virtual destructor.
        -Wold-style-cast        # Use of C-style casts in C++ code.
        -Woverloaded-virtual    # A function hides a virtual function from a base class.
    )

    # Additional warnings for C language that work on both GCC and Clang:
    list(APPEND warn_compile_options_c
        -Werror=implicit                    # Implicit function declarations.
        -Werror=incompatible-pointer-types  # Pointer type mismatches.
        -Werror=int-conversion              # Implicit int conversions that may change value.
    )

    # Additional GCC specific warnings:
    if(CMAKE_CXX_COMPILER_ID MATCHES ".*GNU")
        # For C:
        list(APPEND warn_compile_options_c
            -Wtrampolines           # Warn about trampolines that require executable stacks.
            -Wduplicated-cond       # Identical branches in if-else-if chain.
            -Wduplicated-branches   # Identical switch branches.
            -Wlogical-op            # Suspicious use of logical operators in expressions.
            -Wuseless-cast          # Cast that does not change value.
        )
        # For C++:
        list(APPEND warn_compile_options_cpp
            -Wtrampolines           # Warn about trampolines that require executable stacks.
            -Wduplicated-cond       # Identical branches in if-else-if chain.
            -Wduplicated-branches   # Identical switch branches.
            -Wlogical-op            # Suspicious use of logical operators in expressions.
            -Wuseless-cast          # Cast that does not change value.
            -Wsuggest-override      # Suggest override/final keywords for virtual functions.
        )
    endif()

    message(STATUS "[x_NAME_x] Enabled extra compiler warnings for target: ${target}")
    message(VERBOSE "[x_NAME_x] - C compiler: ${warn_compile_options_c}")
    message(VERBOSE "[x_NAME_x] - C++ compiler: ${warn_compile_options_cpp}")

    target_compile_options(${target} PRIVATE
        $<$<COMPILE_LANGUAGE:CXX>:${warn_compile_options_cpp}>
        $<$<COMPILE_LANGUAGE:C>:${warn_compile_options_c}>
    )
endfunction()
