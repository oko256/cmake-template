# Add configure and install rules for all Systemd files of the project here.

include(GNUInstallDirs)

# If cache variable SYSTEMD_UNIT_DIR is not defined, use a default path.
if(NOT DEFINED CACHE{SYSTEMD_UNIT_DIR})
    set(x_NAME_x_SYSTEMD_UNIT_DIR "${CMAKE_INSTALL_FULL_SYSCONFDIR}/systemd/system")
else()
    set(x_NAME_x_SYSTEMD_UNIT_DIR "${SYSTEMD_UNIT_DIR}")
endif()

# Configure rules:
configure_file("systemd/example.service.in" "${CMAKE_CURRENT_BINARY_DIR}/example.service" @ONLY)

if(NOT CMAKE_SKIP_INSTALL_RULES)
    # Install rules:
    install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/example.service"
        DESTINATION "${x_NAME_x_SYSTEMD_UNIT_DIR}"
    )
endif()
