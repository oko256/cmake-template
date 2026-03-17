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
                "[x_PROJECT_NAME_x] ThreadSanitizer does not work together with "
                "AddressSanitizer or LeakSanitizer.")
        else()
            list(APPEND sanitizers_list "thread")
        endif()
    endif()

    # Combine sanitizers into a single string and enable for target if needed.
    list(JOIN sanitizers_list "," combined_sanitizers)
    if(combined_sanitizers AND NOT "${combined_sanitizers}" STREQUAL "")
        message(STATUS
            "[x_PROJECT_NAME_x] Enabling sanitizers [${combined_sanitizers}] for target: ${target}")
        target_compile_options(${target} PRIVATE -fsanitize=${combined_sanitizers})
        target_link_options(${target} PRIVATE -fsanitize=${combined_sanitizers})
        target_link_libraries(${target} PRIVATE x_NAME_x_sanitizer_defaults)
    endif()
endfunction()

if(NOT TARGET x_NAME_x_sanitizer_defaults)
    # Create a small source file that provides default options for sanitizers.
    file(WRITE "${CMAKE_BINARY_DIR}/sanitizer_defaults.c" [=[
/*
 * Default options for sanitizer runtimes.
 *
 * These functions are called by the respective sanitizer runtimes at startup.
 * Environment variables (e.g. ASAN_OPTIONS) can be used to override these defaults.
 */

/*** AddressSanitizer ***/
#if defined(__has_feature)
  #if __has_feature(address_sanitizer)
    #define HAS_ASAN
  #endif
#elif defined(__SANITIZE_ADDRESS__)
  #define HAS_ASAN
#endif

#ifdef HAS_ASAN
const char *__asan_default_options(void) {
    return "halt_on_error=1"
           ":abort_on_error=1"
           ":print_stacktrace=1"
           ":detect_leaks=1";
}
#endif

/*** ThreadSanitizer ***/
#if defined(__has_feature)
  #if __has_feature(thread_sanitizer)
    #define HAS_TSAN
  #endif
#elif defined(__SANITIZE_THREAD__)
  #define HAS_TSAN
#endif

#ifdef HAS_TSAN
const char *__tsan_default_options(void) {
    return "halt_on_error=1"
           ":abort_on_error=1"
           ":print_stacktrace=1";
}
#endif

/*** LeakSanitizer ***/
const char *__lsan_default_options(void) {
    return "exitcode=42";
}

/*** UndefinedBehaviorSanitizer ***/
const char *__ubsan_default_options(void) {
    return "halt_on_error=1"
           ":abort_on_error=1"
           ":print_stacktrace=1";
}

]=])
    add_library(x_NAME_x_sanitizer_defaults OBJECT "${CMAKE_BINARY_DIR}/sanitizer_defaults.c")
    set_target_properties(x_NAME_x_sanitizer_defaults PROPERTIES SKIP_LINTING ON)
endif()
