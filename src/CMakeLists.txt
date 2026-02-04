# Internal Common Object Library ###############################################

# List all source files for the common library here:
add_library(x_NAME_x-common OBJECT
    ExampleMultiplier.cpp
)
# List possible extra include directories for the common library here:
target_include_directories(x_NAME_x-common PUBLIC
    .
)

target_compile_features(x_NAME_x-common PUBLIC cxx_std_23)
x_NAME_x_apply_options(x_NAME_x-common)
x_NAME_x_apply_target_properties(x_NAME_x-common)
# Extra dependencies here:
# target_link_libraries(x_NAME_x-common PRIVATE ...)

# Main Executable ##############################################################

# List all source files for the main executable here:
add_executable(x_NAME_x-exe
    main.cpp
)
# List possible extra include directories for the main executable here:
target_include_directories(x_NAME_x-exe PRIVATE
    .
)

add_executable(x_NAME_x::exe ALIAS x_NAME_x-exe)
set_property(TARGET x_NAME_x-exe PROPERTY OUTPUT_NAME x_NAME_x)
target_compile_features(x_NAME_x-exe PUBLIC cxx_std_23)
target_link_libraries(x_NAME_x-exe PRIVATE x_NAME_x-common)
x_NAME_x_apply_options(x_NAME_x-exe)
x_NAME_x_apply_target_properties(x_NAME_x-exe)
x_NAME_x_add_version_info(x_NAME_x-exe)
# Extra dependencies here:
# target_link_libraries(x_NAME_x-exe PRIVATE ...)
target_link_libraries(x_NAME_x-exe PRIVATE spdlog::spdlog x_NAME_x::examplelib)

# Install Rules ################################################################

if(NOT CMAKE_SKIP_INSTALL_RULES)
    install(TARGETS x_NAME_x-exe RUNTIME COMPONENT x_NAME_x_Runtime)
endif()
