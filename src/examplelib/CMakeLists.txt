include(GenerateExportHeader)

# Name of the library this file shall build:
set(LIBRARY_NAME "examplelib")

# Shared/Static Library ########################################################

# List all source files for the library here:
add_library(${LIBRARY_NAME}
    ExampleConcat.cpp
    ExampleInternal.cpp
)
# List possible extra private include directories for the library here:
target_include_directories(${LIBRARY_NAME} PRIVATE
    .
)

target_include_directories(${LIBRARY_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
target_include_directories(${LIBRARY_NAME} PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
)
add_library(x_NAME_x::${LIBRARY_NAME} ALIAS ${LIBRARY_NAME})
target_compile_features(${LIBRARY_NAME} PUBLIC cxx_std_23)
x_NAME_x_apply_options(${LIBRARY_NAME})
x_NAME_x_apply_target_properties(${LIBRARY_NAME})
x_NAME_x_add_version_info(${LIBRARY_NAME})

# Extra dependencies here:
# target_link_libraries(${LIBRARY_NAME} PRIVATE/PUBLIC ...)
target_link_libraries(${LIBRARY_NAME} PUBLIC spdlog::spdlog)

# Library version has appended ".999" to indicate a dev build.
if(PROJECT_VERSION_IS_DEV_BUILD)
    set(library_version_suffix ".999")
endif()
set_target_properties(${LIBRARY_NAME} PROPERTIES
    VERSION "${PROJECT_VERSION}${library_version_suffix}"
    SOVERSION ${PROJECT_VERSION_MAJOR}
    # Best practice is to only export the specified symbols to shared libraries.
    # These properties ensure we have default visibility of "hidden".
    CXX_VISIBILITY_PRESET hidden
    C_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN YES
)

generate_export_header(${LIBRARY_NAME})

# Install Rules ################################################################

if(NOT CMAKE_SKIP_INSTALL_RULES)
    include(CMakePackageConfigHelpers)
    include(GNUInstallDirs)
    target_sources(${LIBRARY_NAME} PUBLIC
        FILE_SET generated_headers
            TYPE HEADERS
            BASE_DIRS $<TARGET_PROPERTY:${LIBRARY_NAME},BINARY_DIR>
            FILES ${CMAKE_CURRENT_BINARY_DIR}/${LIBRARY_NAME}_export.h
    )
    install(
        DIRECTORY "${PROJECT_SOURCE_DIR}/include/"
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
        COMPONENT x_NAME_x_Development
    )
    install(TARGETS ${LIBRARY_NAME}
        EXPORT ${LIBRARY_NAME}Targets
        RUNTIME
            COMPONENT x_NAME_x_Runtime
        LIBRARY
            COMPONENT x_NAME_x_Runtime
            NAMELINK_COMPONENT x_NAME_x_Development
        ARCHIVE
            COMPONENT x_NAME_x_Development
        INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
        FILE_SET generated_headers
            COMPONENT x_NAME_x_Development
    )
    configure_package_config_file(
        "${PROJECT_SOURCE_DIR}/${LIBRARY_NAME}Config.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/${LIBRARY_NAME}Config.cmake"
        INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${LIBRARY_NAME}"
    )
    write_basic_package_version_file(
        "${LIBRARY_NAME}ConfigVersion.cmake"
        COMPATIBILITY SameMajorVersion
    )
    install(
        FILES
            "${CMAKE_CURRENT_BINARY_DIR}/${LIBRARY_NAME}Config.cmake"
            "${CMAKE_CURRENT_BINARY_DIR}/${LIBRARY_NAME}ConfigVersion.cmake"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${LIBRARY_NAME}"
        COMPONENT x_NAME_x_Development
    )
    install(
        EXPORT ${LIBRARY_NAME}Targets
        NAMESPACE ${LIBRARY_NAME}::
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${LIBRARY_NAME}"
        COMPONENT x_NAME_x_Development
    )
endif()
