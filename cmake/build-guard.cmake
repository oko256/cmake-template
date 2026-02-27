# Guard against building in-source
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
    message(
        FATAL_ERROR
        "[x_PROJECT_NAME_x] In-source builds are not allowed. "
        "Please read README.md for instructions on how to build this project. "
        "You may need to delete CMakeCache.txt and CMakeFiles/ first."
    )
endif()
