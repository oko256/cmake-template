# This function sets up requested sanitizers for the given target.
function(x_NAME_x_enable_sanitizers
        target
        enable_sanitizer_address
        enable_sanitizer_leak
        enable_sanitizer_undefined
        enable_sanitizer_thread)

    set(sanitizers_list "")
    if(enable_sanitizer_address)
        list(APPEND sanitizers_list "address")
    endif()
    if(enable_sanitizer_undefined)
        list(APPEND sanitizers_list "undefined")
    endif()
    if(enable_sanitizer_leak)
        list(APPEND sanitizers_list "leak")
    endif()
    if(enable_sanitizer_thread)
        # ThreadSanitizer cannot be combined with Leak or Address!
        if("address" IN_LIST sanitizers_list OR "leak" IN_LIST sanitizers_list)
            message(FATAL_ERROR
                "[x_NAME_x] ThreadSanitizer does not work together with "
                "AddressSanitizer or LeakSanitizer.")
        else()
            list(APPEND sanitizers_list "thread")
        endif()
    endif()

    # Combine sanitizers into a single string and enable for target if needed.
    list(JOIN sanitizers_list "," combined_sanitizers)
    if(combined_sanitizers AND NOT "${combined_sanitizers}" STREQUAL "")
        message(STATUS
            "[x_NAME_x] Enabling sanitizers [${combined_sanitizers}] for target: ${target}")
        target_compile_options(${target} PRIVATE -fsanitize=${combined_sanitizers})
        target_link_options(${target} PRIVATE -fsanitize=${combined_sanitizers})
    endif()
endfunction()
